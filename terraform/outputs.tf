output "final_alb_url" {
  value = module.compute.alb_url
}

output "final_ecr_repo" {
  value = module.compute.ecr_repository_url
}