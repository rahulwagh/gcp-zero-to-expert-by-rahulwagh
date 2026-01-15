# 🛠️ Utility Scripts

This directory contains reusable scripts for GCP infrastructure setup and configuration.

---

## 📁 Available Scripts

### 1. `install-nginx-with-custom-page.sh`

A robust nginx installation script that handles apt lock conflicts and creates a custom landing page with instance metadata.

#### ✨ Features:
- ✅ Waits for cloud-init and apt locks (prevents boot-time conflicts)
- ✅ Installs and configures nginx
- ✅ Creates beautiful custom HTML landing page
- ✅ Shows instance metadata (name, zone, IP, hostname)
- ✅ Creates `/health` endpoint for load balancer health checks
- ✅ Creates `/info.txt` endpoint for quick text-based info
- ✅ Configures nginx to start on boot
- ✅ Customizable colors and branding

#### 🚀 Usage:

##### Option 1: As GCP VM Startup Script (Console)

1. Create a new VM instance in Google Cloud Console
2. Expand **"Management, security, disks, networking, sole tenancy"**
3. Under **"Management"** → **"Automation"** → **"Startup script"**
4. Paste the contents of `install-nginx-with-custom-page.sh`
5. Click **"Create"**

##### Option 2: With Terraform

```hcl
resource "google_compute_instance" "web_server" {
  name         = "web-server-01"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  network_interface {
    network = "default"
    access_config {}
  }

  metadata_startup_script = file("${path.module}/scripts/install-nginx-with-custom-page.sh")
}
```

##### Option 3: Direct Download and Execute

```bash
# Download and run on an existing VM
wget https://raw.githubusercontent.com/rahulwagh/gcp-zero-to-expert-by-rahulwagh/main/scripts/install-nginx-with-custom-page.sh

# Make executable
chmod +x install-nginx-with-custom-page.sh

# Run as root
sudo bash install-nginx-with-custom-page.sh
```

##### Option 4: With Custom Branding

```bash
# Set custom environment variables before running
export PAGE_TITLE="My Custom App"
export PAGE_GRADIENT="linear-gradient(135deg, #f093fb 0%, #f5576c 100%)"
export PRIMARY_COLOR="#f5576c"
export CHAPTER_NAME="My Project Name"

sudo bash install-nginx-with-custom-page.sh
```

#### 🎨 Customization Options:

You can customize the appearance by setting environment variables:

| Variable | Description | Default |
|----------|-------------|---------|
| `PAGE_TITLE` | Main page title | `Load Balancer Backend` |
| `PAGE_GRADIENT` | Background gradient CSS | Purple gradient |
| `PRIMARY_COLOR` | Primary accent color | `#667eea` |
| `CHAPTER_NAME` | Footer chapter/project name | `GCP Zero to Expert` |

#### 📊 Example Custom Colors:

```bash
# Blue theme
export PAGE_GRADIENT="linear-gradient(135deg, #667eea 0%, #764ba2 100%)"
export PRIMARY_COLOR="#667eea"

# Pink/Red theme
export PAGE_GRADIENT="linear-gradient(135deg, #f093fb 0%, #f5576c 100%)"
export PRIMARY_COLOR="#f5576c"

# Green theme
export PAGE_GRADIENT="linear-gradient(135deg, #0ba360 0%, #3cba92 100%)"
export PRIMARY_COLOR="#0ba360"

# Orange theme
export PAGE_GRADIENT="linear-gradient(135deg, #f2994a 0%, #f2c94c 100%)"
export PRIMARY_COLOR="#f2994a"
```

#### 🧪 Testing:

After installation, test the endpoints:

```bash
# Test main page
curl http://INSTANCE_IP/

# Test health check
curl http://INSTANCE_IP/health
# Expected output: OK

# Test info endpoint
curl http://INSTANCE_IP/info.txt
# Shows instance details in plain text
```

#### 🔍 Troubleshooting:

**Check if nginx is running:**
```bash
sudo systemctl status nginx
```

**View startup script logs:**
```bash
# On the VM
sudo journalctl -u google-startup-scripts.service
```

**Check nginx error logs:**
```bash
sudo tail -f /var/log/nginx/error.log
```

**Manually restart nginx:**
```bash
sudo systemctl restart nginx
```

#### 📋 What Gets Created:

| File | Purpose |
|------|---------|
| `/var/www/html/index.html` | Custom landing page with instance metadata |
| `/var/www/html/health` | Health check endpoint (returns "OK") |
| `/var/www/html/info.txt` | Plain text instance information |

---

## 🎯 Use Cases

### Load Balancer Backends
Perfect for creating backend instances that show which server is responding:
- External Load Balancers (Chapter 5)
- Internal Load Balancers (Chapter 6)
- Regional/Global load balancers

### Web Server Testing
Quick way to spin up a web server for testing:
- Network connectivity
- Firewall rules
- VPC peering
- Cloud NAT

### Demos and Presentations
Create professional-looking demo pages that show:
- Instance metadata
- Load balancing in action
- Auto-scaling behavior

---

## 📦 Adding More Scripts

To add more utility scripts to this directory:

1. Create a descriptive filename (use kebab-case)
2. Add a shebang line (`#!/bin/bash`)
3. Include comprehensive comments
4. Update this README with usage instructions
5. Test thoroughly before committing

---

## 🤝 Contributing

Found a bug or have an improvement? Feel free to:
1. Open an issue
2. Submit a pull request
3. Suggest new utility scripts

---

## 📄 License

These scripts are part of the GCP Zero to Expert course and are licensed under MIT License.

---

**Happy Scripting! 🚀**

*Part of GCP Zero to Expert by Rahul Wagh*
