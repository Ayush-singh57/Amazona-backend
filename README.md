🛒 Amazona E-Commerce - Backend API & Infrastructure

This repository contains the Node.js/Express backend for the Amazona E-Commerce platform. It serves as a RESTful API providing product data, user authentication, and order processing capabilities.

Beyond the application code, this repository contains the Infrastructure as Code (IaC) and CI/CD pipelines used to deploy the application as a highly available, serverless containerized service on AWS.

🚀 Tech Stack & Architecture

Runtime Environment: Node.js & Express.js

Database: MongoDB Atlas (Mongoose ODM)

Containerization: Docker

Cloud Provider: Amazon Web Services (AWS)

Compute: Amazon ECS (Elastic Container Service) on Fargate (Serverless)

Networking: Amazon Application Load Balancer (ALB), VPC, NAT Gateways

Infrastructure as Code (IaC): HashiCorp Terraform

CI/CD: GitHub Actions

📂 Repository Structure

├── .github/workflows/
│   └── backend-pipeline.yml  # Automated CI/CD deployment pipeline
├── routes/                   # Express API routes (Products, Users, Orders)
├── models/                   # Mongoose database schemas
├── terraform/                # Infrastructure as Code (AWS ECS, VPC, ALB)
├── Dockerfile                # Containerization blueprint
├── server.js                 # Entry point & Express server setup
└── package.json


☁️ Cloud Infrastructure (Terraform)

The infrastructure for this backend is fully automated via Terraform. It provisions:

Custom VPC with Public and Private Subnets.

NAT Gateway to allow private Fargate tasks to securely pull images and connect to MongoDB Atlas.

Application Load Balancer (ALB) to route incoming HTTP traffic from the internet to the private containers.

Amazon ECR to store versioned Docker images.

Amazon ECS Cluster & Task Definitions running on serverless AWS Fargate.

To provision the infrastructure manually:

cd terraform
terraform init
terraform apply


🔄 CI/CD Pipeline

Deployments are fully automated. Pushing code to the main branch triggers the GitHub Actions workflow which:

Authenticates securely with AWS.

Builds a new Docker image from the latest code.

Pushes the Docker image to Amazon Elastic Container Registry (ECR).

Registers a new ECS Task Definition.

Triggers a rolling update on the ECS Service, ensuring zero-downtime deployments.

💻 Local Development

To run this backend API locally on your machine:

Prerequisites

Node.js installed

A MongoDB Atlas Cluster (or local MongoDB instance)

1. Install Dependencies

npm install


2. Environment Variables

Create a .env file in the root directory and add the following:

PORT=4000
MONGODB_URI=your_mongodb_connection_string
PAYPAL_CLIENT_ID=your_paypal_client_id
GOOGLE_API_KEY=your_google_api_key


3. Run the Server

npm start
# Server will start on http://localhost:4000


🔐 CORS Configuration

The backend is configured to accept requests via Cross-Origin Resource Sharing (CORS). For local development, it accepts requests from localhost. In production, ensure the origin in server.js is updated to match your live CloudFront frontend URL to maintain strict security.
