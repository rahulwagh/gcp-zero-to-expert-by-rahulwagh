# Terraform Variables Configuration
# Update the project_id with your actual GCP project ID

project_id = "cl-demo-sandboxterraform"  # Use the project ID from Chapter 1 (with random suffix)
region     = "europe-north2"
zone       = "europe-north2-a"

# VPC Configuration
vpc_name = "cl-vpc-sandbox"

# Subnet Configuration
subnet_name = "cl-sub-sandbox-web-eu-nrth2-01"
subnet_cidr = "10.100.1.0/24"

# Firewall Configuration
firewall_rule_name = "cl-fw-sandbox-allow-ssh-icmp"
firewall_tag       = "cl-vm-sandbox-allow-ssh-icmp"

# VM Configuration
vm_name      = "cl-vm-sandbox-web-01"
machine_type = "e2-micro"  # Free tier eligible
vm_image     = "debian-cloud/debian-11"

# SSH Configuration
ssh_user       = "rahulwagh"
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDJB+hbkh+z7fGawz+9OkPatanBLVUfmyOUZwCmgbxAH rahulwagh@Rahuls-MacBook-Pro-2.local"
