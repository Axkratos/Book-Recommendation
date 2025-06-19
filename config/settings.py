import os
from dotenv import load_dotenv

load_dotenv()

# API Configuration
GOOGLE_API_KEY = os.getenv("GOOGLE_API_KEY")
if not GOOGLE_API_KEY:
    raise ValueError("GOOGLE_API_KEY environment variable is required")

# File upload settings
MAX_FILE_SIZE = 20 * 1024 * 1024  # 10MB
ALLOWED_EXTENSIONS = ['.pdf']

# Session settings
SESSION_TIMEOUT = 3600  # 1 hour in seconds