# BookRec - AI-Powered Book Recommendation Backend

BookRec is an intelligent book recommendation system backend that provides personalized book suggestions using hybrid machine learning approaches. Built with FastAPI, it combines collaborative filtering, content-based filtering, and vector similarity search to deliver accurate book recommendations.

## Features

* 🚀 **Fast & Modern**: Built with FastAPI for high performance
* 🤖 **Hybrid ML Models**: Combines collaborative filtering, content-based, and vector search
* 📊 **SVD-based Collaborative Filtering**: Uses matrix factorization for user-item recommendations
* 🔍 **Content-Based Filtering**: TF-IDF vectorization with cosine similarity
* 🧠 **Vector Similarity Search**: Powered by Google Generative AI embeddings and ChromaDB
* 📈 **Real-time Model Training**: Automatic model retraining with new data
* 🐳 **Docker Ready**: Containerized deployment
* 📖 **Comprehensive Book Database**: Support for books with ISBN, ratings, and metadata

## Tech Stack

* **Framework**: FastAPI
* **Language**: Python 3.11
* **Machine Learning**: scikit-learn, TruncatedSVD, NearestNeighbors
* **Vector Database**: ChromaDB
* **Embeddings**: Google Generative AI (models/embedding-001)
* **Data Processing**: pandas, numpy
* **Containerization**: Docker


## Quick Start

### Prerequisites

* Python 3.11+
* Google API Key (for embeddings)
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
GOOGLE_API_KEY=**********
MONGO_URI=*************
```

4. **Prepare the data**:
   * Ensure `books/books_cleaned.csv` is present
   * The system will automatically create ChromaDB vector store on first run
   * ML models will be trained and saved to `artifacts/` directory

5. **Run the application**:
```bash
uvicorn app.main:app --host 0.0.0.0 --port 5000 --reload
```

6. **Access the API**:
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
  -v $(pwd)/chroma_db:/app/chroma_db \
  -v $(pwd)/artifacts:/app/artifacts \
  bookrec-backend
```

3. **Access the application**:
   * API Base URL: `http://localhost:5000`
