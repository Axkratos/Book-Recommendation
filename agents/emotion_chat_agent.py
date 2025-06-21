import os
import asyncio
import json
from services.gemini_emotion_detector import GeminiEmotionDetector
from services.book_recommender import BookRecommender
from typing import Dict, List, Any
import google.generativeai as genai
from datetime import datetime

class EmotionChatAgent:
    def __init__(self, data_path="./books_with_emotions.csv"):
        api_key = os.getenv("GOOGLE_API_KEY")
        if not api_key:
            raise ValueError("GOOGLE_API_KEY environment variable is required")

        genai.configure(api_key=api_key)
        self.chat_model = genai.GenerativeModel('gemini-2.0-flash')
        self.chat = self.chat_model.start_chat(history=[])
        self.emotion_detector = GeminiEmotionDetector(api_key)
        self.book_recommender = BookRecommender(data_path)
        self.conversation_history = []
        self.emotion_profile = {e: 0.0 for e in self.emotion_detector.emotion_categories}
        self.emotion_profile['neutral'] = 0.5

        self.questions_asked = 0
        self.max_questions = 4  # Exactly 4 questions as requested
        self.recommendations_provided = False
        self.user_preferences = {}
        self.state = "init"

        self.intro_message = (
            "Hi Axkratos! I'm your book recommendation assistant. I'll help you find books based on "
            "your mood and preferences. How are you feeling today?"
        )
        
        # Exactly 4 questions for the conversation
        self.conversation_questions = [
            "What types of books or genres have you enjoyed in the past?",
            "Are you looking for something that matches your current mood, or something different?",
            "Is there a specific theme or topic you're interested in exploring?",
            "Do you prefer light reads or something more thought-provoking and deep?"
        ]

    async def update_emotion_profile(self, message: str) -> Dict[str, float]:
        current_emotions = await self.emotion_detector.detect_emotions(message)
        for emotion, score in current_emotions.items():
            self.emotion_profile[emotion] = 0.7 * self.emotion_profile.get(emotion, 0.0) + 0.3 * score
        return self.emotion_profile

    def get_next_question(self) -> str:
        if self.questions_asked < len(self.conversation_questions):
            question = self.conversation_questions[self.questions_asked]
            self.questions_asked += 1
            return question
        return None

    async def get_response(self, message: str) -> str:
        """Process user message and return a response string"""
        self.conversation_history.append({"role": "user", "content": message})

        # First message is always intro
        if len(self.conversation_history) == 1 and self.state == "init":
            self.state = "chatting"
            self.questions_asked = 0
            self.recommendations_provided = False
            return self.intro_message

        # Update emotion profile using Gemini
        await self.update_emotion_profile(message)

        # If we've already provided recommendations, return follow-up
        if self.recommendations_provided:
            prompt = (
                f"The user said: \"{message}\" after I provided book recommendations.\n"
                "Respond helpfully addressing their feedback on the recommendations."
            )
            return await self._generate_response(prompt)

        # Still in questioning phase
        if self.questions_asked < self.max_questions:
            next_question = self.get_next_question()
            if next_question:
                prompt = (
                    f"The user said: \"{message}\"\n"
                    f"Respond empathetically in a friendly way. Then naturally ask this question: \"{next_question}\"\n"
                    "Keep your response concise, warm, and under 100 words."
                )
                response = await self._generate_response(prompt)
                return response

        # After exactly 4 questions, provide JSON recommendations as a STRING
        if self.questions_asked >= self.max_questions and not self.recommendations_provided:
            self.recommendations_provided = True
            json_data = await self._get_json_recommendations()
            # Convert the JSON object to a properly formatted string
            return json.dumps(json_data, indent=2)

        # Fallback (shouldn't reach here in normal flow)
        return "I'm here to help! Could you tell me more about what you're looking for in a book?"

    async def _generate_response(self, prompt: str) -> str:
        try:
            response = await asyncio.to_thread(lambda: self.chat.send_message(prompt).text)
            return response
        except Exception as e:
            print(f"Error generating response: {e}")
            return (
                "I'd love to know more about what you enjoy reading. Could you share more details?"
            )

    async def _get_json_recommendations(self) -> Dict:
        """Generate recommendations in JSON format"""
        insights = await self.emotion_detector.get_conversation_insights()
        self.user_preferences = insights
        recommendations = self.book_recommender.get_recommendations(self.emotion_profile, count=5)
        
        # Current date and time in the requested format
        current_time = datetime.utcnow().strftime("%Y-%m-%d %H:%M:%S")
        
        # Format recommendations as JSON
        response_data = {
            "timestamp": current_time,
            "user": "Axkratos",  # Fixed username
            "emotions": self.emotion_profile,
            "dominant_emotion": self.get_dominant_emotion(),
            "user_interests": insights.get("interests", []),
            "user_personality": insights.get("personality", "unknown"),
            "recommendations": []
        }
        
        for book in recommendations[:5]:
            response_data["recommendations"].append({
                "title": book["title"],
                "author": book["authors"],
                "description": book["description"][:200] + "..." if len(book["description"]) > 200 else book["description"],
                "isbn10": book["isbn10"],
                "category": book["categories"],
                "thumbnail": book["thumbnail"],
                "published_year": book["published_year"],
                "average_rating": book["average_rating"],
                "ratings_count": book["ratings_count"],
                "similarity_score": round(book["similarity_score"], 2)
            })
            
        return response_data

    def get_emotion_profile(self) -> Dict[str, float]:
        return self.emotion_profile

    def get_dominant_emotion(self) -> str:
        non_neutral = [(e, s) for e, s in self.emotion_profile.items() if e != 'neutral']
        dom = max(non_neutral, key=lambda x: x[1], default=('neutral', 0.0))
        return dom[0] if dom[1] > 0.25 else 'neutral'