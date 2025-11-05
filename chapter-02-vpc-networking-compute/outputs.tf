output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "vpc_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "vpc_self_link" {
  description = "Self link of the VPC network"
  value       = google_compute_network.vpc.self_link
}

output "subnet_name" {
  description = "Name of the subnet"
  value       = google_compute_subnetwork.subnet.name
}

output "subnet_cidr" {
  description = "CIDR range of the subnet"
  value       = google_compute_subnetwork.subnet.ip_cidr_range
}

output "subnet_region" {
  description = "Region of the subnet"
  value       = google_compute_subnetwork.subnet.region
}

output "firewall_rule_name" {
  description = "Name of the firewall rule"
  value       = google_compute_firewall.allow_ssh_icmp.name
}

output "vm_name" {
  description = "Name of the compute instance"
  value       = google_compute_instance.vm.name
}

output "vm_internal_ip" {
  description = "Internal IP address of the VM"
  value       = google_compute_instance.vm.network_interface[0].network_ip
}

output "vm_external_ip" {
  description = "External IP address of the VM"
  value       = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "vm_zone" {
  description = "Zone where the VM is running"
  value       = google_compute_instance.vm.zone
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.ssh_user}@${google_compute_instance.vm.network_interface[0].access_config[0].nat_ip}"
}

output "nginx_url" {
  description = "URL to access the nginx web server"
  value       = "http://${google_compute_instance.vm.network_interface[0].access_config[0].nat_ip}"
}
