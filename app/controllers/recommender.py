from fastapi import HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional, Dict, Any
import pandas as pd
import pickle
import numpy as np
from sklearn.neighbors import NearestNeighbors
from sklearn.decomposition import TruncatedSVD
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.metrics.pairwise import cosine_similarity

from langchain_chroma import Chroma
from langchain_google_genai import GoogleGenerativeAIEmbeddings


from scipy.sparse import csr_matrix
import logging
from datetime import datetime, timedelta
import os
from pathlib import Path
import re
from app.models.database import load_all_books, load_ratings_data, get_user_ratings

# Configuration
MAX_FEATURES = 1000
MIN_RATINGS_PER_BOOK = 3
MIN_RATINGS_PER_USER = 2
SVD_COMPONENTS = 50
CONTENT_FEATURES = 5000

# Setup logging
logger = logging.getLogger(__name__)

# Models directory
models_dir = Path("./artifacts")
models_dir.mkdir(exist_ok=True)

# Pydantic models
class BookRec(BaseModel):
    isbn: str
    title: str

class ItemRecRequest(BaseModel):
    book_titles: List[str] = Field(..., description="List of seed book titles", min_items=1, max_items=10)
    limit: int = Field(20, gt=0, le=100, description="Maximum number of recommendations")

class UserRecRequest(BaseModel):
    user_id: str = Field(..., description="User ID for recommendations")
    limit: int = Field(20, gt=0, le=100, description="Maximum number of recommendations")
    min_rating_threshold: float = Field(6.0, ge=1.0, le=10.0, description="Minimum rating threshold for recommendations")

class ModelStats(BaseModel):
    last_retrain: Optional[datetime] = None
    total_ratings: int = 0
    total_books: int = 0
    books_with_ratings: int = 0
    unique_users: int = 0
    model_size_mb: float = 0.0
    sparsity: float = 0.0

# Global variables for models
class HybridModelContainer:
    def __init__(self):
        # Collaborative filtering models
        self.item_model: Optional[NearestNeighbors] = None
        self.user_model: Optional[NearestNeighbors] = None
        self.svd_model: Optional[TruncatedSVD] = None
        self.user_features: Optional[np.ndarray] = None
        self.item_features: Optional[np.ndarray] = None
        
        # Content-based models
        self.content_vectorizer: Optional[TfidfVectorizer] = None
        self.content_features: Optional[np.ndarray] = None
        self.content_model: Optional[NearestNeighbors] = None
        
        # Mappings
        self.user_idx_map: Dict[str, int] = {}
        self.item_idx_map: Dict[str, int] = {}
        self.idx_user_map: Dict[int, str] = {}
        self.idx_item_map: Dict[int, str] = {}
        
        # All books data
        self.all_books: Dict[str, Dict] = {}
        self.content_idx_map: Dict[str, int] = {}
        self.idx_content_map: Dict[int, str] = {}
        
        self.last_retrain: Optional[datetime] = None
        self.stats: ModelStats = ModelStats()
        
    def is_loaded(self) -> bool:
        return (self.content_model is not None and 
                len(self.all_books) > 0)

models = HybridModelContainer()

def clean_text(text: str) -> str:
    """Clean text for feature extraction"""
    if not text or pd.isna(text):
        return ""
    text = str(text).lower()
    text = re.sub(r'[^a-zA-Z\s]', ' ', text)
    text = re.sub(r'\s+', ' ', text)
    return text.strip()

def create_content_features(books_data: List[Dict]) -> tuple:
    """Create content-based features for all books"""
    logger.info("Creating content-based features...")
    
    content_strings = []
    isbn_list = []
    
    for book in books_data:
        content = clean_text(book['content'])
        if content:
            content_strings.append(content)
            isbn_list.append(book['isbn'])
    
    if not content_strings:
        raise HTTPException(status_code=500, detail="No valid content found for books")
    
    vectorizer = TfidfVectorizer(
        max_features=CONTENT_FEATURES,
        stop_words='english',
        ngram_range=(1, 2),
        min_df=2,
        max_df=0.8
    )
    
    content_matrix = vectorizer.fit_transform(content_strings)
    
    content_idx_map = {isbn: idx for idx, isbn in enumerate(isbn_list)}
    idx_content_map = {idx: isbn for idx, isbn in enumerate(isbn_list)}
    
    content_model = NearestNeighbors(
        n_neighbors=min(50, len(isbn_list)),
        metric='cosine',
        algorithm='brute'
    )
    content_model.fit(content_matrix)
    
    return vectorizer, content_matrix, content_model, content_idx_map, idx_content_map

def create_sparse_matrix(df: pd.DataFrame) -> tuple:
    """Create sparse rating matrix with optimizations"""
    user_counts = df['user_id'].value_counts()
    item_counts = df['isbn10'].value_counts()
    
    valid_users = user_counts[user_counts >= MIN_RATINGS_PER_USER].index
    valid_items = item_counts[item_counts >= MIN_RATINGS_PER_BOOK].index
    
    df_filtered = df[
        (df['user_id'].isin(valid_users)) & 
        (df['isbn10'].isin(valid_items))
    ].copy()
    
    logger.info(f"Filtered CF data: {len(df_filtered)} ratings, "
                f"{df_filtered['user_id'].nunique()} users, "
                f"{df_filtered['isbn10'].nunique()} items")
    
    unique_users = df_filtered['user_id'].unique()
    unique_items = df_filtered['isbn10'].unique()
    
    user_to_idx = {user: idx for idx, user in enumerate(unique_users)}
    item_to_idx = {item: idx for idx, item in enumerate(unique_items)}
    
    user_indices = df_filtered['user_id'].map(user_to_idx)
    item_indices = df_filtered['isbn10'].map(item_to_idx)
    ratings = df_filtered['rating'].values
    
    rating_matrix = csr_matrix(
        (ratings, (user_indices, item_indices)),
        shape=(len(unique_users), len(unique_items))
    )
    
    return rating_matrix, user_to_idx, item_to_idx

async def retrain_hybrid():
    """Train both collaborative and content-based models"""
    try:
        logger.info("Starting hybrid model training...")
        
        # Load all books for content-based recommendations
        books_data = await load_all_books()
        
        if not books_data:
            raise HTTPException(status_code=500, detail="No books found in collection")
        
        # Store books data
        models.all_books = {}
        for book in books_data:
            models.all_books[book['isbn']] = book
            
        # Create content-based features
        vectorizer, content_matrix, content_model, content_idx_map, idx_content_map = create_content_features(books_data)
        
        models.content_vectorizer = vectorizer
        models.content_features = content_matrix
        models.content_model = content_model
        models.content_idx_map = content_idx_map
        models.idx_content_map = idx_content_map
        
        # Load ratings for collaborative filtering
        ratings_data = await load_ratings_data()
        
        if len(ratings_data) >= 100:
            df = pd.DataFrame(ratings_data)
            df = df[df['rating'] > 0]
            
            rating_matrix, user_to_idx, item_to_idx = create_sparse_matrix(df)
            
            if rating_matrix.shape[0] > 0 and rating_matrix.shape[1] > 0:
                idx_to_user = {idx: user for user, idx in user_to_idx.items()}
                idx_to_item = {idx: item for item, idx in item_to_idx.items()}
                
                n_components = min(SVD_COMPONENTS, min(rating_matrix.shape) - 1)
                svd = TruncatedSVD(n_components=n_components)
                user_features = svd.fit_transform(rating_matrix)
                item_features = svd.components_.T
                
                item_model = NearestNeighbors(
                    n_neighbors=min(50, item_features.shape[0]),
                    metric='cosine',
                    algorithm='brute'
                )
                item_model.fit(item_features)
                
                user_model = NearestNeighbors(
                    n_neighbors=min(20, user_features.shape[0]),
                    metric='cosine',
                    algorithm='brute'
                )
                user_model.fit(user_features)
                
                models.item_model = item_model
                models.user_model = user_model
                models.svd_model = svd
                models.user_features = user_features
                models.item_features = item_features
                models.user_idx_map = user_to_idx
                models.item_idx_map = item_to_idx
                models.idx_user_map = idx_to_user
                models.idx_item_map = idx_to_item
                
                logger.info(f"Collaborative filtering trained with {len(user_to_idx)} users and {len(item_to_idx)} items")
        
        models.last_retrain = datetime.utcnow()
        
        models.stats = ModelStats(
            last_retrain=models.last_retrain,
            total_ratings=len(ratings_data) if ratings_data else 0,
            total_books=len(books_data),
            books_with_ratings=len(models.item_idx_map),
            unique_users=len(models.user_idx_map),
            model_size_mb=_calculate_model_size(),
            sparsity=1.0 - (rating_matrix.nnz / (rating_matrix.shape[0] * rating_matrix.shape[1])) if 'rating_matrix' in locals() else 0.0
        )
        
        await save_models()
        
        logger.info(f"Hybrid training completed. Total books: {len(books_data)}, "
                   f"Books with ratings: {len(models.item_idx_map)}")
        
    except Exception as e:
        logger.error(f"Error during hybrid training: {e}")
        raise HTTPException(status_code=500, detail=f"Model training failed: {str(e)}")

def _calculate_model_size() -> float:
    """Calculate approximate model size in MB"""
    size = 0
    if models.user_features is not None:
        size += models.user_features.nbytes
    if models.item_features is not None:
        size += models.item_features.nbytes
    if models.content_features is not None:
        size += models.content_features.data.nbytes
    return size / (1024 * 1024)

def get_content_recommendations(isbn: str, limit: int = 20) -> List[str]:
    """Get content-based recommendations for a book - returns list of ISBNs"""
    if isbn not in models.content_idx_map:
        return []
    
    book_idx = models.content_idx_map[isbn]
    
    try:
        distances, indices = models.content_model.kneighbors(
            models.content_features[book_idx],
            n_neighbors=min(limit + 1, models.content_features.shape[0])
        )
        
        recommendations = []
        for idx in indices[0][1:]:  # Skip first (self)
            similar_isbn = models.idx_content_map[idx]
            recommendations.append(similar_isbn)
        
        return recommendations[:limit]
    
    except Exception as e:
        logger.error(f"Error in content recommendations: {e}")
        return []

def get_collaborative_recommendations(isbn: str, limit: int = 20) -> List[str]:
    """Get collaborative filtering recommendations for a book - returns list of ISBNs"""
    if not models.item_model or isbn not in models.item_idx_map:
        return []
    
    item_idx = models.item_idx_map[isbn]
    
    try:
        distances, indices = models.item_model.kneighbors(
            models.item_features[item_idx].reshape(1, -1),
            n_neighbors=min(limit + 1, len(models.item_idx_map))
        )
        
        recommendations = []
        for idx in indices[0][1:]:  # Skip first (self)
            similar_isbn = models.idx_item_map[idx]
            recommendations.append(similar_isbn)
        
        return recommendations[:limit]
    
    except Exception as e:
        logger.error(f"Error in collaborative recommendations: {e}")
        return []

def find_book_by_title(title: str) -> Optional[str]:
    """Find book ISBN by title (case insensitive)"""
    title_lower = title.lower().strip()
    
    for isbn, book_info in models.all_books.items():
        if book_info['title'].lower().strip() == title_lower:
            return isbn
    
    return None

async def save_models():
    """Save trained models to disk"""
    try:
        model_data = {
            'item_model': models.item_model,
            'user_model': models.user_model,
            'svd_model': models.svd_model,
            'user_features': models.user_features,
            'item_features': models.item_features,
            'content_vectorizer': models.content_vectorizer,
            'content_features': models.content_features,
            'content_model': models.content_model,
            'user_idx_map': models.user_idx_map,
            'item_idx_map': models.item_idx_map,
            'idx_user_map': models.idx_user_map,
            'idx_item_map': models.idx_item_map,
            'content_idx_map': models.content_idx_map,
            'idx_content_map': models.idx_content_map,
            'all_books': models.all_books,
            'last_retrain': models.last_retrain,
            'stats': models.stats.dict()
        }
        
        with open(models_dir / "hybrid_models.pkl", "wb") as f:
            pickle.dump(model_data, f, protocol=pickle.HIGHEST_PROTOCOL)
            
        logger.info("Hybrid models saved successfully")
    except Exception as e:
        logger.error(f"Error saving models: {e}")

async def load_models():
    """Load models from disk"""
    try:
        model_path = models_dir / "hybrid_models.pkl"
        if model_path.exists():
            with open(model_path, "rb") as f:
                model_data = pickle.load(f)
            
            models.item_model = model_data.get('item_model')
            models.user_model = model_data.get('user_model')
            models.svd_model = model_data.get('svd_model')
            models.user_features = model_data.get('user_features')
            models.item_features = model_data.get('item_features')
            models.content_vectorizer = model_data.get('content_vectorizer')
            models.content_features = model_data.get('content_features')
            models.content_model = model_data.get('content_model')
            models.user_idx_map = model_data.get('user_idx_map', {})
            models.item_idx_map = model_data.get('item_idx_map', {})
            models.idx_user_map = model_data.get('idx_user_map', {})
            models.idx_item_map = model_data.get('idx_item_map', {})
            models.content_idx_map = model_data.get('content_idx_map', {})
            models.idx_content_map = model_data.get('idx_content_map', {})
            models.all_books = model_data.get('all_books', {})
            models.last_retrain = model_data.get('last_retrain')
            
            stats_data = model_data.get('stats', {})
            models.stats = ModelStats(**stats_data)
            
            logger.info("Hybrid models loaded successfully")
            return True
    except Exception as e:
        logger.error(f"Error loading models: {e}")
    return False


# Load cleaned books CSV
books = pd.read_csv("books/books_cleaned.csv")

# Initialize the embedding model
embedding = GoogleGenerativeAIEmbeddings(
    model="models/embedding-001",
    google_api_key=os.getenv("GOOGLE_API_KEY")
)

# Load or connect to your persisted Chroma vector store
db_books = Chroma(
    embedding_function=embedding,
    persist_directory="chroma_db"
)


# —————— Pydantic schemas ——————

class Query(BaseModel):
    text: str


class Book(BaseModel):
    isbn10: str
    title: str
    authors: str
    categories: str
    thumbnail: str
    description: str
    published_year: int
    average_rating: float
    ratings_count: int


# —————— Recommendation logic ——————

def recommend_books_logic(text: str) -> List[Book]:
    """
    1. Run a vector‐store similarity search
    2. Extract ISBN13s, filter the DataFrame
    3. Marshal into List[Book]
    """
    try:
        # # how many vectors?
        # print(f"📚 Vector count: {db_books._collection.count()}")

        # 1) vector similarity search
        docs = db_books.similarity_search(text, k=12)

        # 2) extract ISBN13 from each doc’s page_content
        isbn13s = [doc.page_content.strip().split()[0] for doc in docs]

        # 3) filter your DataFrame by those ISBN13s
        #    note: your CSV uses float-ish ISBN13, so cast
        filtered = books[books["isbn13"].isin(map(float, isbn13s))]

        # 4) build your Pydantic Book objects
        result: List[Book] = []
        for _, row in filtered.iterrows():
            result.append(Book(
                isbn10=row["isbn10"],
                title=row["title"],
                authors=row["authors"],
                categories=row["categories"],
                thumbnail=str(row["thumbnail"]) if pd.notna(row["thumbnail"]) else "",
                description=row["description"],
                published_year=int(row["published_year"]),
                average_rating=float(row["average_rating"]),
                ratings_count=int(row["ratings_count"]),
            ))
        return result

    except Exception as e:
        # bubble up as an HTTP error
        raise HTTPException(status_code=500, detail=str(e))
