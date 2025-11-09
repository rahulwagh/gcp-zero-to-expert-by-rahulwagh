# ============================================
# VPC and Network Outputs
# ============================================

output "vpc_name" {
  description = "Name of the VPC network"
  value       = data.google_compute_network.vpc.name
}

output "private_subnet_name" {
  description = "Name of the private subnet"
  value       = google_compute_subnetwork.private_subnet.name
}

output "private_subnet_cidr" {
  description = "CIDR range of the private subnet"
  value       = google_compute_subnetwork.private_subnet.ip_cidr_range
}

# ============================================
# Bastion Host Outputs
# ============================================

output "bastion_name" {
  description = "Name of the bastion host"
  value       = google_compute_instance.bastion.name
}

output "bastion_external_ip" {
  description = "External IP address of the bastion host"
  value       = google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip
}

output "bastion_internal_ip" {
  description = "Internal IP address of the bastion host"
  value       = google_compute_instance.bastion.network_interface[0].network_ip
}

output "bastion_ssh_command" {
  description = "SSH command to connect to the bastion host"
  value       = "ssh ${var.ssh_user}@${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip}"
}

# ============================================
# Private VM Outputs
# ============================================

output "private_vm_name" {
  description = "Name of the private VM"
  value       = google_compute_instance.private_vm.name
}

output "private_vm_internal_ip" {
  description = "Internal IP address of the private VM (no external IP)"
  value       = google_compute_instance.private_vm.network_interface[0].network_ip
}

output "private_vm_ssh_command" {
  description = "SSH command to connect to private VM from bastion"
  value       = "ssh ${var.ssh_user}@${google_compute_instance.private_vm.network_interface[0].network_ip}"
}

# ============================================
# Connection Instructions
# ============================================

output "connection_instructions" {
  description = "Instructions for connecting to the private VM via bastion"
  value = <<-EOT

    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                    BASTION HOST CONNECTION GUIDE                          ║
    ╚═══════════════════════════════════════════════════════════════════════════╝

    Step 1: Connect to Bastion Host
    ─────────────────────────────────────────────────────────────────────────────
    ssh ${var.ssh_user}@${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip}

    Step 2: From Bastion, Connect to Private VM
    ─────────────────────────────────────────────────────────────────────────────
    ssh ${var.ssh_user}@${google_compute_instance.private_vm.network_interface[0].network_ip}

    One-liner using SSH ProxyJump:
    ─────────────────────────────────────────────────────────────────────────────
    ssh -J ${var.ssh_user}@${google_compute_instance.bastion.network_interface[0].access_config[0].nat_ip} ${var.ssh_user}@${google_compute_instance.private_vm.network_interface[0].network_ip}

    Test Connectivity:
    ─────────────────────────────────────────────────────────────────────────────
    # From bastion host, ping the private VM:
    ping ${google_compute_instance.private_vm.network_interface[0].network_ip}

  EOT
}

# ============================================
# Firewall Rule Outputs
# ============================================

output "bastion_firewall_rule" {
  description = "Name of the bastion firewall rule"
  value       = google_compute_firewall.bastion_allow_ssh.name
}

output "private_firewall_rule" {
  description = "Name of the private subnet firewall rule"
  value       = google_compute_firewall.private_allow_ssh_icmp.name
}
