# ============================================
# VPC Network
# ============================================

resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false
  description             = "Custom VPC for sandbox environment"
}

# ============================================
# Subnet
# ============================================

resource "google_compute_subnetwork" "subnet" {
  name          = var.subnet_name
  ip_cidr_range = var.subnet_cidr
  region        = var.region
  network       = google_compute_network.vpc.id
  description   = "Subnet for web servers in europe-north2"

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# ============================================
# Firewall Rules
# ============================================

# Allow SSH and ICMP from anywhere (adjust source_ranges for production)
resource "google_compute_firewall" "allow_ssh_icmp" {
  name    = var.firewall_rule_name
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [var.firewall_tag]

  description = "Allow SSH and ICMP traffic to instances with specific tag"
}

# ============================================
# Compute Instance
# ============================================

resource "google_compute_instance" "vm" {
  name         = var.vm_name
  machine_type = var.machine_type
  zone         = var.zone

  tags = [var.firewall_tag]

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id

    access_config {
      # Ephemeral public IP
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  labels = {
    environment = "sandbox"
    managed-by  = "terraform"
    purpose     = "web-server"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
    systemctl enable nginx

    # Create a simple webpage
    cat > /var/www/html/index.html <<HTML
    <!DOCTYPE html>
    <html>
    <head>
      <title>GCP Sandbox VM</title>
      <style>
        body { font-family: Arial, sans-serif; margin: 40px; background: #f0f0f0; }
        .container { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #4285f4; }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🚀 GCP Sandbox VM - Chapter 2</h1>
        <p><strong>VM Name:</strong> ${var.vm_name}</p>
        <p><strong>Region:</strong> ${var.region}</p>
        <p><strong>Zone:</strong> ${var.zone}</p>
        <p><strong>Status:</strong> ✅ Running</p>
        <p>This VM was created using Terraform!</p>
      </div>
    </body>
    </html>
HTML
  EOF

  lifecycle {
    ignore_changes = [
      metadata_startup_script,
    ]
  }
}
