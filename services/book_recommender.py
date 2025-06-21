import pandas as pd
import numpy as np
from typing import Dict, List

class BookRecommender:
    def __init__(self, csv_file_path):
        self.book_data = self._load_book_data(csv_file_path)

    def _load_book_data(self, csv_file_path):
        required_columns = ['isbn13', 'title', 'authors', 'categories', 'thumbnail',
                            'description', 'published_year', 'anger', 'disgust',
                            'fear', 'joy', 'sadness', 'surprise', 'neutral']
        try:
            df = pd.read_csv(csv_file_path)
            for col in required_columns:
                if col not in df.columns:
                    raise ValueError(f"Required column '{col}' not found in CSV data")
            df['authors'] = df['authors'].fillna('Unknown Author')
            df['categories'] = df['categories'].fillna('General')
            df['description'] = df['description'].fillna('No description available.')
            emotion_columns = ['anger', 'disgust', 'fear', 'joy', 'sadness', 'surprise', 'neutral']
            for col in emotion_columns:
                df[col] = pd.to_numeric(df[col], errors='coerce').fillna(0.0)
            return df
        except Exception as e:
            print(f"Error loading book data: {e}")
            return pd.DataFrame(columns=required_columns)

    def compute_similarity(self, user_emotions: Dict[str, float], book_emotions: Dict[str, float]) -> float:
        numerator = 0
        user_magnitude = 0
        book_magnitude = 0
        for emotion in user_emotions:
            if emotion in book_emotions:
                numerator += user_emotions[emotion] * book_emotions[emotion]
                user_magnitude += user_emotions[emotion] ** 2
                book_magnitude += book_emotions[emotion] ** 2
        if user_magnitude == 0 or book_magnitude == 0:
            return 0
        similarity = numerator / (np.sqrt(user_magnitude) * np.sqrt(book_magnitude))
        return similarity

    def get_recommendations(self, user_emotions: Dict[str, float], count: int = 5) -> List[Dict]:
        if len(self.book_data) == 0:
            return []
        similarity_scores = []
        for _, book in self.book_data.iterrows():
            book_emotions = {
                'anger': book['anger'],
                'disgust': book['disgust'],
                'fear': book['fear'],
                'joy': book['joy'],
                'sadness': book['sadness'],
                'surprise': book['surprise'],
                'neutral': book['neutral']
            }
            similarity = self.compute_similarity(user_emotions, book_emotions)
            similarity_scores.append((book, similarity))
        similarity_scores.sort(key=lambda x: x[1], reverse=True)
        recommendations = []
        for book, score in similarity_scores[:count]:
            recommendations.append({
                "title": book["title"],
                "author": book["authors"],
                "description": book["description"][:200] + "..." if len(book["description"]) > 200 else book["description"],
                "isbn10": book["isbn10"],
                "category": book["categories"],
                "thumbnail": book["thumbnail"],
                "published_year": book["published_year"],
                "average_rating": book["average_rating"],
                "ratings_count": book["ratings_count"]
            })
        return recommendations