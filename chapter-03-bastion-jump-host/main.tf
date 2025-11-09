# ============================================
# Data Source: Reference Existing VPC
# ============================================
# This references the VPC created in Chapter 2
# Make sure Chapter 2's VPC exists before running this

data "google_compute_network" "vpc" {
  name = var.vpc_name
}

# ============================================
# Private Subnet
# ============================================
# This subnet will NOT have external internet access
# VMs in this subnet can only be accessed via the bastion host

resource "google_compute_subnetwork" "private_subnet" {
  name          = var.private_subnet_name
  ip_cidr_range = var.private_subnet_cidr
  region        = var.region
  network       = data.google_compute_network.vpc.id
  description   = "Private subnet for database and backend services"

  # Enable VPC Flow Logs for monitoring
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }

  # Private Google Access allows VMs without external IPs to access Google APIs
  private_ip_google_access = true
}

# ============================================
# Firewall Rules
# ============================================

# Firewall rule to allow SSH access to bastion host from internet
resource "google_compute_firewall" "bastion_allow_ssh" {
  name    = var.bastion_firewall_rule_name
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]  # Allow from anywhere - restrict in production!
  target_tags   = [var.bastion_firewall_tag]

  description = "Allow SSH access to bastion host from internet"
}

# Firewall rule to allow SSH and ICMP from bastion host to private subnet
resource "google_compute_firewall" "private_allow_ssh_icmp" {
  name    = var.private_firewall_rule_name
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }

  # Only allow traffic from the bastion host's subnet (where bastion resides)
  # In production, you might want to be more specific with source tags
  source_tags = [var.bastion_firewall_tag]
  target_tags = [var.private_firewall_tag]

  description = "Allow SSH and ICMP from bastion host to private VMs"
}

# ============================================
# Bastion Host / Jump Host
# ============================================
# This VM has a public IP and acts as a gateway to private VMs

resource "google_compute_instance" "bastion" {
  name         = var.bastion_vm_name
  machine_type = var.bastion_machine_type
  zone         = var.zone

  tags = [var.bastion_firewall_tag]

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = 20
      type  = "pd-standard"
    }
  }

  # Bastion needs to be in a subnet with external access
  # We'll use the existing public subnet from Chapter 2
  network_interface {
    network = data.google_compute_network.vpc.id
    # Using the same subnet as Chapter 2 for the bastion
    # Alternatively, you could create a dedicated bastion subnet
    subnetwork = "cl-sub-sandbox-web-eu-nrth2-01"

    access_config {
      # Ephemeral public IP - bastion needs internet access
    }
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  labels = {
    environment = "sandbox"
    managed-by  = "terraform"
    purpose     = "bastion-host"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Update system
    apt-get update
    apt-get upgrade -y

    # Install useful tools for a bastion host
    apt-get install -y \
      htop \
      vim \
      net-tools \
      dnsutils \
      telnet \
      tcpdump

    # Create a welcome message
    cat > /etc/motd <<MOTD
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║              🔐 BASTION HOST / JUMP SERVER 🔐             ║
    ║                                                           ║
    ║  This is a bastion host for accessing private VMs        ║
    ║  in the private subnet (10.100.2.0/24)                   ║
    ║                                                           ║
    ║  To access private VM:                                   ║
    ║  ssh ${var.ssh_user}@<PRIVATE_VM_INTERNAL_IP>            ║
    ║                                                           ║
    ║  Chapter 3: Bastion Host Setup                           ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
MOTD
  EOF

  lifecycle {
    ignore_changes = [
      metadata_startup_script,
    ]
  }
}

# ============================================
# Private VM (Database/Backend Server)
# ============================================
# This VM does NOT have a public IP
# It can only be accessed via the bastion host

resource "google_compute_instance" "private_vm" {
  name         = var.private_vm_name
  machine_type = var.private_machine_type
  zone         = var.zone

  tags = [var.private_firewall_tag]

  boot_disk {
    initialize_params {
      image = var.vm_image
      size  = 20
      type  = "pd-standard"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id

    # NO access_config block = no external IP
    # This VM is completely private
  }

  metadata = {
    ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  }

  labels = {
    environment = "sandbox"
    managed-by  = "terraform"
    purpose     = "database-server"
  }

  metadata_startup_script = <<-EOF
    #!/bin/bash
    # Update system
    apt-get update
    apt-get upgrade -y

    # Install PostgreSQL (example database)
    apt-get install -y postgresql postgresql-contrib

    # Create a welcome message
    cat > /etc/motd <<MOTD
    ╔═══════════════════════════════════════════════════════════╗
    ║                                                           ║
    ║            🔒 PRIVATE DATABASE SERVER 🔒                  ║
    ║                                                           ║
    ║  This VM is on a private subnet with no internet access  ║
    ║  Accessible only via the bastion host                    ║
    ║                                                           ║
    ║  Subnet: ${var.private_subnet_cidr}                      ║
    ║  PostgreSQL: Installed and ready                         ║
    ║                                                           ║
    ║  Chapter 3: Private VM in Private Subnet                 ║
    ║                                                           ║
    ╚═══════════════════════════════════════════════════════════╝
MOTD
  EOF

  lifecycle {
    ignore_changes = [
      metadata_startup_script,
    ]
  }
}
