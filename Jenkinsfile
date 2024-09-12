pipeline {
    agent any
 
    environment {
        GOOGLE_APPLICATION_CREDENTIALS = "${env.WORKSPACE}/gcp-service-account-json.json"
    }
 
    stages {
        stage('Checkout') {
            steps {
                // Checkout Terraform code from your GitHub repository
                git branch: 'main', credentialsId: 'github-credentials-id', url: 'https://github.com/nikhil090820/GCP-terraform-code.git'
            }
        }
 
        stage('Install Terraform') {
            steps {
                // Install Terraform if it's not already installed
                sh '''
                    if ! [ -x "$(command -v terraform)" ]; then
                        wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip unzip terraform_1.5.0_linux_amd64.zip
                        sudo mv terraform /usr/local/bin/
                    fi
                '''
            }
        }
        
       stage('Initialize Terraform') {
            steps {
                script {
                    // Inject the service account key file
                    withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        // Initialize Terraform
                        sh 'terraform init'
                    }
                }
            }
        }
        
       stage('Terraform Plan') {
            steps {
                script {
                    // Inject the service account key file
                    withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        // Initialize Terraform
                        sh 'terraform plan'
                    }
                }
            }
        }
        
        stage('Apply Terraform') {
            steps {
                script {
                    // Apply Terraform configurations
                    withCredentials([file(credentialsId: 'gcp-service-account-json', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                        sh 'terraform destroy -auto-approve'
                    }
                }
            }
        }
       
    }
 
    post {
        always {
            // Cleanup workspace
            cleanWs()
        }
    }
}
