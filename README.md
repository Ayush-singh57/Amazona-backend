<div align="center">

# 🛒 Amazona — E-Commerce Backend API

**Backend of amazona webpage**
**deployed on AWS ECS Fargate with full Infrastructure as Code and automated CI/CD.**

[![Node.js](https://img.shields.io/badge/Node.js-339933?style=for-the-badge&logo=node.js&logoColor=white)](https://nodejs.org)
[![Express](https://img.shields.io/badge/Express-000000?style=for-the-badge&logo=express&logoColor=white)](https://expressjs.com)
[![MongoDB](https://img.shields.io/badge/MongoDB-47A248?style=for-the-badge&logo=mongodb&logoColor=white)](https://mongodb.com)
[![Docker](https://img.shields.io/badge/Docker-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://docker.com)
[![AWS](https://img.shields.io/badge/AWS-232F3E?style=for-the-badge&logo=amazon-aws&logoColor=white)](https://aws.amazon.com)
[![Terraform](https://img.shields.io/badge/Terraform-7B42BC?style=for-the-badge&logo=terraform&logoColor=white)](https://terraform.io)

</div>

---

## 📋 Table of Contents

- [Architecture Overview](#-architecture-overview)
- [Tech Stack](#-tech-stack)
- [Repository Structure](#-repository-structure)
- [Cloud Infrastructure](#️-cloud-infrastructure-terraform)
- [CI/CD Pipeline](#-cicd-pipeline)
- [Local Development](#-local-development)
- [CORS Configuration](#-cors-configuration)

---

## 🏗 Architecture Overview

```
Internet
    │
    ▼
┌─────────────────────────────┐
│  Application Load Balancer  │  ← Public Subnets
└────────────┬────────────────┘
             │
    ┌────────▼────────┐
    │   ECS Fargate   │  ← Private Subnets (Serverless Containers)
    │  (Node/Express) │
    └────────┬────────┘
             │  NAT Gateway
    ┌────────▼────────┐     ┌──────────────────┐
    │  MongoDB Atlas  │     │   Amazon ECR     │
    │   (Database)    │     │  (Docker Images) │
    └─────────────────┘     └──────────────────┘
```

The backend runs as a **serverless containerized service** on AWS Fargate — no servers to manage. All traffic enters through an **Application Load Balancer** in public subnets, which routes to private Fargate tasks. A **NAT Gateway** gives containers secure outbound access for image pulls and database connections.

---

## 🚀 Tech Stack

| Layer | Technology |
|---|---|
| **Runtime** | Node.js + Express.js |
| **Database** | MongoDB Atlas (Mongoose ODM) |
| **Containerization** | Docker |
| **Cloud Provider** | Amazon Web Services (AWS) |
| **Compute** | Amazon ECS on Fargate *(Serverless)* |
| **Networking** | ALB · VPC · NAT Gateways |
| **Infrastructure as Code** | HashiCorp Terraform |
| **CI/CD** | GitHub Actions |

---

## 📂 Repository Structure

```
amazona-backend/
│
├── 📁 .github/workflows/
│   └── backend-pipeline.yml    # Automated CI/CD deployment pipeline
│
├── 📁 routes/                  # Express API routes
│   ├── productRoutes.js        #   → Products
│   ├── userRoutes.js           #   → Authentication & Users
│   └── orderRoutes.js          #   → Orders
│
├── 📁 models/                  # Mongoose database schemas
│
├── 📁 terraform/               # Infrastructure as Code (AWS)
│   ├── vpc.tf                  #   → VPC, Subnets, NAT Gateway
│   ├── ecs.tf                  #   → ECS Cluster, Task Definitions
│   ├── alb.tf                  #   → Application Load Balancer
│   └── ecr.tf                  #   → Container Registry
│
├── 🐳 Dockerfile               # Containerization blueprint
├── 🟢 server.js                # Entry point & Express server setup
└── 📦 package.json
```

---

## ☁️ Cloud Infrastructure (Terraform)

The entire AWS infrastructure is defined as code and provisioned automatically. A single `terraform apply` builds everything from scratch.

### What Gets Provisioned

> 🔹 **VPC** — Custom network with isolated Public and Private Subnets
>
> 🔹 **NAT Gateway** — Allows private Fargate tasks to securely reach the internet
>
> 🔹 **Application Load Balancer** — Routes external HTTP traffic to containers
>
> 🔹 **Amazon ECR** — Private registry for versioned Docker images
>
> 🔹 **Amazon ECS + Fargate** — Serverless cluster with Task Definitions and rolling deployments

### Manual Provisioning

```bash
cd terraform
terraform init
terraform apply
```

---

## 🔄 CI/CD Pipeline

Every push to `main` triggers a fully automated deployment — **no manual steps required.**

```
git push → GitHub Actions
               │
               ├── 1️⃣  Authenticate with AWS (OIDC)
               ├── 2️⃣  Build Docker image from latest code
               ├── 3️⃣  Push image to Amazon ECR
               ├── 4️⃣  Register new ECS Task Definition
               └── 5️⃣  Trigger rolling update → ✅ Zero-downtime deploy
```

The pipeline uses **GitHub Actions OIDC** for secure, keyless AWS authentication — no long-lived credentials stored in secrets.

---

## 💻 Local Development

### Prerequisites

- [Node.js](https://nodejs.org) (v18+)
- A [MongoDB Atlas](https://www.mongodb.com/cloud/atlas) cluster or local MongoDB instance

### 1 · Install Dependencies

```bash
npm install
```

### 2 · Configure Environment Variables

Create a `.env` file in the project root:

```env
PORT=4000
MONGODB_URI=your_mongodb_connection_string
PAYPAL_CLIENT_ID=your_paypal_client_id
GOOGLE_API_KEY=your_google_api_key
```

> ⚠️ **Never commit your `.env` file.** Make sure it's listed in `.gitignore`.

### 3 · Start the Development Server

```bash
npm start
```

The API will be available at **`http://localhost:4000`** 🚀

---

## 🔐 CORS Configuration

CORS is configured in `server.js` to control which origins can access the API.

| Environment | Allowed Origin |
|---|---|
| **Local Development** | `http://localhost:3000` |
| **Production** | Your CloudFront frontend URL |

> Before deploying to production, update the `origin` value in `server.js` to your live CloudFront URL to enforce strict cross-origin security.

---

<div align="center">

</div>
