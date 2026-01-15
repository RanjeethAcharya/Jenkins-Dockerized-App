# Stage 1: Build and Test
FROM node:20 AS build

# Install system dependencies required by Electron
RUN apt-get update && apt-get install -y \
    libnss3 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libgbm1 \
    libasound2 \
    libpangocairo-1.0-0 \
    libxss1 \
    libgtk-3-0 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copy package files first for caching
COPY package*.json ./

# Install dependencies (including Electron for build scripts)
# We set ELECTRON_RUN_AS_NODE to ensure postinstall scripts don't try to spawn GUI
ENV ELECTRON_RUN_AS_NODE=1
RUN npm install --legacy-peer-deps

# Copy source code
COPY . .

# Run tests
# CI=true ensures vitest runs once and exits
ENV CI=true
RUN npm run test

# Build the renderer (React) application
RUN npm run build:renderer

# Stage 2: Serve with Nginx
FROM nginx:alpine

# Copy the build output from the previous stage
# The vite config outputs to ../../dist/renderer relative to src/renderer, which maps to /app/dist/renderer
COPY --from=build /app/dist/renderer /usr/share/nginx/html

# Expose port 80
EXPOSE 80

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
