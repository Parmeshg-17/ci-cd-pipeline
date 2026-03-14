pipeline {
    agent any

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker build -t ci-cd-pipeline:latest .'
            }
        }

        stage('Deploy Container') {
            steps {
                // Stop and remove the old container if it exists so the port isn't blocked
                sh 'docker rm -f my-web-app || true'

                // Run the new container on port 8081
                sh 'docker run -d --name my-web-app -p 8081:80 ci-cd-pipeline:latest'
            }
        }
    }
}
