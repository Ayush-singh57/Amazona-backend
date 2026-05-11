output "backend_alb_url" {
  value = module.compute.alb_dns_name
}

output "mongodb_whitelist_ip" {
  description = "Put this EXACT IP address into your MongoDB Atlas Network Access!"
  value       = "${module.networking.nat_public_ip}/32"
}