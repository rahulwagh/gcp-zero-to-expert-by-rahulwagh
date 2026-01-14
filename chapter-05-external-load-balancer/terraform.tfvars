# ============================================
# Chapter 5: External HTTP Load Balancer Configuration
# ============================================

# Project Configuration
project_id = "cl-demo-sandbox"
region     = "europe-north2"
zone       = "europe-north2-a"

# VPC Configuration (from Chapter 2)
vpc_name    = "cl-vpc-sandbox"
subnet_name = "cl-sub-sandbox-web-eu-nrth2-01"

# Instance Template Configuration
instance_template_name = "cl-template-sandbox-web-lb"
machine_type           = "e2-micro"
vm_image               = "debian-cloud/debian-11"

# Managed Instance Group Configuration
mig_name        = "cl-mig-sandbox-web-lb"
mig_target_size = 2 # Start with 2 instances, can be scaled up later

# Load Balancer Configuration
lb_name           = "cl-lb-sandbox-web"
health_check_port = 80

# Firewall Configuration
firewall_name_lb_health_check = "cl-fw-sandbox-allow-lb-health-check"
firewall_name_web_traffic     = "cl-fw-sandbox-allow-web-traffic"
network_tag                   = "web-backend"
