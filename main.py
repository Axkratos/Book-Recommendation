from fastapi import FastAPI, File, UploadFile, HTTPException, WebSocket, WebSocketDisconnect
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional, Dict
import os
import tempfile
import uuid
import json
import asyncio
from datetime import datetime
from concurrent.futures import ThreadPoolExecutor

from agents.chatbot_agent import BookChatAgent
from models.schemas import ChatRequest, ChatResponse, DocumentUploadResponse, SessionInfo

app = FastAPI(
    title="Book Buddy API",
    description="AI-powered book discussion companion with real-time chat",
    version="2.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace with your frontend URL in production
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# In-memory storage (use Redis/DB in production)
sessions = {}
active_connections: Dict[str, WebSocket] = {}

# Thread pool for CPU-intensive tasks
executor = ThreadPoolExecutor(max_workers=4)

class ConnectionManager:
    def __init__(self):
        self.active_connections: Dict[str, WebSocket] = {}

    async def connect(self, websocket: WebSocket, session_id: str):
        await websocket.accept()
        self.active_connections[session_id] = websocket

    def disconnect(self, session_id: str):
        if session_id in self.active_connections:
            del self.active_connections[session_id]

    async def send_message(self, session_id: str, message: dict):
        if session_id in self.active_connections:
            try:
                await self.active_connections[session_id].send_text(json.dumps(message))
            except:
                # Connection closed, remove it
                self.disconnect(session_id)

manager = ConnectionManager()

class SessionManager:
    @staticmethod
    def create_session() -> str:
        session_id = str(uuid.uuid4())
        sessions[session_id] = {
            "agent": BookChatAgent(),
            "created_at": datetime.now(),
            "messages": [],
            "document_info": None,
            "processing": False
        }
        return session_id
    
    @staticmethod
    def get_session(session_id: str):
        if session_id not in sessions:
            raise HTTPException(status_code=404, detail="Session not found")
        return sessions[session_id]
    
    @staticmethod
    def delete_session(session_id: str):
        if session_id in sessions:
            # Clean up WebSocket connection
            manager.disconnect(session_id)
            del sessions[session_id]

# WebSocket endpoint for real-time chat
@app.websocket("/ws/{session_id}")
async def websocket_endpoint(websocket: WebSocket, session_id: str):
    try:
        # Verify session exists
        session = SessionManager.get_session(session_id)
        await manager.connect(websocket, session_id)
        
        # Send connection confirmation
        await manager.send_message(session_id, {
            "type": "connection",
            "status": "connected",
            "message": "Connected to Book Buddy! Upload a book to start chatting."
        })
        
        while True:
            # Receive message from client
            data = await websocket.receive_text()
            message_data = json.loads(data)
            
            if message_data["type"] == "chat":
                user_message = message_data["message"]
                
                # Send typing indicator
                await manager.send_message(session_id, {
                    "type": "typing",
                    "status": True
                })
                
                # Process message in thread pool to avoid blocking
                loop = asyncio.get_event_loop()
                response = await loop.run_in_executor(
                    executor, 
                    session["agent"].get_response, 
                    user_message
                )
                
                # Store messages
                timestamp = datetime.now().isoformat()
                session["messages"].extend([
                    {"role": "user", "content": user_message, "timestamp": timestamp},
                    {"role": "assistant", "content": response, "timestamp": timestamp}
                ])
                
                # Send response
                await manager.send_message(session_id, {
                    "type": "message",
                    "role": "assistant",
                    "content": response,
                    "timestamp": timestamp
                })
                
    except WebSocketDisconnect:
        manager.disconnect(session_id)
    except Exception as e:
        await manager.send_message(session_id, {
            "type": "error",
            "message": f"An error occurred: {str(e)}"
        })

@app.post("/api/sessions", response_model=SessionInfo)
async def create_session():
    """Create a new chat session"""
    session_id = SessionManager.create_session()
    return SessionInfo(session_id=session_id, message="Session created successfully")

@app.delete("/api/sessions/{session_id}")
async def delete_session(session_id: str):
    """Delete a chat session"""
    SessionManager.delete_session(session_id)
    return {"message": "Session deleted successfully"}

@app.post("/api/sessions/{session_id}/upload", response_model=DocumentUploadResponse)
async def upload_document(
    session_id: str,
    file: UploadFile = File(...)
):
    """Upload a PDF document to a session"""
    if not file.filename.lower().endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are allowed")
    
    session = SessionManager.get_session(session_id)
    
    # Prevent multiple uploads at once
    if session["processing"]:
        raise HTTPException(status_code=429, detail="Document is already being processed")
    
    session["processing"] = True
    
    try:
        # Notify WebSocket clients about upload start
        await manager.send_message(session_id, {
            "type": "upload_status",
            "status": "processing",
            "message": f"Processing {file.filename}..."
        })
        
        # Save uploaded file temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as tmp_file:
            content = await file.read()
            tmp_file.write(content)
            tmp_file_path = tmp_file.name
        
        # Process document in thread pool
        loop = asyncio.get_event_loop()
        success = await loop.run_in_executor(
            executor,
            session["agent"].load_document,
            tmp_file_path,
            file.filename
        )
        
        # Clean up temp file
        os.unlink(tmp_file_path)
        
        if success:
            session["document_info"] = {
                "filename": file.filename,
                "uploaded_at": datetime.now().isoformat()
            }
            
            # Notify WebSocket clients about successful upload
            await manager.send_message(session_id, {
                "type": "upload_status",
                "status": "success",
                "message": f"Successfully processed {file.filename}! Ask me anything about the book."
            })
            
            return DocumentUploadResponse(
                success=True,
                filename=file.filename,
                message="Document processed successfully"
            )
        else:
            await manager.send_message(session_id, {
                "type": "upload_status",
                "status": "error",
                "message": "Failed to process document"
            })
            raise HTTPException(status_code=500, detail="Failed to process document")
            
    except Exception as e:
        if 'tmp_file_path' in locals():
            os.unlink(tmp_file_path)
        
        await manager.send_message(session_id, {
            "type": "upload_status",
            "status": "error",
            "message": f"Error processing document: {str(e)}"
        })
        raise HTTPException(status_code=500, detail=f"Error processing document: {str(e)}")
    
    finally:
        session["processing"] = False

@app.post("/api/sessions/{session_id}/chat", response_model=ChatResponse)
async def chat(session_id: str, request: ChatRequest):
    """REST endpoint for chat (fallback for non-WebSocket clients)"""
    session = SessionManager.get_session(session_id)
    
    try:
        # Process in thread pool
        loop = asyncio.get_event_loop()
        response = await loop.run_in_executor(
            executor,
            session["agent"].get_response,
            request.message
        )
        
        # Store messages
        timestamp = datetime.now().isoformat()
        session["messages"].extend([
            {"role": "user", "content": request.message, "timestamp": timestamp},
            {"role": "assistant", "content": response, "timestamp": timestamp}
        ])
        
        return ChatResponse(
            response=response,
            success=True
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error generating response: {str(e)}")

@app.get("/api/sessions/{session_id}/messages")
async def get_messages(session_id: str):
    """Get chat history for a session"""
    session = SessionManager.get_session(session_id)
    return {
        "messages": session["messages"],
        "document_info": session.get("document_info")
    }

@app.get("/api/sessions/{session_id}/status")
async def get_session_status(session_id: str):
    """Get session status"""
    session = SessionManager.get_session(session_id)
    return {
        "session_id": session_id,
        "created_at": session["created_at"].isoformat(),
        "document_loaded": session["agent"].document_loaded,
        "document_info": session.get("document_info"),
        "message_count": len(session["messages"]),
        "processing": session["processing"]
    }

@app.get("/api/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "timestamp": datetime.now().isoformat(),
        "active_sessions": len(sessions),
        "active_connections": len(manager.active_connections)
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app, 
        host="0.0.0.0", 
        port=8000,
        workers=1,  # Use 1 worker for WebSocket support
        loop="asyncio"
    )