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

# Install dependencies (ignoring scripts initially to avoid missing file errors)
# Use BuildKit cache mount to speed up npm install
ENV ELECTRON_RUN_AS_NODE=1
RUN --mount=type=cache,target=/root/.npm \
    npm install --legacy-peer-deps --ignore-scripts

# Copy source code
COPY . .

# Run postinstall scripts now that source code is available
# Rebuild electron to ensure the binary is downloaded (was skipped by --ignore-scripts)
# Use cache for electron binaries to speed up build
RUN --mount=type=cache,target=/root/.cache/electron \
    --mount=type=cache,target=/root/.cache/electron-builder \
    npm rebuild electron esbuild

RUN --mount=type=cache,target=/root/.cache/electron \
    --mount=type=cache,target=/root/.cache/electron-builder \
    npm run postinstall

# Run tests
# CI=true ensures vitest runs once and exits
ENV CI=true
RUN npm run test

# Build the renderer (React) application
RUN npm run build:renderer

# Stage 2: Serve with light Node image
# Use alpine to drastically reduce image size (removes build tools, electron binaries, etc.)
FROM node:20-alpine

WORKDIR /app

# Install simple static server
RUN npm install -g serve

# Copy only the built artifacts from the build stage
COPY --from=build /app/dist/renderer ./dist/renderer

# Expose port 80
EXPOSE 80

# Serve the application
CMD ["serve", "-s", "dist/renderer", "-l", "80"]
