output "load_balancer_public_ip" {
  description = "Publiczny adres IP Load Balancera (wejście do aplikacji)"
  value       = module.networking.lb_public_ip
}

# Jeśli chcesz widzieć prywatne IP maszyn (do celów testowych):
output "app_vms_private_ips" {
  value = module.compute.app_vm_private_ips
}