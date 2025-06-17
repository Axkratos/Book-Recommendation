from motor.motor_asyncio import AsyncIOMotorClient
from typing import Dict, List
import logging
import dotenv
from fastapi import  HTTPException
# Load environment variables from .env file
dotenv.load_dotenv()
MONGO_URI= dotenv.get_key(".env", "MONGO_URI")

DB_NAME = "bookrec"
RATINGS_COLLECTION = "ratings"
USER_COLL = "users"
BOOKS_COLLECTION = "books"

# Setup logging
logger = logging.getLogger(__name__)

# Mongo client
client = AsyncIOMotorClient(MONGO_URI)
db = client[DB_NAME]

async def load_all_books():
    """Load all books from the collection"""
    logger.info("Loading all books from collection...")
    
    try:
        cursor = db[BOOKS_COLLECTION].find({})
        books_data = []
        
        async for book in cursor:
            isbn = book.get("isbn10", "") or book.get("_id", "")
            title = book.get("title", "")
            authors = book.get("authors", "")
            year = book.get("published_year", "")
            description = book.get("description", "")
            categories = book.get("categories", "")
            
            if isbn and title:
                book_info = {
                    "isbn": str(isbn),
                    "title": str(title),
                    "author": str(authors),
                    "year": str(year) if year else "",
                    "description": str(description) if description else "",
                    "categories": str(categories) if categories else "",
                    "content": f"{title} {authors} {description} {categories}".strip()
                }
                books_data.append(book_info)
        
        logger.info(f"Loaded {len(books_data)} books from collection")
        return books_data
        
    except Exception as e:
        logger.error(f"Error loading books: {e}")
        raise Exception(f"Failed to load books from database: {str(e)}")

async def load_ratings_data():
    """Load ratings data from the collection"""
    try:
        cursor = db[RATINGS_COLLECTION].find({})
        ratings_data = []
        
        async for rating in cursor:
            ratings_data.append({
                'user_id': str(rating.get('User-ID', '')),
                'isbn10': str(rating.get('ISBN', '')),
                'rating': float(rating.get('Book-Rating', 0))
            })
        
        return ratings_data
        
    except Exception as e:
        logger.error(f"Error loading ratings: {e}")
        raise Exception(f"Failed to load ratings from database: {str(e)}")

async def get_user_ratings(user_id: str) -> Dict[str, float]:
    """Get user's ratings as a dictionary"""
    try:
        ratings = {}
        cursor = db[RATINGS_COLLECTION].find({'User-ID': user_id})
        async for rating in cursor:
            isbn = rating.get('ISBN', '')
            rating_val = rating.get('Book-Rating', 0)
            if isbn and rating_val > 0:
                ratings[isbn] = float(rating_val)
        return ratings
    except Exception as e:
        logger.error(f"Error getting user ratings: {e}")
        raise Exception(f"Failed to get user ratings: {str(e)}")
async def load_user_ratings(user_id: str) -> List[Dict[str, float]]:
    try:
        cursor = db[RATINGS_COLLECTION].find({'User-ID': user_id})
        user_ratings = []
        async for rating in cursor:
            user_ratings.append({
                'isbn10': str(rating.get('ISBN', '')),
                'rating': float(rating.get('Book-Rating', 0))
            })
        return user_ratings
    except Exception as e:
        logger.error(f"Error loading user ratings: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to load user ratings: {e}")
