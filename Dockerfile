# -------- Stage 1: Builder --------
FROM python:3.11-slim AS builder

WORKDIR /app

# Installing build dependencies
RUN apt-get update && apt-get install -y gcc && rm -rf /var/lib/apt/lists/*

# Copying only requirements first (leverage Docker cache)
COPY requirements.txt .

# Upgrading pip and install dependencies in a temp location
RUN pip install --upgrade pip && \
    pip install --prefix=/install --no-cache-dir -r requirements.txt

# -------- Stage 2: Runtime --------
FROM python:3.11-slim AS final

WORKDIR /app

# Copying installed packages from builder
COPY --from=builder /install /usr/local

# Copying the actual app code
COPY . .

# Setting environment
ENV PYTHONUNBUFFERED=1

# Exposing the FastAPI port
EXPOSE 5000

# Starting the server
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "5000"]
