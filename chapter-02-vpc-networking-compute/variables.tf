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

# VPC Variables
variable "vpc_name" {
  description = "Name of the VPC network"
  type        = string
  default     = "cl-vpc-sandbox"
}

# Subnet Variables
variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
  default     = "cl-sub-sandbox-web-eu-nrth2-01"
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.100.1.0/24"
}

# Firewall Variables
variable "firewall_rule_name" {
  description = "Name of the firewall rule"
  type        = string
  default     = "cl-fw-sandbox-allow-ssh-icmp"
}

variable "firewall_tag" {
  description = "Network tag for firewall rule targeting"
  type        = string
  default     = "cl-vm-sandbox-allow-ssh-icmp"
}

# VM Variables
variable "vm_name" {
  description = "Name of the compute instance"
  type        = string
  default     = "cl-vm-sandbox-web-01"
}

variable "machine_type" {
  description = "Machine type for the compute instance"
  type        = string
  default     = "e2-micro"
}

variable "vm_image" {
  description = "Boot disk image for the compute instance"
  type        = string
  default     = "debian-cloud/debian-11"
}

variable "ssh_user" {
  description = "SSH username for the VM"
  type        = string
  default     = "rahulwagh"
}

variable "ssh_public_key" {
  description = "SSH public key for VM access"
  type        = string
}
