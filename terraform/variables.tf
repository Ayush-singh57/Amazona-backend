variable "aws_region" {
  default = "ap-south-1"
}

variable "project_name" {
  default = "amazona-production"
}

variable "app_image" {
  description = "The URL of your Docker image in ECR or DockerHub"
  default     = "835637956758.dkr.ecr.ap-south-1.amazonaws.com/amazona-backend:latest" 
}