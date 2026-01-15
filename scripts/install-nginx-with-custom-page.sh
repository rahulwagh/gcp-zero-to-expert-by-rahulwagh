#!/bin/bash
# ============================================================================
# Nginx Installation Script with Custom Landing Page
# ============================================================================
# This script installs nginx and creates a custom HTML page showing instance
# details. It handles apt lock conflicts that occur during VM boot.
#
# Usage:
#   - As a startup script in GCP Console
#   - As metadata_startup_script in Terraform
#   - Run manually: sudo bash install-nginx-with-custom-page.sh
#
# Features:
#   - Waits for cloud-init and apt locks
#   - Installs nginx
#   - Creates custom HTML page with instance metadata
#   - Creates /health endpoint for load balancer health checks
#   - Configures nginx to start on boot
#
# Author: Rahul Wagh
# Repository: gcp-zero-to-expert-by-rahulwagh
# ============================================================================

set -e

# ============================================================================
# Configuration Variables (Customize these as needed)
# ============================================================================
PAGE_TITLE="${PAGE_TITLE:-Load Balancer Backend}"
PAGE_GRADIENT="${PAGE_GRADIENT:-linear-gradient(135deg, #667eea 0%, #764ba2 100%)}"
PRIMARY_COLOR="${PRIMARY_COLOR:-#667eea}"
CHAPTER_NAME="${CHAPTER_NAME:-GCP Zero to Expert}"

# ============================================================================
# Helper Functions
# ============================================================================

# Function to log messages with timestamp
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# Function to wait for apt lock to be released
wait_for_apt() {
    log "Checking for apt locks..."
    local max_attempts=60  # 5 minutes maximum wait
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if ! sudo fuser /var/lib/dpkg/lock-frontend >/dev/null 2>&1 && \
           ! sudo fuser /var/lib/dpkg/lock >/dev/null 2>&1 && \
           ! sudo fuser /var/lib/apt/lists/lock >/dev/null 2>&1; then
            log "Apt lock released, continuing..."
            return 0
        fi

        log "Waiting for other apt processes to finish (attempt $((attempt + 1))/$max_attempts)..."
        sleep 5
        ((attempt++))
    done

    log "WARNING: Timed out waiting for apt lock, attempting to continue..."
    return 1
}

# Function to get instance metadata
get_metadata() {
    local metadata_key=$1
    curl -sf -H "Metadata-Flavor: Google" \
        "http://metadata.google.internal/computeMetadata/v1/instance/$metadata_key" 2>/dev/null || echo "Unknown"
}

# ============================================================================
# Main Installation Process
# ============================================================================

log "Starting nginx installation script..."

# Wait for cloud-init to complete
log "Waiting for cloud-init to complete..."
cloud-init status --wait 2>/dev/null || log "Cloud-init not available or already completed"

# Wait for apt lock
wait_for_apt

# Update package list
log "Updating package list..."
apt-get update -qq

# Install nginx
log "Installing nginx..."
DEBIAN_FRONTEND=noninteractive apt-get install -y -qq nginx

# Get instance details from metadata server
log "Fetching instance metadata..."
INSTANCE_NAME=$(get_metadata "name")
INSTANCE_ZONE=$(get_metadata "zone" | cut -d'/' -f4)
INSTANCE_IP=$(get_metadata "network-interfaces/0/ip")
INSTANCE_HOSTNAME=$(hostname)

log "Instance Details:"
log "  Name: $INSTANCE_NAME"
log "  Zone: $INSTANCE_ZONE"
log "  IP: $INSTANCE_IP"
log "  Hostname: $INSTANCE_HOSTNAME"

# Create custom index page
log "Creating custom HTML page..."
cat > /var/www/html/index.html <<HTML
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$PAGE_TITLE - $INSTANCE_NAME</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: $PAGE_GRADIENT;
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 600px;
            width: 100%;
            text-align: center;
        }

        h1 {
            color: $PRIMARY_COLOR;
            margin-bottom: 20px;
            font-size: 2.5em;
        }

        .status {
            display: inline-block;
            padding: 8px 16px;
            background: #10b981;
            color: white;
            border-radius: 20px;
            font-weight: bold;
            margin: 20px 0;
            animation: pulse 2s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
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
            align-items: center;
        }

        .label {
            font-weight: bold;
            color: $PRIMARY_COLOR;
        }

        .value {
            font-family: 'Courier New', monospace;
            color: #333;
            background: #f0f0f0;
            padding: 4px 8px;
            border-radius: 4px;
        }

        .footer {
            margin-top: 30px;
            color: #666;
            font-size: 0.9em;
            border-top: 1px solid #e0e0e0;
            padding-top: 20px;
        }

        .timestamp {
            font-size: 0.85em;
            color: #999;
            margin-top: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 $PAGE_TITLE</h1>
        <div class="status">✓ Server Online</div>

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
                <span class="label">Hostname:</span>
                <span class="value">$INSTANCE_HOSTNAME</span>
            </div>
            <div class="info-item">
                <span class="label">Web Server:</span>
                <span class="value">nginx</span>
            </div>
        </div>

        <div class="footer">
            <p><strong>$CHAPTER_NAME</strong></p>
            <p>by Rahul Wagh</p>
            <p class="timestamp">Page generated: $(date)</p>
        </div>
    </div>
</body>
</html>
HTML

# Create health check endpoint
log "Creating health check endpoint..."
cat > /var/www/html/health <<HTML
OK
HTML

# Create a simple text info page
log "Creating info endpoint..."
cat > /var/www/html/info.txt <<EOF
Instance Information
====================
Name: $INSTANCE_NAME
Zone: $INSTANCE_ZONE
IP: $INSTANCE_IP
Hostname: $INSTANCE_HOSTNAME
Generated: $(date)
EOF

# Set proper permissions
chmod 644 /var/www/html/index.html
chmod 644 /var/www/html/health
chmod 644 /var/www/html/info.txt

# Restart nginx to apply changes
log "Restarting nginx..."
systemctl restart nginx

# Enable nginx to start on boot
log "Enabling nginx to start on boot..."
systemctl enable nginx

# Verify nginx is running
if systemctl is-active --quiet nginx; then
    log "✓ Nginx is running successfully!"
else
    log "✗ ERROR: Nginx failed to start!"
    exit 1
fi

# Display success message
log "============================================"
log "✓ Web server setup complete!"
log "============================================"
log "Access the server at: http://$INSTANCE_IP"
log "Health check endpoint: http://$INSTANCE_IP/health"
log "Info endpoint: http://$INSTANCE_IP/info.txt"
log "============================================"
