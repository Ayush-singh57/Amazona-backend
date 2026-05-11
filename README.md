Amazona Backend API

RESTful API for the Amazona E-Commerce platform. This repository contains the Node.js backend services and the Infrastructure as Code (IaC) required to deploy a highly available, serverless architecture on AWS.

🏗 Architecture Overview

This API is built for production scalability using AWS managed services:

Compute: AWS ECS on Fargate (Serverless Containers)

Traffic Routing: AWS Application Load Balancer (ALB)

Infrastructure Provisioning: Terraform

CI/CD: GitHub Actions

Database: MongoDB Atlas

📂 Project Structure

├── .github/workflows/      # CI/CD pipelines
├── models/                 # Mongoose database schemas
├── routes/                 # Express route handlers
├── terraform/              # AWS Infrastructure code
├── Dockerfile              # Container configuration
├── server.js               # Application entry point
└── package.json            # Project dependencies


💻 Local Setup

Prerequisites

Node.js v18+

MongoDB Connection URI (Local or Atlas)

Installation

Clone the repository and install dependencies:

npm install


Create a .env file in the root directory:

PORT=4000
MONGODB_URI=your_mongodb_connection_string
PAYPAL_CLIENT_ID=your_paypal_client_id
GOOGLE_API_KEY=your_google_api_key


Start the development server:

npm start


☁️ Cloud Deployment

The infrastructure is managed via Terraform and deployed automatically using GitHub Actions.

1. Provision Infrastructure

To manually deploy or update AWS resources (ALB, ECS, VPC, NAT Gateway, ECR):

cd terraform
terraform init
terraform apply


2. Automated CI/CD

Pushing to the main branch automatically triggers the .github/workflows/backend-pipeline.yml action. The pipeline:

Builds a new Docker image from the latest source.

Pushes the image to Amazon ECR.

Updates the ECS Task Definition.

Performs a rolling zero-downtime update to the ECS Service behind the ALB.

🔐 Security & CORS

By default, the backend accepts Cross-Origin Resource Sharing (CORS) requests. Before routing production traffic, ensure the origin policy in server.js is updated to strictly match your deployed CloudFront frontend URL.
