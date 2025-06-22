import os
import google.generativeai as genai
import asyncio
import json
import re
from typing import Dict, Any, List, Optional

class GeminiEmotionDetector:
    def __init__(self, api_key=None):
        if api_key is None:
            api_key = os.getenv("GOOGLE_API_KEY")
            if not api_key:
                raise ValueError("GOOGLE_API_KEY not found. Please set the environment variable.")

        genai.configure(api_key=api_key)
        self.model = genai.GenerativeModel('gemini-2.0-flash')
        self.emotion_categories = ['anger', 'disgust', 'fear', 'joy', 'sadness', 'surprise', 'neutral']
        self.conversation_history: List[Dict[str, str]] = []

    async def detect_emotions(self, text: str) -> Dict[str, float]:
        self.conversation_history.append({"role": "user", "content": text})
        prompt = (
            "Analyze the following user's message for emotional content. "
            "Return a JSON object with these keys (anger, disgust, fear, joy, sadness, surprise, neutral) "
            "and values (between 0.0 and 1.0). Only return the JSON. "
            f'Message: "{text}"'
        )
        try:
            response_text = await asyncio.to_thread(lambda: self.model.generate_content(prompt).text)
            # print("Gemini response:", repr(response_text))  # Debugging aid
            json_match = re.search(r'({[\s\S]*?})', response_text)
            if json_match:
                emotion_scores = json.loads(json_match.group(1))
                # Ensure all required emotions are present and in [0,1]
                for emotion in self.emotion_categories:
                    emotion_scores[emotion] = min(max(float(emotion_scores.get(emotion, 0.0)), 0.0), 1.0)
                return emotion_scores
            else:
                print("No JSON found in response!")
                return self._default_emotion_scores()
        except Exception as e:
            print(f"Error in Gemini emotion detection: {e}")
            return self._default_emotion_scores()

    def _default_emotion_scores(self) -> Dict[str, float]:
        return {e: 0.0 for e in self.emotion_categories[:-1]} | {'neutral': 0.8}

    async def get_conversation_insights(self) -> Dict[str, Any]:
        if len(self.conversation_history) < 2:
            return {"interests": [], "preferences": [], "personality": "unknown"}

        history_text = "\n".join([msg["content"] for msg in self.conversation_history])
        prompt = (
            "Given the conversation history below, analyze:\n"
            "1. What topics or genres the person might be interested in\n"
            "2. Any book preferences they've expressed\n"
            "3. Key personality traits that might influence book preferences\n\n"
            f"Conversation history:\n{history_text}\n"
            "Respond ONLY with a JSON object in this format:\n"
            '{ "interests": ["interest1", "interest2"], "preferences": ["preference1", "preference2"], "personality": "brief personality insight" }'
        )
        try:
            response_text = await asyncio.to_thread(lambda: self.model.generate_content(prompt).text)
            json_match = re.search(r'({[\s\S]*?})', response_text)
            if json_match:
                return json.loads(json_match.group(1))
            else:
                return {"interests": [], "preferences": [], "personality": "unknown"}
        except Exception as e:
            print(f"Error getting conversation insights: {e}")
            return {"interests": [], "preferences": [], "personality": "unknown"}