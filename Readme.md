# BookRec - Node.js Backend API

BookRec Node.js backend provides comprehensive REST API services for user management, book shelving, community forums, reviews, and other CRUD operations. Built with Node.js and Express, it serves as the main backend for the BookRec book recommendation platform.

## Features

- 🔐 **User Authentication**: Complete auth system with JWT tokens
- 📚 **User Shelf Management**: Personal book collections and reading lists
- 💬 **Community Forum**: Discussion boards and user interactions
- ⭐ **Review System**: Book reviews and ratings management
- 🔒 **Security**: JWT-based authentication and authorization
- 📊 **CRUD Operations**: Full Create, Read, Update, Delete functionality
- 🐳 **Docker Ready**: Containerized deployment
- 🚀 **RESTful API**: Clean and consistent API design

## Tech Stack

- **Runtime**: Node.js 20
- **Framework**: Express.js
- **Database**: MongoDB
- **Authentication**: JWT (JSON Web Tokens)
- **Security**: bcrypt for password hashing
- **File Storage**: Cloudinary
- **Email**: Nodemailer
- **Containerization**: Docker
- **Environment**: dotenv for configuration

## Quick Start

### Prerequisites

- Node.js 20+
- MongoDB (local or cloud instance)
- Docker (optional, for containerized deployment)
- Git

### Clone the Repository

```bash
git clone https://github.com/Axkratos/Book-Recommendation.git
cd Book-Recommendation
git checkout backend  # Switch to the backend branch
```

## Installation & Setup

### Method 1: Local Development (Node.js)

1. **Install dependencies:**
   ```bash
   npm install
   ```

2. **Environment Configuration:**
   Create a `.env` file in the root directory with the following configuration:
   ```env
   # CORS Configuration
   CORS_ORIGIN=*
   
   # Database Configuration  
   MONGODB_URI=mongodb://localhost:27017/bookrec
   
   # Server Configuration
   PORT=8000
   
   # JWT Configuration
   JWT_SECRET=your_jwt_secret_key_here
   JWT_REFRESH_SECRET=your_refresh_secret_key_here
   JWT_EXPIRES_IN=30d
   JWT_REFRESH_EXPIRES_IN=90d
   
   # Email Configuration
   EMAIL_USERNAME=your_email@gmail.com
   EMAIL_PASSWORD=your_app_password
   EMAIL_HOST=smtp.example.com
   EMAIL_PORT=587
   
   # Frontend URLs
   CLIENT_URL=http://localhost:5173/
   FRONTEND_URL=http://localhost:64922
   
   # External Services
   FASTAPI_URL=http://localhost:5000
   
   # Session Configuration  
   SESSION_SECRET=your_session_secret
   
   # Cloudinary Configuration
   CLOUDINARY_CLOUD_NAME=your_cloud_name
   CLOUDINARY_API_KEY=your_api_key
   CLOUDINARY_API_SECRET=your_api_secret
   ```

3. **Run the application:**
   ```bash
   # Development mode with auto-reload
   npm run dev
   
   # Production mode
   npm start
   ```

4. **Access the API:**
   - API Base URL: http://localhost:8000

### Method 2: Docker Deployment

1. **Build the Docker image:**
   ```bash
   docker build -t bookrec-node-backend .
   ```

2. **Run the container:**
   ```bash
   docker run -d \
     --name bookrec-node-app \
     -p 8000:8000 \
     --env-file .env \
     bookrec-node-backend
   ```
