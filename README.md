🛒 Amazona E-Commerce - Backend API & Infrastructure

This repository contains the Node.js/Express backend for the Amazona E-Commerce platform. It serves as a RESTful API providing product data, user authentication, and order processing capabilities.

Beyond the application code, this project heavily focuses on production-grade AWS Infrastructure. The system is engineered to run as a highly available, serverless containerized service utilizing Amazon ECS on Fargate and an Application Load Balancer (ALB), fully provisioned via Infrastructure as Code (IaC).

🚀 Core Infrastructure Focus: ECS Fargate & ALB

The primary architectural achievement of this backend is its robust, scalable cloud deployment.

Compute: Amazon ECS on Fargate: The application runs completely serverless. Docker containers are executed on AWS Fargate, eliminating the need to provision, patch, or manage underlying EC2 servers while allowing for seamless container scaling.

Traffic Routing: Application Load Balancer (ALB): All incoming API traffic is securely intercepted by an ALB. The load balancer intelligently routes requests across healthy Fargate tasks deployed in private subnets across multiple Availability Zones, guaranteeing high availability.

Database: MongoDB Atlas (Mongoose ODM)

Containerization: Docker & Amazon ECR

Infrastructure as Code (IaC): HashiCorp Terraform

CI/CD: GitHub Actions

📂 Repository Structure

├── .github/workflows/
│   └── backend-pipeline.yml  # Automated CI/CD deployment pipeline to ECS
├── routes/                   # Express API routes (Products, Users, Orders)
├── models/                   # Mongoose database schemas
├── terraform/                # Infrastructure as Code (AWS ECS, VPC, ALB)
├── Dockerfile                # Containerization blueprint
├── server.js                 # Entry point & Express server setup
└── package.json


☁️ Cloud Infrastructure Details (Terraform)

The infrastructure for this backend is fully automated and version-controlled via Terraform. It provisions:

Application Load Balancer (ALB) to securely route and distribute incoming HTTP traffic from the internet to the private containers.

Amazon ECS Cluster & Task Definitions running on serverless AWS Fargate, which provides the scalable compute engine for the Node.js containers.

Custom VPC with Public and Private Subnets to isolate backend compute resources from the public internet.

NAT Gateway to allow private Fargate tasks to securely pull external images and connect to the MongoDB Atlas cluster.

Amazon ECR to store versioned Docker images.

To provision the infrastructure manually:

cd terraform
terraform init
terraform apply


🔄 CI/CD Pipeline

Deployments are fully automated. Pushing code to the main branch triggers a GitHub Actions workflow which:

Authenticates securely with AWS.

Builds a new Docker image from the latest code.

Pushes the Docker image to Amazon Elastic Container Registry (ECR).

Registers a new ECS Task Definition.

Triggers a rolling update on the ECS Service, ensuring zero-downtime deployments behind the ALB.

💻 Local Debugging (Minor)

While this backend is explicitly architected for AWS Fargate deployment, you can run it locally for quick debugging. Ensure you have Node.js installed and a MongoDB Atlas connection string.

# 1. Install dependencies
npm install

# 2. Create a .env file with PORT, MONGODB_URI, PAYPAL_CLIENT_ID, and GOOGLE_API_KEY

# 3. Start the server locally
npm start 


🔐 CORS Configuration

The backend is configured to accept requests via Cross-Origin Resource Sharing (CORS). For local development, it accepts requests from localhost. In production, the origin in server.js must match the live CloudFront frontend URL to maintain strict security and ensure the ALB only processes authorized cross-origin requests.
