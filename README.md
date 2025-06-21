# BookRec - AI-Powered Book Chat Backend

BookRec is an intelligent chat application backend that allows users to upload books and have interactive conversations with their content. Built with FastAPI, it provides a robust API for creating chat sessions, uploading documents, and engaging in AI-powered discussions about books.

## Features

* 🚀 **Fast & Modern**: Built with FastAPI for high performance
* 📚 **Document Upload**: Support for various book formats
* 💬 **Interactive Chat**: AI-powered conversations with book content
* 🔐 **Session Management**: Secure session-based interactions
* 🐳 **Docker Ready**: Containerized deployment
* 📖 **Book Reader AI Pal**: Specialized for book content analysis

## Tech Stack

* **Framework**: FastAPI
* **Language**: Python 3.11
* **Containerization**: Docker
* **AI Integration**: Document processing and chat capabilities


## Quick Start

### Prerequisites

* Python 3.11+
* Docker (optional, for containerized deployment)
* Git

### Clone the Repository

```bash
git clone https://github.com/Axkratos/Book-Recommendation.git
cd Book-Recommendation
git checkout ai  # Switch to the AI branch
```

## Installation & Setup

### Method 1: Local Development (FastAPI)

1. **Create a virtual environment**:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. **Install dependencies**:
```bash
pip install -r requirements.txt
```

3. **Environment Configuration**: 
Create a `.env` file in the root directory:
```env
# Add your environment variables here
GOOGLE_API_KEY=********
MONGO_URI=**************
```

4. **Run the application**:
```bash
uvicorn app.main:app --host 0.0.0.0 --port 5000 --reload
```

5. **Access the API**:
   * API Base URL: `http://localhost:5000`
   

### Method 2: Docker Deployment

1. **Build the Docker image**:
```bash
docker build -t bookrec-backend .
```

2. **Run the container**:
```bash
docker run -d \
  --name bookrec-app \
  -p 5000:5000 \
  --env-file .env \
  bookrec-backend
```

3. **Access the application**:
   * API Base URL: `http://localhost:5000`
