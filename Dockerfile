# Stage 1: Build and Test
FROM node:20 as build

WORKDIR /app

# Copy package files first for caching
COPY package*.json ./

# Install dependencies (including Electron for build scripts)
# We set ELECTRON_RUN_AS_NODE to ensure postinstall scripts don't try to spawn GUI
ENV ELECTRON_RUN_AS_NODE=1
RUN npm install

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
