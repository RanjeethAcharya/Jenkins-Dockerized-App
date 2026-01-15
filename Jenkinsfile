pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                // Check out the code from the repository
                checkout scm
            }
        }

        stage('Build and Test') {
            steps {
                script {
                    echo 'Building Docker image and running tests...'
                    // Validates the Dockerfile, installs dependencies, runs tests, and creates the artifact
                    if (isUnix()) {
                        sh 'docker build -t todometer-app .'
                    } else {
                        bat 'docker build -t todometer-app .'
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    echo 'Deploying application to container...'
                    // Stop and remove the existing container if running
                    if (isUnix()) {
                        sh 'docker rm -f todometer-container || true'
                        sh 'docker run -d -p 8090:80 --name todometer-container todometer-app'
                    } else {
                        // On Windows, use 'bat' and handle error suppression differently if needed
                        bat 'docker rm -f todometer-container || exit 0'
                        bat 'docker run -d -p 8090:80 --name todometer-container todometer-app'
                    }
                }
            }
        }
    }
}
