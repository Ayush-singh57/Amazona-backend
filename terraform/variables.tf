variable "aws_region" {
  type    = string
  default = "ap-south-1"
}

variable "project_name" {
  type    = string
}

variable "environment" {
  type    = string
}

variable "mongodb_uri" {
  description = "The connection string for MongoDB Atlas"
  type        = string
  sensitive   = true
}