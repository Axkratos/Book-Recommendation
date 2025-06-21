
# from fastapi import FastAPI, File, UploadFile, HTTPException, WebSocket, WebSocketDisconnect
# from fastapi.middleware.cors import CORSMiddleware
# from pydantic import BaseModel
# from typing import List, Optional, Dict
# import os
# import tempfile
# import uuid
# import json
# import pandas as pd
# import asyncio
# from datetime import datetime
# from concurrent.futures import ThreadPoolExecutor

# # Import BookPal dependencies
# from agents.chatbot_agent import BookChatAgent
# # Import EmotionRead dependencies
# from services.emotion_detector import EmotionDetector
# from services.book_recommender import BookRecommender
# from models.schemas import ChatRequest, ChatResponse, DocumentUploadResponse, SessionInfo, EmotionProfile, BookRecommendation

# # Initialize FastAPI app
# app = FastAPI(
#     title="Book Buddy & EmotionRead API",
#     description="Combined API for AI-powered book discussion and emotion-based recommendation",
#     version="2.0.0"
# )

# # CORS middleware
# app.add_middleware(
#     CORSMiddleware,
#     allow_origins=["*"],
#     allow_credentials=True,
#     allow_methods=["*"],
#     allow_headers=["*"],
# )

# #################################################
# # BookPal App - Original code kept as-is
# #################################################

# # In-memory storage for BookPal (use Redis/DB in production)
# sessions = {}
# active_connections: Dict[str, WebSocket] = {}

# # Thread pool for BookPal CPU-intensive tasks
# executor = ThreadPoolExecutor(max_workers=4)

# class ConnectionManager:
#     def __init__(self):
#         self.active_connections: Dict[str, WebSocket] = {}

#     async def connect(self, websocket: WebSocket, session_id: str):
#         await websocket.accept()
#         self.active_connections[session_id] = websocket

#     def disconnect(self, session_id: str):
#         if session_id in self.active_connections:
#             del self.active_connections[session_id]

#     async def send_message(self, session_id: str, message: dict):
#         if session_id in self.active_connections:
#             try:
#                 await self.active_connections[session_id].send_text(json.dumps(message))
#             except:
#                 # Connection closed, remove it
#                 self.disconnect(session_id)

# manager = ConnectionManager()

# class SessionManager:
#     @staticmethod
#     def create_session() -> str:
#         session_id = str(uuid.uuid4())
#         sessions[session_id] = {
#             "agent": BookChatAgent(),
#             "created_at": datetime.now(),
#             "messages": [],
#             "document_info": None,
#             "processing": False
#         }
#         return session_id
    
#     @staticmethod
#     def get_session(session_id: str):
#         if session_id not in sessions:
#             raise HTTPException(status_code=404, detail="Session not found")
#         return sessions[session_id]
    
#     @staticmethod
#     def delete_session(session_id: str):
#         if session_id in sessions:
#             # Clean up WebSocket connection
#             manager.disconnect(session_id)
#             del sessions[session_id]

# # WebSocket endpoint for real-time chat
# @app.websocket("/ws/{session_id}")
# async def websocket_endpoint(websocket: WebSocket, session_id: str):
#     try:
#         # Verify session exists
#         session = SessionManager.get_session(session_id)
#         await manager.connect(websocket, session_id)
        
#         # Send connection confirmation
#         await manager.send_message(session_id, {
#             "type": "connection",
#             "status": "connected",
#             "message": "Connected to Book Buddy! Upload a book to start chatting."
#         })
        
#         while True:
#             # Receive message from client
#             data = await websocket.receive_text()
#             message_data = json.loads(data)
            
#             if message_data["type"] == "chat":
#                 user_message = message_data["message"]
                
#                 # Send typing indicator
#                 await manager.send_message(session_id, {
#                     "type": "typing",
#                     "status": True
#                 })
                
#                 # Process message in thread pool to avoid blocking
#                 loop = asyncio.get_event_loop()
#                 response = await loop.run_in_executor(
#                     executor, 
#                     session["agent"].get_response, 
#                     user_message
#                 )
                
#                 # Store messages
#                 timestamp = datetime.now().isoformat()
#                 session["messages"].extend([
#                     {"role": "user", "content": user_message, "timestamp": timestamp},
#                     {"role": "assistant", "content": response, "timestamp": timestamp}
#                 ])
                
#                 # Send response
#                 await manager.send_message(session_id, {
#                     "type": "message",
#                     "role": "assistant",
#                     "content": response,
#                     "timestamp": timestamp
#                 })
                
#     except WebSocketDisconnect:
#         manager.disconnect(session_id)
#     except Exception as e:
#         await manager.send_message(session_id, {
#             "type": "error",
#             "message": f"An error occurred: {str(e)}"
#         })

# @app.post("/api/sessions", response_model=SessionInfo)
# async def create_session():
#     """Create a new chat session"""
#     session_id = SessionManager.create_session()
#     return SessionInfo(session_id=session_id, message="Session created successfully")

# @app.delete("/api/sessions/{session_id}")
# async def delete_session(session_id: str):
#     """Delete a chat session"""
#     SessionManager.delete_session(session_id)
#     return {"message": "Session deleted successfully"}

# @app.post("/api/sessions/{session_id}/upload", response_model=DocumentUploadResponse)
# async def upload_document(
#     session_id: str,
#     file: UploadFile = File(...)
# ):
#     """Upload a PDF document to a session"""
#     if not file.filename.lower().endswith('.pdf'):
#         raise HTTPException(status_code=400, detail="Only PDF files are allowed")
    
#     session = SessionManager.get_session(session_id)
    
#     # Prevent multiple uploads at once
#     if session["processing"]:
#         raise HTTPException(status_code=429, detail="Document is already being processed")
    
#     session["processing"] = True
    
#     try:
#         # Notify WebSocket clients about upload start
#         await manager.send_message(session_id, {
#             "type": "upload_status",
#             "status": "processing",
#             "message": f"Processing {file.filename}..."
#         })
        
#         # Save uploaded file temporarily
#         with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as tmp_file:
#             content = await file.read()
#             tmp_file.write(content)
#             tmp_file_path = tmp_file.name
        
#         # Process document in thread pool
#         loop = asyncio.get_event_loop()
#         success = await loop.run_in_executor(
#             executor,
#             session["agent"].load_document,
#             tmp_file_path,
#             file.filename
#         )
        
#         # Clean up temp file
#         os.unlink(tmp_file_path)
        
#         if success:
#             session["document_info"] = {
#                 "filename": file.filename,
#                 "uploaded_at": datetime.now().isoformat()
#             }
            
#             # Notify WebSocket clients about successful upload
#             await manager.send_message(session_id, {
#                 "type": "upload_status",
#                 "status": "success",
#                 "message": f"Successfully processed {file.filename}! Ask me anything about the book."
#             })
            
#             return DocumentUploadResponse(
#                 success=True,
#                 filename=file.filename,
#                 message="Document processed successfully"
#             )
#         else:
#             await manager.send_message(session_id, {
#                 "type": "upload_status",
#                 "status": "error",
#                 "message": "Failed to process document"
#             })
#             raise HTTPException(status_code=500, detail="Failed to process document")
            
#     except Exception as e:
#         if 'tmp_file_path' in locals():
#             os.unlink(tmp_file_path)
        
#         await manager.send_message(session_id, {
#             "type": "upload_status",
#             "status": "error",
#             "message": f"Error processing document: {str(e)}"
#         })
#         raise HTTPException(status_code=500, detail=f"Error processing document: {str(e)}")
    
#     finally:
#         session["processing"] = False

# @app.post("/api/sessions/{session_id}/chat", response_model=ChatResponse)
# async def chat(session_id: str, request: ChatRequest):
#     """REST endpoint for chat (fallback for non-WebSocket clients)"""
#     session = SessionManager.get_session(session_id)
    
#     try:
#         # Process in thread pool
#         loop = asyncio.get_event_loop()
#         response = await loop.run_in_executor(
#             executor,
#             session["agent"].get_response,
#             request.message
#         )
        
#         # Store messages
#         timestamp = datetime.now().isoformat()
#         session["messages"].extend([
#             {"role": "user", "content": request.message, "timestamp": timestamp},
#             {"role": "assistant", "content": response, "timestamp": timestamp}
#         ])
        
#         return ChatResponse(
#             response=response,
#             success=True
#         )
        
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Error generating response: {str(e)}")

# @app.get("/api/sessions/{session_id}/messages")
# async def get_messages(session_id: str):
#     """Get chat history for a session"""
#     session = SessionManager.get_session(session_id)
#     return {
#         "messages": session["messages"],
#         "document_info": session.get("document_info")
#     }

# @app.get("/api/sessions/{session_id}/status")
# async def get_session_status(session_id: str):
#     """Get session status"""
#     session = SessionManager.get_session(session_id)
#     return {
#         "session_id": session_id,
#         "created_at": session["created_at"].isoformat(),
#         "document_loaded": session["agent"].document_loaded,
#         "document_info": session.get("document_info"),
#         "message_count": len(session["messages"]),
#         "processing": session["processing"]
#     }

# @app.get("/api/health")
# async def health_check():
#     """Health check endpoint"""
#     return {
#         "status": "healthy",
#         "timestamp": datetime.now().isoformat(),
#         "active_sessions": len(sessions),
#         "active_connections": len(manager.active_connections)
#     }

# #################################################
# # EmotionRead App - With routes prefixed to avoid conflicts
# #################################################

# # Load book data from CSV
# DATA_PATH = "./books_with_emotions.csv"  # Update this to your CSV file path

# # In-memory storage for EmotionRead (use Redis/DB in production)
# emotion_sessions = {}
# emotion_connections: Dict[str, WebSocket] = {}

# # Thread pool for EmotionRead CPU-intensive tasks
# emotion_executor = ThreadPoolExecutor(max_workers=4)

# class EmotionConnectionManager:
#     def __init__(self):
#         self.active_connections: Dict[str, WebSocket] = {}

#     async def connect(self, websocket: WebSocket, session_id: str):
#         await websocket.accept()
#         self.active_connections[session_id] = websocket

#     def disconnect(self, session_id: str):
#         if session_id in self.active_connections:
#             del self.active_connections[session_id]

#     async def send_message(self, session_id: str, message: dict):
#         if session_id in self.active_connections:
#             try:
#                 await self.active_connections[session_id].send_text(json.dumps(message))
#             except:
#                 # Connection closed, remove it
#                 self.disconnect(session_id)

# emotion_manager = EmotionConnectionManager()

# class EmotionChatAgent:
#     def __init__(self):
#         self.emotion_detector = EmotionDetector()
#         self.book_recommender = BookRecommender(DATA_PATH)
#         self.conversation_history = []
#         self.emotion_profile = {
#             "anger": 0.0,
#             "disgust": 0.0,
#             "fear": 0.0,
#             "joy": 0.0,
#             "sadness": 0.0,
#             "surprise": 0.0,
#             "neutral": 0.5  # Default to somewhat neutral
#         }
#         self.questions = [
#             "How has your day been going so far?",
#             "What type of books do you typically enjoy reading?",
#             "How are you feeling right now?",
#             "What's something that made you smile recently?",
#             "Is there anything that's been bothering you lately?",
#             "What kind of mood would you like a book to put you in?",
#             "Do you prefer books that match your current mood or ones that might change it?"
#         ]
#         self.question_index = 0
#         self.recommendations_provided = False
    
#     def get_next_question(self):
#         if self.question_index < len(self.questions):
#             question = self.questions[self.question_index]
#             self.question_index += 1
#             return question
#         return None
    
#     def update_emotion_profile(self, message):
#         # Detect emotions in the user message
#         emotions = self.emotion_detector.detect_emotions(message)
        
#         # Update the emotion profile (with some smoothing)
#         for emotion, score in emotions.items():
#             self.emotion_profile[emotion] = 0.7 * self.emotion_profile[emotion] + 0.3 * score
        
#         return self.emotion_profile
    
#     def get_response(self, message):
#         # Add message to history
#         self.conversation_history.append({"role": "user", "content": message})
        
#         # Update emotions based on message
#         self.update_emotion_profile(message)
        
#         # Decide on response
#         if len(self.conversation_history) < 5 and not self.recommendations_provided:
#             # In questioning phase
#             next_question = self.get_next_question()
#             if next_question:
#                 response = f"Thanks for sharing. {next_question}"
#             else:
#                 # Enough questions asked, provide recommendations
#                 recommendations = self.book_recommender.get_recommendations(self.emotion_profile)
#                 response = self.format_recommendations(recommendations)
#                 self.recommendations_provided = True
#         elif not self.recommendations_provided:
#             # Enough conversation to make recommendations
#             recommendations = self.book_recommender.get_recommendations(self.emotion_profile)
#             response = self.format_recommendations(recommendations)
#             self.recommendations_provided = True
#         else:
#             # Follow-up after recommendations
#             response = "Would you like more book recommendations or would you prefer books with a different emotional tone? You can tell me more about what you're looking for."
#             # Reset for new recommendations
#             self.recommendations_provided = False
        
#         # Add response to history
#         self.conversation_history.append({"role": "assistant", "content": response})
#         return response
    
#     def format_recommendations(self, recommendations):
#         if not recommendations:
#             return "I couldn't find any books that match your emotional profile. Could you tell me more about what kind of books you enjoy?"
        
#         response = "Based on our conversation, here are some book recommendations that might resonate with you:\n\n"
        
#         for i, book in enumerate(recommendations[:5], 1):
#             response += f"{i}. **{book['title']}** by {book['authors']}\n"
#             response += f"   {book['description'][:150]}...\n\n"
        
#         response += "Would any of these interest you? I can provide more details or different recommendations."
#         return response
    
#     def get_emotion_profile(self):
#         return self.emotion_profile
    
#     def get_dominant_emotion(self):
#         return max(self.emotion_profile.items(), key=lambda x: x[1])[0]

# class EmotionSessionManager:
#     @staticmethod
#     def create_session() -> str:
#         session_id = str(uuid.uuid4())
#         emotion_sessions[session_id] = {
#             "agent": EmotionChatAgent(),
#             "created_at": datetime.now(),
#             "messages": [],
#             "processing": False
#         }
#         return session_id
    
#     @staticmethod
#     def get_session(session_id: str):
#         if session_id not in emotion_sessions:
#             raise HTTPException(status_code=404, detail="Session not found")
#         return emotion_sessions[session_id]
    
#     @staticmethod
#     def delete_session(session_id: str):
#         if session_id in emotion_sessions:
#             emotion_manager.disconnect(session_id)
#             del emotion_sessions[session_id]

# # EmotionRead WebSocket endpoint for real-time chat with emotion analysis
# @app.websocket("/emotion/ws/{session_id}")
# async def emotion_websocket_endpoint(websocket: WebSocket, session_id: str):
#     try:
#         # Verify session exists
#         session = EmotionSessionManager.get_session(session_id)
#         await emotion_manager.connect(websocket, session_id)
        
#         # Send connection confirmation
#         await emotion_manager.send_message(session_id, {
#             "type": "connection",
#             "status": "connected",
#             "message": "Connected to EmotionRead! Let's chat about books and how you're feeling."
#         })
        
#         # Send first question to start conversation
#         first_question = "Hi there! I'm your EmotionRead assistant. I'll recommend books based on our conversation. " + \
#                         session["agent"].get_next_question()
        
#         timestamp = datetime.now().isoformat()
#         session["messages"].append({"role": "assistant", "content": first_question, "timestamp": timestamp})
        
#         await emotion_manager.send_message(session_id, {
#             "type": "message",
#             "role": "assistant",
#             "content": first_question,
#             "timestamp": timestamp
#         })
        
#         while True:
#             # Receive message from client
#             data = await websocket.receive_text()
#             message_data = json.loads(data)
            
#             if message_data["type"] == "chat":
#                 user_message = message_data["message"]
                
#                 # Send typing indicator
#                 await emotion_manager.send_message(session_id, {
#                     "type": "typing",
#                     "status": True
#                 })
                
#                 # Process message in thread pool to avoid blocking
#                 loop = asyncio.get_event_loop()
#                 response = await loop.run_in_executor(
#                     emotion_executor, 
#                     session["agent"].get_response, 
#                     user_message
#                 )
                
#                 # Store messages
#                 timestamp = datetime.now().isoformat()
#                 session["messages"].extend([
#                     {"role": "user", "content": user_message, "timestamp": timestamp},
#                     {"role": "assistant", "content": response, "timestamp": timestamp}
#                 ])
                
#                 # Send response
#                 await emotion_manager.send_message(session_id, {
#                     "type": "message",
#                     "role": "assistant",
#                     "content": response,
#                     "timestamp": timestamp
#                 })
                
#                 # Send emotion update
#                 emotion_profile = session["agent"].get_emotion_profile()
#                 await emotion_manager.send_message(session_id, {
#                     "type": "emotion_update",
#                     "emotions": emotion_profile,
#                     "dominant_emotion": session["agent"].get_dominant_emotion()
#                 })
                
#     except WebSocketDisconnect:
#         emotion_manager.disconnect(session_id)
#     except Exception as e:
#         await emotion_manager.send_message(session_id, {
#             "type": "error",
#             "message": f"An error occurred: {str(e)}"
#         })

# @app.post("/emotion/api/sessions", response_model=SessionInfo)
# async def emotion_create_session():
#     """Create a new emotion analysis chat session"""
#     session_id = EmotionSessionManager.create_session()
#     return SessionInfo(session_id=session_id, message="Emotion session created successfully")

# @app.delete("/emotion/api/sessions/{session_id}")
# async def emotion_delete_session(session_id: str):
#     """Delete an emotion analysis chat session"""
#     EmotionSessionManager.delete_session(session_id)
#     return {"message": "Emotion session deleted successfully"}

# @app.post("/emotion/api/sessions/{session_id}/chat", response_model=ChatResponse)
# async def emotion_chat(session_id: str, request: ChatRequest):
#     """REST endpoint for emotion analysis chat"""
#     session = EmotionSessionManager.get_session(session_id)
    
#     try:
#         # Process in thread pool
#         loop = asyncio.get_event_loop()
#         response = await loop.run_in_executor(
#             emotion_executor,
#             session["agent"].get_response,
#             request.message
#         )
        
#         # Store messages
#         timestamp = datetime.now().isoformat()
#         session["messages"].extend([
#             {"role": "user", "content": request.message, "timestamp": timestamp},
#             {"role": "assistant", "content": response, "timestamp": timestamp}
#         ])
        
#         # Get emotions
#         emotion_profile = session["agent"].get_emotion_profile()
#         dominant_emotion = session["agent"].get_dominant_emotion()
        
#         return ChatResponse(
#             response=response,
#             success=True,
#             emotions=emotion_profile,
#             dominant_emotion=dominant_emotion
#         )
        
#     except Exception as e:
#         raise HTTPException(status_code=500, detail=f"Error generating response: {str(e)}")

# @app.get("/emotion/api/sessions/{session_id}/emotions")
# async def get_emotions(session_id: str):
#     """Get emotional profile for a session"""
#     session = EmotionSessionManager.get_session(session_id)
#     emotion_profile = session["agent"].get_emotion_profile()
#     dominant_emotion = session["agent"].get_dominant_emotion()
#     return {
#         "emotions": emotion_profile,
#         "dominant_emotion": dominant_emotion
#     }

# @app.get("/emotion/api/sessions/{session_id}/recommendations")
# async def get_recommendations(session_id: str, count: int = 5):
#     """Get book recommendations based on emotional profile"""
#     session = EmotionSessionManager.get_session(session_id)
#     emotion_profile = session["agent"].get_emotion_profile()
#     recommendations = session["agent"].book_recommender.get_recommendations(emotion_profile, count)
    
#     return {
#         "recommendations": recommendations,
#         "emotions": emotion_profile
#     }

# @app.get("/emotion/api/sessions/{session_id}/messages")
# async def emotion_get_messages(session_id: str):
#     """Get chat history for an emotion analysis session"""
#     session = EmotionSessionManager.get_session(session_id)
#     return {
#         "messages": session["messages"]
#     }

# @app.get("/emotion/api/sessions/{session_id}/status")
# async def emotion_get_session_status(session_id: str):
#     """Get session status for an emotion analysis session"""
#     session = EmotionSessionManager.get_session(session_id)
#     return {
#         "session_id": session_id,
#         "created_at": session["created_at"].isoformat(),
#         "message_count": len(session["messages"]),
#         "processing": session["processing"],
#         "emotions": session["agent"].get_emotion_profile(),
#         "dominant_emotion": session["agent"].get_dominant_emotion()
#     }

# @app.get("/emotion/api/health")
# async def emotion_health_check():
#     """Health check endpoint for emotion analysis service"""
#     return {
#         "status": "healthy",
#         "timestamp": datetime.now().isoformat(),
#         "active_sessions": len(emotion_sessions),
#         "active_connections": len(emotion_manager.active_connections)
#     }

# if __name__ == "__main__":
#     import uvicorn
#     uvicorn.run(
#         app, 
#         host="0.0.0.0", 
#         port=8000,
#         workers=1,  # Use 1 worker for WebSocket support
#         loop="asyncio"
#     )