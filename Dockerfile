# Simple Flutter Web Dockerfile
FROM ubuntu:22.04 AS build

# Install dependencies
RUN apt-get update && apt-get install -y \
  curl \
  git \
  unzip \
  xz-utils \
  zip \
  libglu1-mesa \
  && rm -rf /var/lib/apt/lists/*

# Install Flutter
RUN git clone https://github.com/flutter/flutter.git -b stable /flutter
ENV PATH="/flutter/bin:${PATH}"

# Pre-download web dependencies
RUN flutter doctor
RUN flutter config --enable-web

WORKDIR /app

# Copy and install dependencies
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

# Copy project and build
COPY . .
RUN echo "baseUrl=https://anupnode.onrender.com" > .env
RUN echo "chatUrl=https://esewachat.onrender.com" >> .env
RUN flutter build web --release

# Serve with nginx
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html

# Simple nginx config for Flutter routing
RUN echo 'server { \
  listen 80; \
  root /usr/share/nginx/html; \
  index index.html; \
  location / { try_files $uri $uri/ /index.html; } \
  }' > /etc/nginx/conf.d/default.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]