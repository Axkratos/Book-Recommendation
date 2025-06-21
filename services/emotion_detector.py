
import re
import string
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer
import numpy as np

# Download required NLTK resources
try:
    nltk.data.find('vader_lexicon')
except LookupError:
    nltk.download('vader_lexicon')

class EmotionDetector:
    def __init__(self):
        self.sentiment_analyzer = SentimentIntensityAnalyzer()
        
        # Emotion keywords to help detect specific emotions
        self.emotion_keywords = {
            'anger': ['angry', 'mad', 'furious', 'annoyed', 'irritated', 'enraged', 'frustrated'],
            'disgust': ['disgusted', 'revolted', 'sickened', 'appalled', 'repulsed', 'gross'],
            'fear': ['afraid', 'scared', 'frightened', 'anxious', 'nervous', 'worried', 'terrified'],
            'joy': ['happy', 'excited', 'glad', 'pleased', 'delighted', 'content', 'thrilled', 'joyful'],
            'sadness': ['sad', 'unhappy', 'depressed', 'miserable', 'gloomy', 'melancholic', 'heartbroken'],
            'surprise': ['surprised', 'shocked', 'astonished', 'amazed', 'startled', 'unexpected']
        }
        
    def preprocess_text(self, text):
        # Convert to lowercase
        text = text.lower()
        # Remove punctuation
        text = ''.join([char for char in text if char not in string.punctuation])
        return text
    
    def detect_emotions(self, text):
        """
        Detect emotions in text and return scores for each emotion category.
        Returns a dictionary of emotion scores between 0-1
        """
        preprocessed_text = self.preprocess_text(text)
        
        # Get base sentiment
        sentiment_scores = self.sentiment_analyzer.polarity_scores(text)
        
        # Initialize emotion scores
        emotion_scores = {
            'anger': 0.0,
            'disgust': 0.0,
            'fear': 0.0,
            'joy': 0.0,
            'sadness': 0.0,
            'surprise': 0.0,
            'neutral': 0.0
        }
        
        # Use base sentiment as starting point
        if sentiment_scores['compound'] >= 0.05:
            emotion_scores['joy'] = sentiment_scores['pos'] 
        elif sentiment_scores['compound'] <= -0.05:
            # Distribute negative sentiment between anger, disgust, fear, and sadness
            emotion_scores['anger'] = sentiment_scores['neg'] * 0.25
            emotion_scores['disgust'] = sentiment_scores['neg'] * 0.25
            emotion_scores['fear'] = sentiment_scores['neg'] * 0.25
            emotion_scores['sadness'] = sentiment_scores['neg'] * 0.25
        else:
            emotion_scores['neutral'] = sentiment_scores['neu']
        
        # Adjust based on emotion keywords
        for emotion, keywords in self.emotion_keywords.items():
            for keyword in keywords:
                if keyword in preprocessed_text:
                    emotion_scores[emotion] += 0.2
        
        # Normalize to ensure all scores are between 0-1
        for emotion in emotion_scores:
            emotion_scores[emotion] = min(max(emotion_scores[emotion], 0.0), 1.0)
        
        # Ensure neutral is inverse of total emotion intensity
        total_emotion = sum(emotion_scores.values()) - emotion_scores['neutral']
        emotion_scores['neutral'] = max(0.0, min(1.0, 1.0 - (total_emotion / 6.0)))
        
        return emotion_scores