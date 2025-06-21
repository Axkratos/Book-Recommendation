from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=2000, description="User message")
    context: Optional[Dict[str, Any]] = Field(None, description="Additional context")

class ChatResponse(BaseModel):
    response: str = Field(..., description="AI response")
    success: bool = Field(True, description="Success status")
    error: Optional[str] = Field(None, description="Error message if any")
    timestamp: Optional[str] = Field(None, description="Response timestamp")
    sources: Optional[List[str]] = Field(None, description="Source references")

class DocumentUploadResponse(BaseModel):
    success: bool = Field(..., description="Upload success status")
    filename: str = Field(..., description="Uploaded filename")
    message: str = Field(..., description="Status message")
    file_size: Optional[int] = Field(None, description="File size in bytes")
    pages_processed: Optional[int] = Field(None, description="Number of pages processed")
    processing_time: Optional[float] = Field(None, description="Processing time in seconds")

class SessionInfo(BaseModel):
    session_id: str = Field(..., description="Unique session identifier")
    message: str = Field(..., description="Status message")
    created_at: Optional[str] = Field(None, description="Session creation timestamp")

class SessionStatus(BaseModel):
    session_id: str = Field(..., description="Session identifier")
    created_at: str = Field(..., description="Session creation timestamp")
    document_loaded: bool = Field(False, description="Whether document is loaded")
    document_info: Optional[Dict[str, Any]] = Field(None, description="Document information")
    message_count: int = Field(0, description="Number of messages in session")
    processing: bool = Field(False, description="Whether session is processing")
    last_activity: Optional[str] = Field(None, description="Last activity timestamp")

class ChatMessage(BaseModel):
    role: str = Field(..., description="Message role (user, assistant, system)")
    content: str = Field(..., description="Message content")
    timestamp: str = Field(..., description="Message timestamp")
    metadata: Optional[Dict[str, Any]] = Field(None, description="Additional metadata")

class ChatHistory(BaseModel):
    messages: List[ChatMessage] = Field([], description="List of chat messages")
    document_info: Optional[Dict[str, Any]] = Field(None, description="Document information")
    session_info: Optional[SessionStatus] = Field(None, description="Session status")

class WebSocketMessage(BaseModel):
    type: str = Field(..., description="Message type")
    data: Dict[str, Any] = Field(..., description="Message data")
    timestamp: Optional[str] = Field(None, description="Message timestamp")

class DocumentMetadata(BaseModel):
    filename: str = Field(..., description="Document filename")
    file_size: int = Field(..., description="File size in bytes")
    pages: int = Field(..., description="Number of pages")
    uploaded_at: str = Field(..., description="Upload timestamp")
    processing_time: float = Field(..., description="Processing time in seconds")
    chunk_count: Optional[int] = Field(None, description="Number of text chunks")

class BookAnalysis(BaseModel):
    title: Optional[str] = Field(None, description="Book title")
    themes: List[str] = Field([], description="Identified themes")
    characters: List[str] = Field([], description="Main characters")
    summary: Optional[str] = Field(None, description="Book summary")
    genre: Optional[str] = Field(None, description="Book genre")
    key_concepts: List[str] = Field([], description="Key concepts")

class HealthCheck(BaseModel):
    status: str = Field("healthy", description="Service status")
    timestamp: str = Field(..., description="Health check timestamp")
    active_sessions: int = Field(0, description="Number of active sessions")
    active_connections: int = Field(0, description="Number of active WebSocket connections")
    system_info: Optional[Dict[str, Any]] = Field(None, description="System information")

class ErrorResponse(BaseModel):
    error: str = Field(..., description="Error message")
    detail: Optional[str] = Field(None, description="Detailed error description")
    code: Optional[int] = Field(None, description="Error code")
    timestamp: str = Field(..., description="Error timestamp")

# WebSocket message types
class WSConnectionMessage(BaseModel):
    type: str = Field("connection", description="Message type")
    status: str = Field(..., description="Connection status")
    message: str = Field(..., description="Connection message")

class WSChatMessage(BaseModel):
    type: str = Field("message", description="Message type")
    role: str = Field(..., description="Message role")
    content: str = Field(..., description="Message content")
    timestamp: str = Field(..., description="Message timestamp")

class WSTypingMessage(BaseModel):
    type: str = Field("typing", description="Message type")
    status: bool = Field(..., description="Typing status")

class WSUploadMessage(BaseModel):
    type: str = Field("upload_status", description="Message type")
    status: str = Field(..., description="Upload status")
    message: str = Field(..., description="Upload message")
    filename: Optional[str] = Field(None, description="Filename")

class WSErrorMessage(BaseModel):
    type: str = Field("error", description="Message type")
    message: str = Field(..., description="Error message")
    code: Optional[int] = Field(None, description="Error code")

class EmotionProfile(BaseModel):
    emotions: Dict[str, float]
    dominant_emotion: str
class BookRecommendation(BaseModel):
    isbn13: str
    title: str
    authors: str
    description: str
    thumbnail: Optional[str] = None
    categories: Optional[str] = None
    published_year: Optional[int] = None
    similarity_score: float