pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'mdgm5340/book-rec-frontend:latest'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'main', url: 'https://github.com/MD-Gyasuddin-Mansuri/Book-Recommendation.git', credentialsId: 'github-creds'
            }
        }

        stage('Flutter Pub Get') {
            steps {
                sh '/snap/bin/flutter pub get'
            }
        }

        stage('Build Web') {
            steps {
                sh '/snap/bin/flutter build web --release'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE .'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push $DOCKER_IMAGE
                    '''
                }
            }
        }
    }

    post {
        always {
            echo "Pipeline completed."
        }
        success {
            echo "✅ Pipeline succeeded. Docker image pushed: $DOCKER_IMAGE"
        }
        failure {
            echo "❌ Pipeline failed. Check logs for errors."
        }
    }
}
