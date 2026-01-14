# ============================================
# Data Source: Reference Existing VPC
# ============================================
# This references the VPC created in Chapter 2

data "google_compute_network" "vpc" {
  name = var.vpc_name
}

# ============================================
# Data Source: Reference Existing Subnet
# ============================================
# This references the subnet created in Chapter 2

data "google_compute_subnetwork" "subnet" {
  name   = var.subnet_name
  region = var.region
}

# ============================================
# Firewall Rules
# ============================================

# Allow health checks from Google Cloud Load Balancer
resource "google_compute_firewall" "allow_health_check" {
  name    = var.firewall_name_lb_health_check
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  # Google Cloud Load Balancer health check IP ranges
  source_ranges = [
    "35.191.0.0/16",  # Google Cloud health check ranges
    "130.211.0.0/22", # Google Cloud health check ranges
  ]

  target_tags = [var.network_tag]

  description = "Allow health checks from Google Cloud Load Balancer"
}

# Allow HTTP traffic from anywhere to the load balancer
resource "google_compute_firewall" "allow_web_traffic" {
  name    = var.firewall_name_web_traffic
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.network_tag]

  description = "Allow HTTP traffic from internet to backend instances"
}

# ============================================
# Instance Template
# ============================================
# Template for creating identical backend instances

resource "google_compute_instance_template" "web_backend" {
  name_prefix  = "${var.instance_template_name}-"
  machine_type = var.machine_type
  region       = var.region

  tags = [var.network_tag]

  disk {
    source_image = var.vm_image
    auto_delete  = true
    boot         = true
    disk_size_gb = 10
    disk_type    = "pd-standard"
  }

  network_interface {
    network    = data.google_compute_network.vpc.id
    subnetwork = data.google_compute_subnetwork.subnet.id

    # Each instance gets an external IP for testing
    # In production, you might remove this and use Cloud NAT
    access_config {
      network_tier = "PREMIUM"
    }
  }

  # Startup script to install and configure nginx
  metadata_startup_script = <<-EOF
    #!/bin/bash
    set -e

    # Update package list
    apt-get update

    # Install nginx
    apt-get install -y nginx

    # Get instance details
    INSTANCE_NAME=$(curl -H "Metadata-Flavor: Google" \
      http://metadata.google.internal/computeMetadata/v1/instance/name)
    INSTANCE_ZONE=$(curl -H "Metadata-Flavor: Google" \
      http://metadata.google.internal/computeMetadata/v1/instance/zone | cut -d'/' -f4)
    INSTANCE_IP=$(curl -H "Metadata-Flavor: Google" \
      http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/ip)

    # Create custom index page
    cat > /var/www/html/index.html <<HTML
    <!DOCTYPE html>
    <html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Load Balancer Backend - $INSTANCE_NAME</title>
        <style>
            body {
                font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
                margin: 0;
                padding: 0;
                background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
                min-height: 100vh;
                display: flex;
                justify-content: center;
                align-items: center;
            }
            .container {
                background: white;
                border-radius: 20px;
                padding: 40px;
                box-shadow: 0 20px 60px rgba(0,0,0,0.3);
                max-width: 600px;
                text-align: center;
            }
            h1 {
                color: #667eea;
                margin-bottom: 20px;
                font-size: 2.5em;
            }
            .info {
                background: #f7f7f7;
                border-radius: 10px;
                padding: 20px;
                margin: 20px 0;
                text-align: left;
            }
            .info-item {
                margin: 10px 0;
                padding: 10px;
                background: white;
                border-radius: 5px;
                display: flex;
                justify-content: space-between;
            }
            .label {
                font-weight: bold;
                color: #667eea;
            }
            .value {
                font-family: monospace;
                color: #333;
            }
            .status {
                display: inline-block;
                padding: 8px 16px;
                background: #10b981;
                color: white;
                border-radius: 20px;
                font-weight: bold;
                margin: 20px 0;
            }
            .footer {
                margin-top: 30px;
                color: #666;
                font-size: 0.9em;
            }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>🚀 Load Balancer Active!</h1>
            <div class="status">✓ Backend Server Online</div>

            <div class="info">
                <div class="info-item">
                    <span class="label">Instance Name:</span>
                    <span class="value">$INSTANCE_NAME</span>
                </div>
                <div class="info-item">
                    <span class="label">Zone:</span>
                    <span class="value">$INSTANCE_ZONE</span>
                </div>
                <div class="info-item">
                    <span class="label">Internal IP:</span>
                    <span class="value">$INSTANCE_IP</span>
                </div>
                <div class="info-item">
                    <span class="label">Server:</span>
                    <span class="value">nginx</span>
                </div>
            </div>

            <div class="footer">
                <p>Chapter 5: External HTTP(S) Load Balancer</p>
                <p>GCP Zero to Expert by Rahul Wagh</p>
            </div>
        </div>
    </body>
    </html>
HTML

    # Create health check endpoint
    cat > /var/www/html/health <<HTML
    OK
HTML

    # Restart nginx to apply changes
    systemctl restart nginx
    systemctl enable nginx

    echo "Web server setup complete!"
  EOF

  labels = {
    environment = "sandbox"
    managed-by  = "terraform"
    purpose     = "load-balancer-backend"
  }

  # Lifecycle to handle template updates
  lifecycle {
    create_before_destroy = true
  }
}

# ============================================
# Managed Instance Group (MIG)
# ============================================
# Creates and manages multiple identical instances

resource "google_compute_instance_group_manager" "web_backend" {
  name               = var.mig_name
  base_instance_name = "web-backend"
  zone               = var.zone
  target_size        = var.mig_target_size

  version {
    instance_template = google_compute_instance_template.web_backend.id
  }

  # Named ports for load balancer backend
  named_port {
    name = "http"
    port = 80
  }

  # Auto-healing configuration
  auto_healing_policies {
    health_check      = google_compute_health_check.http_health_check.id
    initial_delay_sec = 300 # Wait 5 minutes before first health check
  }

  # Update policy for rolling updates
  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 1
    replacement_method    = "SUBSTITUTE"
  }
}

# ============================================
# Health Check
# ============================================
# Checks if backend instances are healthy

resource "google_compute_health_check" "http_health_check" {
  name                = "${var.lb_name}-health-check"
  check_interval_sec  = 5
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 2

  http_health_check {
    port         = var.health_check_port
    request_path = "/health"
  }
}

# ============================================
# Backend Service
# ============================================
# Defines the group of backends and their settings

resource "google_compute_backend_service" "web_backend" {
  name                  = "${var.lb_name}-backend-service"
  protocol              = "HTTP"
  port_name             = "http"
  timeout_sec           = 30
  health_checks         = [google_compute_health_check.http_health_check.id]
  load_balancing_scheme = "EXTERNAL_MANAGED"

  backend {
    group           = google_compute_instance_group_manager.web_backend.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
    max_utilization = 0.8
  }

  # Session affinity and connection draining
  session_affinity        = "NONE"
  connection_draining_timeout_sec = 300

  # Enable Cloud CDN (optional - commented out for basic setup)
  # enable_cdn = true

  # cdn_policy {
  #   cache_mode = "CACHE_ALL_STATIC"
  #   default_ttl = 3600
  #   client_ttl = 7200
  #   max_ttl = 10800
  # }
}

# ============================================
# URL Map
# ============================================
# Routes requests to the appropriate backend service

resource "google_compute_url_map" "web_lb" {
  name            = "${var.lb_name}-url-map"
  default_service = google_compute_backend_service.web_backend.id

  # You can add custom host and path rules here
  # host_rule {
  #   hosts        = ["example.com"]
  #   path_matcher = "main"
  # }

  # path_matcher {
  #   name            = "main"
  #   default_service = google_compute_backend_service.web_backend.id
  # }
}

# ============================================
# HTTP Proxy
# ============================================
# Terminates HTTP connections and forwards to backend

resource "google_compute_target_http_proxy" "web_lb" {
  name    = "${var.lb_name}-http-proxy"
  url_map = google_compute_url_map.web_lb.id
}

# ============================================
# Global Forwarding Rule
# ============================================
# Provides the external IP address for the load balancer

resource "google_compute_global_forwarding_rule" "web_lb" {
  name                  = "${var.lb_name}-forwarding-rule"
  ip_protocol           = "TCP"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "80"
  target                = google_compute_target_http_proxy.web_lb.id
}
