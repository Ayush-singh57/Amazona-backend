terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # This ensures you use a modern version of the AWS provider
    }
  }
}

