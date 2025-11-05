# Chapter 2: VPC, Networking, and Compute Instance

## Overview

In this chapter, you'll learn how to create a complete networking infrastructure in Google Cloud Platform using Terraform. We'll set up a custom VPC, subnet, firewall rules, and deploy a compute instance that you can SSH into from your local machine.

## What You'll Learn

- Creating custom VPC networks (no auto-subnets)
- Configuring subnets with specific CIDR ranges
- Setting up firewall rules for SSH and ICMP
- Deploying compute instances with network tags
- Adding SSH keys to VM instances for secure access
- Configuring startup scripts to install nginx
- Using VPC flow logs for network monitoring

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     GCP Project                              │
│                                                              │
│  ┌────────────────────────────────────────────────────────┐ │
│  │  VPC: cl-vpc-sandbox                                   │ │
│  │                                                         │ │
│  │  ┌──────────────────────────────────────────────────┐ │ │
│  │  │  Subnet: cl-sub-sandbox-web-eu-nrth2-01         │ │ │
│  │  │  CIDR: 10.100.1.0/24                            │ │ │
│  │  │  Region: europe-north2                          │ │ │
│  │  │                                                  │ │ │
│  │  │  ┌────────────────────────────────────────┐    │ │ │
│  │  │  │  VM: cl-vm-sandbox-web-01              │    │ │ │
│  │  │  │  Tag: cl-vm-sandbox-allow-ssh-icmp     │    │ │ │
│  │  │  │  Internal IP: 10.100.1.x               │    │ │ │
│  │  │  │  External IP: x.x.x.x                  │    │ │ │
│  │  │  │  • Nginx Web Server                    │    │ │ │
│  │  │  │  • SSH Access Enabled                  │    │ │ │
│  │  │  └────────────────────────────────────────┘    │ │ │
│  │  └──────────────────────────────────────────────────┘ │ │
│  │                                                         │ │
│  │  Firewall Rule: cl-fw-sandbox-allow-ssh-icmp          │ │
│  │  • SSH (TCP:22)                                        │ │
│  │  • ICMP (Ping)                                         │ │
│  │  • Target: cl-vm-sandbox-allow-ssh-icmp tag           │ │
│  └────────────────────────────────────────────────────────┘ │
│                                                              │
└─────────────────────────────────────────────────────────────┘
        ▲
        │ SSH / ICMP
        │
   Your Laptop
```

## Prerequisites

Before you begin, ensure you have:

1. **Completed Chapter 1** or have an existing GCP project
2. **Terraform** installed (version >= 1.0)
3. **Google Cloud SDK** installed and configured
4. **GCP Project** with billing enabled
5. **Authentication** set up:
   ```bash
   gcloud auth application-default login
   ```

## Required GCP APIs

This chapter requires the following APIs to be enabled:

- Compute Engine API (`compute.googleapis.com`)

Enable them using:
```bash
gcloud services enable compute.googleapis.com
```

## Configuration Files

This chapter includes the following Terraform files:

- **provider.tf**: Configures the Google Cloud provider
- **main.tf**: Defines VPC, subnet, firewall rules, and VM instance
- **variables.tf**: Declares input variables
- **outputs.tf**: Defines output values
- **terraform.tfvars**: Configuration values

## Setup Instructions

### Step 1: Update terraform.tfvars

Open `terraform.tfvars` and update the `project_id`:

```hcl
project_id = "YOUR-PROJECT-ID"  # Replace with your actual GCP project ID
```

The SSH public key is already configured. If you want to use a different key, update:

```hcl
ssh_public_key = "your-ssh-public-key-here"
```

### Step 2: Initialize Terraform

Initialize the Terraform working directory:

```bash
terraform init
```

### Step 3: Plan the Deployment

Preview the changes Terraform will make:

```bash
terraform plan
```

You should see:
- 1 VPC network to be created
- 1 subnet to be created
- 1 firewall rule to be created
- 1 compute instance to be created

### Step 4: Apply the Configuration

Create the infrastructure:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

The deployment will take approximately 2-3 minutes.

### Step 5: Verify the Deployment

After successful deployment, Terraform will output important information:

```bash
terraform output
```

Example output:
```
nginx_url = "http://34.88.123.45"
ssh_command = "ssh rahulwagh@34.88.123.45"
vm_external_ip = "34.88.123.45"
vm_internal_ip = "10.100.1.2"
vm_name = "cl-vm-sandbox-web-01"
vpc_name = "cl-vpc-sandbox"
```

## Testing the Infrastructure

### 1. Test ICMP (Ping)

```bash
ping $(terraform output -raw vm_external_ip)
```

Expected output:
```
PING 34.88.123.45 (34.88.123.45): 56 data bytes
64 bytes from 34.88.123.45: icmp_seq=0 ttl=54 time=25.3 ms
```

### 2. Test SSH Access

Get the SSH command:
```bash
terraform output ssh_command
```

Connect to the VM:
```bash
ssh rahulwagh@<VM_EXTERNAL_IP>
```

Or use the shorthand:
```bash
$(terraform output -raw ssh_command)
```

Once connected, verify:
```bash
# Check hostname
hostname

# Check network configuration
ip addr show

# Check nginx status
sudo systemctl status nginx

# Check VPC metadata
curl -H "Metadata-Flavor: Google" http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/network
```

### 3. Test Nginx Web Server

Open a browser or use curl:
```bash
curl $(terraform output -raw nginx_url)
```

Or visit the URL in your browser:
```bash
open $(terraform output -raw nginx_url)  # macOS
```

You should see a custom webpage showing VM details.

### 4. Verify Networking via GCP Console

1. Navigate to [VPC Networks](https://console.cloud.google.com/networking/networks/list)
2. Click on `cl-vpc-sandbox`
3. Verify:
   - VPC mode: Custom
   - Subnets: 1 subnet in europe-north2
   - Firewall rules: cl-fw-sandbox-allow-ssh-icmp

## Understanding the Code

### VPC Network

Creates a custom VPC without auto-created subnets:

```hcl
resource "google_compute_network" "vpc" {
  name                    = "cl-vpc-sandbox"
  auto_create_subnetworks = false
}
```

**Why custom mode?**
- Full control over subnet CIDR ranges
- Better security through explicit subnet creation
- Suitable for production environments

### Subnet

Creates a subnet in a specific region:

```hcl
resource "google_compute_subnetwork" "subnet" {
  name          = "cl-sub-sandbox-web-eu-nrth2-01"
  ip_cidr_range = "10.100.1.0/24"
  region        = "europe-north2"
  network       = google_compute_network.vpc.id

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}
```

**Key points:**
- CIDR `10.100.1.0/24` provides 256 IP addresses (254 usable)
- VPC flow logs enabled for network monitoring
- Regional resource (not zonal)

### Firewall Rules

Creates rules allowing SSH and ICMP:

```hcl
resource "google_compute_firewall" "allow_ssh_icmp" {
  name    = "cl-fw-sandbox-allow-ssh-icmp"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["cl-vm-sandbox-allow-ssh-icmp"]
}
```

**Security notes:**
- Uses network tags for targeting specific VMs
- `source_ranges = ["0.0.0.0/0"]` allows traffic from anywhere
- For production, restrict to specific IP ranges:
  ```hcl
  source_ranges = ["YOUR_HOME_IP/32"]
  ```

### Compute Instance

Creates a VM with nginx:

```hcl
resource "google_compute_instance" "vm" {
  name         = "cl-vm-sandbox-web-01"
  machine_type = "e2-micro"
  zone         = "europe-north2-a"

  tags = ["cl-vm-sandbox-allow-ssh-icmp"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
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

  metadata_startup_script = <<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    systemctl start nginx
  EOF
}
```

**Key features:**
- **Machine type**: e2-micro (free tier eligible)
- **Tags**: Firewall rules target this VM via tags
- **SSH keys**: Injected via metadata
- **Startup script**: Installs and starts nginx
- **Ephemeral IP**: Gets a public IP automatically

## Network Tags vs Firewall Rules

**Network tags** are labels attached to VM instances that firewall rules can target:

```
Firewall Rule                    VM Instance
┌─────────────────────┐         ┌──────────────────────┐
│ Name: allow-ssh-icmp│         │ Name: vm-web-01      │
│ Target Tags:        │─────────▶│ Tags:                │
│ - allow-ssh-icmp    │         │ - allow-ssh-icmp     │
└─────────────────────┘         └──────────────────────┘
```

This allows:
- **Flexibility**: Apply same firewall rule to multiple VMs
- **Security**: Only tagged VMs receive the traffic
- **Scalability**: Add/remove tags without changing firewall rules

## Outputs Explained

After deployment, you'll get these useful outputs:

| Output | Description | Usage |
|--------|-------------|-------|
| `vm_external_ip` | Public IP address | SSH access, browser access |
| `vm_internal_ip` | Private IP within VPC | Internal communication |
| `ssh_command` | Ready-to-use SSH command | Copy and paste to terminal |
| `nginx_url` | URL to nginx web server | Open in browser |
| `vpc_name` | VPC network name | Reference in other resources |
| `subnet_cidr` | Subnet CIDR range | Network planning |

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

Type `yes` when prompted.

**Important**: This will delete:
- The compute instance
- The firewall rule
- The subnet
- The VPC network

## Cost Estimation

Approximate monthly costs (as of 2024):

| Resource | Type | Estimated Cost |
|----------|------|----------------|
| Compute Instance | e2-micro | $7.11/month (free tier: $0) |
| External IP | Ephemeral | $0 (while VM running) |
| Network Egress | First 1GB | Free |
| VPC | Standard | Free |

**Free Tier**: e2-micro instances in certain regions are free tier eligible (up to 1 instance per month).

## Common Issues

### Issue: "External IP is not accessible"

**Solution**:
1. Verify firewall rules are applied:
   ```bash
   gcloud compute firewall-rules list --filter="name=cl-fw-sandbox-allow-ssh-icmp"
   ```

2. Check VM has the correct tag:
   ```bash
   gcloud compute instances describe cl-vm-sandbox-web-01 --zone=europe-north2-a --format="get(tags.items)"
   ```

3. Verify the VM has an external IP:
   ```bash
   terraform output vm_external_ip
   ```

### Issue: "SSH connection refused"

**Solutions**:

1. Wait 2-3 minutes after VM creation for SSH service to start

2. Verify the VM is running:
   ```bash
   gcloud compute instances list --filter="name=cl-vm-sandbox-web-01"
   ```

3. Check SSH key was added correctly:
   ```bash
   gcloud compute instances describe cl-vm-sandbox-web-01 --zone=europe-north2-a --format="get(metadata.items[ssh-keys])"
   ```

4. Try connecting with verbose output:
   ```bash
   ssh -v rahulwagh@<EXTERNAL_IP>
   ```

### Issue: "Permission denied (publickey)"

**Solution**:

1. Verify your SSH key is correct in `terraform.tfvars`

2. If using a different key, ensure the private key is in your SSH agent:
   ```bash
   ssh-add -l
   ssh-add ~/.ssh/id_ed25519
   ```

3. Generate a new key pair if needed:
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

### Issue: "Cannot ping VM"

**Solution**:

1. Verify ICMP is allowed in firewall rule:
   ```bash
   gcloud compute firewall-rules describe cl-fw-sandbox-allow-ssh-icmp
   ```

2. Check VM has the firewall tag:
   ```bash
   gcloud compute instances describe cl-vm-sandbox-web-01 --zone=europe-north2-a --format="get(tags.items)"
   ```

### Issue: "Quota exceeded"

**Error**: `Quota 'CPUS' exceeded`

**Solution**:
1. Check your quotas:
   ```bash
   gcloud compute project-info describe --project=YOUR_PROJECT_ID
   ```

2. Request quota increase in GCP Console
3. Or use a different region with available quota

## Best Practices

1. **Network Security**:
   - Restrict `source_ranges` to your IP: `["YOUR_IP/32"]`
   - Use separate firewall rules for different services
   - Enable VPC Flow Logs for monitoring

2. **SSH Keys**:
   - Use ed25519 keys (more secure than RSA)
   - Rotate keys regularly
   - Never commit private keys to git

3. **Instance Management**:
   - Use startup scripts for configuration
   - Add meaningful labels for organization
   - Use preemptible instances for testing (cheaper)

4. **Network Design**:
   - Plan CIDR ranges to avoid conflicts
   - Use descriptive naming conventions
   - Document your network topology

5. **Cost Optimization**:
   - Use e2-micro for testing (free tier)
   - Delete resources when not in use
   - Use ephemeral IPs (free while VM runs)

## Next Steps

Now that you have networking and compute set up, you can:

- Add more VMs to the same subnet
- Create additional subnets in different regions
- Set up internal load balancing
- Deploy applications on the VM
- Configure Cloud NAT for private VMs
- Implement Cloud Armor for DDoS protection

## Security Considerations

### Production Recommendations

1. **Restrict SSH access**:
   ```hcl
   source_ranges = ["YOUR_OFFICE_IP/32", "YOUR_HOME_IP/32"]
   ```

2. **Use Cloud Identity-Aware Proxy (IAP)**:
   ```bash
   gcloud compute ssh cl-vm-sandbox-web-01 --zone=europe-north2-a --tunnel-through-iap
   ```

3. **Disable external IPs** for VMs that don't need internet access

4. **Use service accounts** with minimal permissions

5. **Enable OS Login** instead of metadata SSH keys:
   ```hcl
   metadata = {
     enable-oslogin = "TRUE"
   }
   ```

## Additional Resources

- [VPC Network Documentation](https://cloud.google.com/vpc/docs)
- [Compute Engine Documentation](https://cloud.google.com/compute/docs)
- [Firewall Rules Best Practices](https://cloud.google.com/vpc/docs/firewalls)
- [VPC Flow Logs](https://cloud.google.com/vpc/docs/using-flow-logs)
- [SSH Key Management](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys)

## Troubleshooting Commands

Quick reference for troubleshooting:

```bash
# List all VPCs
gcloud compute networks list

# List all subnets
gcloud compute networks subnets list

# List all firewall rules
gcloud compute firewall-rules list

# List all VMs
gcloud compute instances list

# Describe specific VM
gcloud compute instances describe cl-vm-sandbox-web-01 --zone=europe-north2-a

# View serial port output (for startup script debugging)
gcloud compute instances get-serial-port-output cl-vm-sandbox-web-01 --zone=europe-north2-a

# SSH into VM
gcloud compute ssh cl-vm-sandbox-web-01 --zone=europe-north2-a
```
