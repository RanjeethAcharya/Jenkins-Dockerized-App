# todometer

A simple, meter-based to-do list built with Electron and React.

![todometer](ToDoMeter/assets/screenshot.png)

## DevOps Implementation

This repository highlights the **DevOps transformation** of the todometer application, focusing on containerization, automation, and build optimization.

### Key Features

- **Dockerized Application**: Fully containerized React/Electron application.
- **Multi-Stage Build**: Optimized `Dockerfile` that uses `node:20` for building and `node:alpine` for the final runtime, reducing image size from **~2.5GB to <200MB**.
- **Build Caching**: Implemented Docker BuildKit cache mounts (`--mount=type=cache`) to speed up dependency installation and Electron rebuilding.
- **CI/CD Pipeline**: Automated Generic Webhook Trigger Jenkins pipeline for Build, Test, and Deployment.

### Docker Build Process

The `Dockerfile` employs a multi-stage approach:
1.  **Build Stage**: Installs system dependencies, caches npm modules, tests, and builds the static assets.
2.  **Runtime Stage**: Uses a lightweight Alpine image to serve the application using `serve`, ensuring minimal footprint.

**Build & Run Locally:**

```bash
# Build the image
docker build -t todometer-app .

# Run the container (Mapped to port 8090)
docker run -d -p 8090:80 --name todometer-container todometer-app
```

### Jenkins Pipeline

The `Jenkinsfile` defines the CI/CD workflow:
1.  **Checkout**: Pulls the latest code.
2.  **Build & Test**: Builds the Docker image and runs unit tests (`vitest`) inside the build process.
3.  **Deploy**: Auto-deploys the container to the host using a fixed port (`8090`).

#### Prerequisites for Jenkins Agent:
- Docker installed and running.
- Unix or Windows agent (Pipeline supports both environments).
