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

# Subnet Variables (using existing subnet from Chapter 2)
variable "subnet_name" {
  description = "Name of the subnet for backend VMs (must exist)"
  type        = string
  default     = "cl-sub-sandbox-web-eu-nrth2-01"
}

# Instance Template Variables
variable "instance_template_name" {
  description = "Name of the instance template"
  type        = string
  default     = "cl-template-sandbox-web-lb"
}

variable "machine_type" {
  description = "Machine type for backend instances"
  type        = string
  default     = "e2-micro"
}

variable "vm_image" {
  description = "Boot disk image for the compute instances"
  type        = string
  default     = "debian-cloud/debian-11"
}

# Managed Instance Group Variables
variable "mig_name" {
  description = "Name of the managed instance group"
  type        = string
  default     = "cl-mig-sandbox-web-lb"
}

variable "mig_target_size" {
  description = "Number of instances in the managed instance group"
  type        = number
  default     = 2
}

# Load Balancer Variables
variable "lb_name" {
  description = "Name prefix for load balancer components"
  type        = string
  default     = "cl-lb-sandbox-web"
}

variable "health_check_port" {
  description = "Port for health check"
  type        = number
  default     = 80
}

# Firewall Variables
variable "firewall_name_lb_health_check" {
  description = "Name of the firewall rule for load balancer health checks"
  type        = string
  default     = "cl-fw-sandbox-allow-lb-health-check"
}

variable "firewall_name_web_traffic" {
  description = "Name of the firewall rule for web traffic to load balancer"
  type        = string
  default     = "cl-fw-sandbox-allow-web-traffic"
}

variable "network_tag" {
  description = "Network tag for backend instances"
  type        = string
  default     = "web-backend"
}
