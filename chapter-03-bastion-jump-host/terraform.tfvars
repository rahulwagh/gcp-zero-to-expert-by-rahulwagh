# Terraform Variables Configuration
# Update the project_id with your actual GCP project ID

project_id = "cl-demo-sandbox"
region     = "europe-north2"
zone       = "europe-north2-a"

# VPC Configuration (using existing VPC from Chapter 2)
vpc_name = "cl-vpc-sandbox"

# Private Subnet Configuration
private_subnet_name = "cl-sub-sandbox-private-eu-nrth2-01"
private_subnet_cidr = "10.100.2.0/24"

# Bastion Host Configuration
bastion_vm_name       = "cl-vm-sandbox-bastion-01"
bastion_machine_type  = "e2-micro"  # Free tier eligible
bastion_firewall_tag  = "cl-vm-bastion-allow-ssh"

# Private VM Configuration
private_vm_name       = "cl-vm-sandbox-private-db-01"
private_machine_type  = "e2-micro"  # Free tier eligible
vm_image              = "debian-cloud/debian-11"

# Firewall Configuration
private_firewall_rule_name = "cl-fw-sandbox-private-sub-allow-ssh-icmp"
private_firewall_tag       = "cl-vm-private-sub-allow-ssh-icmp"
bastion_firewall_rule_name = "cl-fw-sandbox-bastion-allow-ssh"

# SSH Configuration
ssh_user       = "rahulwagh"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJB+hbkh+z7fGawz+9OkPatanBLVUfmyOUZwCmgbxAH rahulwagh@Rahuls-MacBook-Pro-2.local"
