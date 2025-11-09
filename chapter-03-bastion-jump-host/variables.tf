variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  type        = string
  default     = "europe-north2"
}

variable "zone" {
  description = "The GCP zone"
  type        = string
  default     = "europe-north2-a"
}

# VPC Variables (using existing VPC from Chapter 2)
variable "vpc_name" {
  description = "Name of the VPC network (must exist)"
  type        = string
  default     = "cl-vpc-sandbox"
}

# Private Subnet Variables
variable "private_subnet_name" {
  description = "Name of the private subnet"
  type        = string
  default     = "cl-sub-sandbox-private-eu-nrth2-01"
}

variable "private_subnet_cidr" {
  description = "CIDR range for the private subnet"
  type        = string
  default     = "10.100.2.0/24"
}

# Bastion Host Variables
variable "bastion_vm_name" {
  description = "Name of the bastion/jump host instance"
  type        = string
  default     = "cl-vm-sandbox-bastion-01"
}

variable "bastion_machine_type" {
  description = "Machine type for the bastion host"
  type        = string
  default     = "e2-micro"
}

variable "bastion_firewall_tag" {
  description = "Network tag for bastion host firewall rule targeting"
  type        = string
  default     = "cl-vm-bastion-allow-ssh"
}

# Private VM Variables
variable "private_vm_name" {
  description = "Name of the private VM instance"
  type        = string
  default     = "cl-vm-sandbox-private-db-01"
}

variable "private_machine_type" {
  description = "Machine type for the private VM"
  type        = string
  default     = "e2-micro"
}

variable "vm_image" {
  description = "Boot disk image for the compute instances"
  type        = string
  default     = "debian-cloud/debian-11"
}

# Firewall Variables
variable "private_firewall_rule_name" {
  description = "Name of the firewall rule for private subnet"
  type        = string
  default     = "cl-fw-sandbox-private-sub-allow-ssh-icmp"
}

variable "private_firewall_tag" {
  description = "Network tag for private subnet firewall rule targeting"
  type        = string
  default     = "cl-vm-private-sub-allow-ssh-icmp"
}

variable "bastion_firewall_rule_name" {
  description = "Name of the firewall rule for bastion host"
  type        = string
  default     = "cl-fw-sandbox-bastion-allow-ssh"
}

# SSH Variables
variable "ssh_user" {
  description = "SSH username for the VMs"
  type        = string
  default     = "rahulwagh"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}
