from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes.routes import router
from app.controllers.recommender import models, load_models, retrain_hybrid
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI instance
app = FastAPI(
    title="Book Recommendation API",
    description="Hybrid book recommender system with FastAPI and MongoDB",
    version="1.0.0"
)

# Enable CORS so frontend can call backend APIs
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Replace with your frontend URL in production (e.g., http://localhost:5173)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routes from routes.py
app.include_router(router)

@app.on_event("startup")
async def startup_event():
    """Initialize models on startup"""
    if not await load_models():
        logger.info("No pre-trained models found. Training initial models...")
        await retrain_hybrid()
    print("Models loaded successfully.")
    print("Application started successfully.")
        
