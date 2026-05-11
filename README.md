🚀 Amazona Backend: Production-Grade Infrastructure

This is not just a Node.js API; it is a fully automated cloud ecosystem. The core value of this repository lies in its Infrastructure as Code (IaC) and its Automated Deployment Pipelines, ensuring the Amazona platform is scalable, secure, and resilient.

🏗️ INFRASTRUCTURE AS CODE (Terraform)

The entire AWS environment is defined and managed via Terraform. This eliminates manual configuration and ensures 100% environment reproducibility.

Core Components Orchestrated:

NETWORK STACK: A custom VPC with Public/Private Subnets across multiple Availability Zones.

TRAFFIC ROUTING: An Application Load Balancer (ALB) serving as the secure entry point for all API traffic.

SERVERLESS COMPUTE: AWS ECS on Fargate running containerized Node.js tasks without managing EC2 instances.

GATEWAY SECURITY: NAT Gateways allowing private tasks to securely access MongoDB Atlas and external APIs.

IMAGE REGISTRY: Amazon ECR for private, version-controlled Docker image storage.

Command to Provision: terraform init && terraform apply -auto-approve

🔄 CONTINUOUS DEPLOYMENT (GitHub Actions)

We implement a Zero-Downtime CI/CD Pipeline. Every commit to the main branch triggers a sophisticated workflow that bridges the gap between code and the cloud.

The Deployment Lifecycle:

DOCKERIZATION: Triggered on push; builds a production-optimized image using the Dockerfile.

ECR PUSH: Securely authenticates and pushes the new image to the Amazon Elastic Container Registry.

TASK REGISTRATION: Dynamically updates the ECS Task Definition with the latest image URI.

ROLLING UPDATE: Instructs the ECS Service to perform a phased rollout.

STABILITY CHECK: The ALB performs health checks. New containers only receive traffic once they are verified as Healthy.

📂 REPOSITORY ARCHITECTURE

├── .github/workflows/      # 🚀 CI/CD: Automated ECS deployment
├── terraform/              # 🏗️ IaC: VPC, ALB, ECS, and ECR definitions
├── routes/                 # 🛣️ API: Endpoint logic
├── models/                 # 📊 Data: Mongoose schemas
├── Dockerfile              # 🐳 Container: Image build instructions
├── server.js               # 🟢 Entry: App bootstrap & middleware
└── package.json            # 📦 Deps: Node.js manifest


💻 LOCAL DEBUGGING (Minor Focus)

While the project is optimized for the Cloud, it can be audited locally:

npm install

Configure .env (MONGO_URI, PORT, JWT_SECRET).

npm start

🔐 SECURITY & CORS

Traffic is strictly routed through the AWS ALB. Cross-Origin Resource Sharing (CORS) is explicitly configured to allow communication from the CloudFront frontend. Production traffic is served over a secure, isolated network layer.
