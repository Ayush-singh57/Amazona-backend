terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "networking" {
  source       = "./modules/networking"
  project_name = var.project_name
}

module "compute" {
  source          = "./modules/compute"
  project_name    = var.project_name
  vpc_id          = module.networking.vpc_id
  public_subnets  = module.networking.public_subnets
  private_subnets = module.networking.private_subnets
  app_image       = var.app_image
}