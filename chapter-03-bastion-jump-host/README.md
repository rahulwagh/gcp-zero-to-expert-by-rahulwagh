# Chapter 3: Bastion Host / Jump Server for Private VMs

## Overview

In this chapter, you'll learn how to implement a secure bastion host (jump server) architecture to access private VMs that don't have direct internet access. This is a critical security pattern used in production environments to protect backend infrastructure like databases, application servers, and internal services.

## What You'll Learn

- Creating private subnets without internet access
- Deploying a bastion host / jump server with public access
- Configuring private VMs without external IPs
- Setting up firewall rules for bastion-to-private-VM access
- Using SSH ProxyJump for seamless connections
- Implementing security best practices for jump hosts
- Understanding Private Google Access for VMs without external IPs

## Architecture

```
┌──────────────────────────────────────────────────────────────────────┐
│                         GCP Project                                  │
│                                                                      │
│  ┌────────────────────────────────────────────────────────────────┐ │
│  │  VPC: cl-vpc-sandbox (from Chapter 2)                          │ │
│  │                                                                 │ │
│  │  ┌─────────────────────────────────────────────────────────┐  │ │
│  │  │  Public Subnet: cl-sub-sandbox-web-eu-nrth2-01         │  │ │
│  │  │  CIDR: 10.100.1.0/24                                   │  │ │
│  │  │                                                         │  │ │
│  │  │  ┌──────────────────────────────────────────────┐     │  │ │
│  │  │  │  🌐 Bastion Host                             │     │  │ │
│  │  │  │  VM: cl-vm-sandbox-bastion-01                │     │  │ │
│  │  │  │  Tag: cl-vm-bastion-allow-ssh                │     │  │ │
│  │  │  │  External IP: x.x.x.x ✅                     │     │  │ │
│  │  │  │  Internal IP: 10.100.1.x                     │     │  │ │
│  │  │  └──────────────────────────────────────────────┘     │  │ │
│  │  └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                 │ │
│  │  ┌─────────────────────────────────────────────────────────┐  │ │
│  │  │  Private Subnet: cl-sub-sandbox-private-eu-nrth2-01    │  │ │
│  │  │  CIDR: 10.100.2.0/24                                   │  │ │
│  │  │  🔒 No Internet Gateway                                │  │ │
│  │  │                                                         │  │ │
│  │  │  ┌──────────────────────────────────────────────┐     │  │ │
│  │  │  │  🔐 Private VM (Database)                    │     │  │ │
│  │  │  │  VM: cl-vm-sandbox-private-db-01             │     │  │ │
│  │  │  │  Tag: cl-vm-private-sub-allow-ssh-icmp       │     │  │ │
│  │  │  │  External IP: None ❌                        │     │  │ │
│  │  │  │  Internal IP: 10.100.2.x                     │     │  │ │
│  │  │  │  • PostgreSQL Installed                      │     │  │ │
│  │  │  │  • Only accessible via Bastion               │     │  │ │
│  │  │  └──────────────────────────────────────────────┘     │  │ │
│  │  └─────────────────────────────────────────────────────────┘  │ │
│  │                                                                 │ │
│  │  Firewall Rules:                                               │ │
│  │  • cl-fw-sandbox-bastion-allow-ssh                            │ │
│  │    - SSH (TCP:22) from Internet → Bastion                     │ │
│  │  • cl-fw-sandbox-private-sub-allow-ssh-icmp                   │ │
│  │    - SSH (TCP:22) and ICMP from Bastion → Private VMs         │ │
│  └────────────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────────────┘
        ▲
        │ SSH to Bastion
        │
   Your Laptop
        │
        │ SSH ProxyJump through Bastion
        ▼
   Private VM
```

## Connection Flow

```
You → Internet → Bastion Host (Public IP) → Private VM (Internal IP only)
      SSH to      10.100.1.x                   10.100.2.x
      Bastion
```

## Prerequisites

Before you begin, ensure you have:

1. **Completed Chapter 2** - The VPC `cl-vpc-sandbox` must exist
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
- **main.tf**: Defines private subnet, bastion host, private VM, and firewall rules
- **variables.tf**: Declares input variables
- **outputs.tf**: Defines output values with connection instructions
- **terraform.tfvars**: Configuration values

## Setup Instructions

### Step 1: Ensure Chapter 2 VPC Exists

This chapter uses the VPC created in Chapter 2. Verify it exists:

```bash
gcloud compute networks describe cl-vpc-sandbox
```

If it doesn't exist, go back and complete Chapter 2 first.

### Step 2: Update terraform.tfvars

Open `terraform.tfvars` and verify/update the `project_id`:

```hcl
project_id = "YOUR-PROJECT-ID"  # Replace with your actual GCP project ID
```

The SSH public key is already configured. If you want to use a different key, update:

```hcl
ssh_public_key = "your-ssh-public-key-here"
```

### Step 3: Initialize Terraform

Initialize the Terraform working directory:

```bash
cd chapter-03-bastion-jump-host
terraform init
```

### Step 4: Plan the Deployment

Preview the changes Terraform will make:

```bash
terraform plan
```

You should see:
- 1 private subnet to be created
- 2 firewall rules to be created
- 2 compute instances to be created (bastion + private VM)

### Step 5: Apply the Configuration

Create the infrastructure:

```bash
terraform apply
```

Type `yes` when prompted to confirm.

The deployment will take approximately 2-3 minutes.

### Step 6: View Connection Instructions

After successful deployment, Terraform will output connection instructions:

```bash
terraform output connection_instructions
```

Example output:
```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    BASTION HOST CONNECTION GUIDE                          ║
╚═══════════════════════════════════════════════════════════════════════════╝

Step 1: Connect to Bastion Host
─────────────────────────────────────────────────────────────────────────────
ssh rahulwagh@34.88.123.45

Step 2: From Bastion, Connect to Private VM
─────────────────────────────────────────────────────────────────────────────
ssh rahulwagh@10.100.2.2

One-liner using SSH ProxyJump:
─────────────────────────────────────────────────────────────────────────────
ssh -J rahulwagh@34.88.123.45 rahulwagh@10.100.2.2
```

## Testing the Infrastructure

### 1. Connect to Bastion Host

Get the SSH command for the bastion host:

```bash
terraform output bastion_ssh_command
```

Connect to the bastion:

```bash
ssh rahulwagh@<BASTION_EXTERNAL_IP>
```

You should see a welcome message indicating you're on the bastion host.

### 2. Test Connectivity from Bastion to Private VM

From the bastion host, ping the private VM:

```bash
ping $(terraform output -raw private_vm_internal_ip)
```

Expected output:
```
PING 10.100.2.2 (10.100.2.2): 56 data bytes
64 bytes from 10.100.2.2: icmp_seq=0 ttl=64 time=1.2 ms
```

### 3. SSH to Private VM from Bastion

From the bastion host, SSH to the private VM:

```bash
ssh rahulwagh@<PRIVATE_VM_INTERNAL_IP>
```

Or use the command from outputs:

```bash
terraform output private_vm_ssh_command
```

You should see the private VM's welcome message and be logged in.

### 4. Test with SSH ProxyJump (One Command)

From your local machine, you can connect directly to the private VM using SSH ProxyJump:

```bash
ssh -J rahulwagh@<BASTION_EXTERNAL_IP> rahulwagh@<PRIVATE_VM_INTERNAL_IP>
```

This establishes a connection through the bastion host automatically.

### 5. Verify Private VM Has No External IP

Check that the private VM truly has no external IP:

```bash
gcloud compute instances describe cl-vm-sandbox-private-db-01 \
  --zone=europe-north2-a \
  --format="get(networkInterfaces[0].accessConfigs)"
```

Expected output: (empty) - meaning no external IP configured.

### 6. Verify PostgreSQL on Private VM

SSH to the private VM and check PostgreSQL:

```bash
# From your local machine, use ProxyJump:
ssh -J rahulwagh@<BASTION_IP> rahulwagh@<PRIVATE_VM_IP>

# Once on the private VM:
sudo systemctl status postgresql
```

## Understanding the Code

### Data Source: Existing VPC

References the VPC created in Chapter 2:

```hcl
data "google_compute_network" "vpc" {
  name = "cl-vpc-sandbox"
}
```

**Important**: This chapter depends on Chapter 2's VPC existing.

### Private Subnet

Creates a subnet without internet access:

```hcl
resource "google_compute_subnetwork" "private_subnet" {
  name          = "cl-sub-sandbox-private-eu-nrth2-01"
  ip_cidr_range = "10.100.2.0/24"
  region        = "europe-north2"
  network       = data.google_compute_network.vpc.id

  private_ip_google_access = true
}
```

**Key points:**
- CIDR `10.100.2.0/24` provides 256 IP addresses
- `private_ip_google_access = true` allows VMs to access Google APIs without external IPs
- No Cloud NAT configured (VMs can't reach internet)

### Bastion Host Firewall

Allows SSH access from the internet to the bastion:

```hcl
resource "google_compute_firewall" "bastion_allow_ssh" {
  name    = "cl-fw-sandbox-bastion-allow-ssh"
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["cl-vm-bastion-allow-ssh"]
}
```

**Security note:** For production, restrict `source_ranges` to your office/home IP.

### Private Subnet Firewall

Allows SSH and ICMP from bastion to private VMs:

```hcl
resource "google_compute_firewall" "private_allow_ssh_icmp" {
  name    = "cl-fw-sandbox-private-sub-allow-ssh-icmp"
  network = data.google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  allow {
    protocol = "icmp"
  }

  source_tags = ["cl-vm-bastion-allow-ssh"]
  target_tags = ["cl-vm-private-sub-allow-ssh-icmp"]
}
```

**Key points:**
- Uses `source_tags` to only allow traffic from bastion
- Uses `target_tags` to only allow traffic to private VMs
- More secure than IP-based rules (tags move with VMs)

### Bastion Host

Creates a VM with external IP in public subnet:

```hcl
resource "google_compute_instance" "bastion" {
  name = "cl-vm-sandbox-bastion-01"
  tags = ["cl-vm-bastion-allow-ssh"]

  network_interface {
    network    = data.google_compute_network.vpc.id
    subnetwork = "cl-sub-sandbox-web-eu-nrth2-01"

    access_config {
      # Ephemeral public IP
    }
  }
}
```

**Key features:**
- Has a public IP via `access_config`
- Located in the public subnet from Chapter 2
- Tagged for SSH access from internet

### Private VM

Creates a VM without external IP in private subnet:

```hcl
resource "google_compute_instance" "private_vm" {
  name = "cl-vm-sandbox-private-db-01"
  tags = ["cl-vm-private-sub-allow-ssh-icmp"]

  network_interface {
    subnetwork = google_compute_subnetwork.private_subnet.id
    # NO access_config = no external IP
  }
}
```

**Key features:**
- **No `access_config` block** = no external IP
- Only accessible via internal network
- Can still access Google APIs via Private Google Access

## Bastion Host Security Best Practices

### 1. Restrict Source IP Ranges

For production, limit SSH access to specific IPs:

```hcl
# In main.tf, modify bastion firewall rule:
source_ranges = ["YOUR_OFFICE_IP/32", "YOUR_HOME_IP/32"]
```

### 2. Use SSH Keys Only (No Passwords)

Always use SSH keys, never passwords:

```hcl
metadata = {
  ssh-keys = "${var.ssh_user}:${var.ssh_public_key}"
  block-project-ssh-keys = "true"  # Block project-wide SSH keys
}
```

### 3. Enable OS Login

For production, use OS Login instead of metadata SSH keys:

```hcl
metadata = {
  enable-oslogin = "TRUE"
}
```

Then grant access via IAM:

```bash
gcloud compute instances add-iam-policy-binding cl-vm-sandbox-bastion-01 \
  --zone=europe-north2-a \
  --member=user:you@example.com \
  --role=roles/compute.osLogin
```

### 4. Audit Logging

Enable audit logging for the bastion host:

```bash
# View SSH login attempts
gcloud logging read "resource.type=gce_instance AND resource.labels.instance_id=BASTION_INSTANCE_ID" \
  --limit 50 \
  --format json
```

### 5. Minimal Tools on Bastion

Keep the bastion host minimal - only install tools needed for SSH proxying and basic diagnostics.

### 6. Regular Updates

Automate security updates:

```bash
# Add to bastion startup script
apt-get update
apt-get upgrade -y
apt-get install -y unattended-upgrades
```

## SSH Configuration Tips

### Configure SSH Config File

Add this to your `~/.ssh/config` for easier access:

```bash
# Bastion Host
Host bastion
  HostName <BASTION_EXTERNAL_IP>
  User rahulwagh
  IdentityFile ~/.ssh/id_ed25519

# Private VM via Bastion
Host private-db
  HostName <PRIVATE_VM_INTERNAL_IP>
  User rahulwagh
  ProxyJump bastion
  IdentityFile ~/.ssh/id_ed25519
```

Then simply connect with:

```bash
ssh bastion          # Connect to bastion
ssh private-db       # Connect to private VM via bastion
```

### SSH Agent Forwarding

Enable agent forwarding to use your local SSH keys on the bastion:

```bash
ssh -A rahulwagh@<BASTION_IP>
```

Or in `~/.ssh/config`:

```bash
Host bastion
  ForwardAgent yes
```

**Security warning:** Only use agent forwarding with trusted bastion hosts.

## Outputs Explained

After deployment, you'll get these useful outputs:

| Output | Description | Usage |
|--------|-------------|-------|
| `bastion_external_ip` | Public IP of bastion host | SSH from your laptop |
| `bastion_internal_ip` | Internal IP of bastion | Reference for firewall rules |
| `private_vm_internal_ip` | Internal IP of private VM | SSH from bastion |
| `bastion_ssh_command` | SSH command for bastion | Copy and paste to terminal |
| `private_vm_ssh_command` | SSH command for private VM | Run from bastion |
| `connection_instructions` | Full connection guide | Step-by-step instructions |

## Cleanup

To destroy all resources created in this chapter:

```bash
terraform destroy
```

Type `yes` when prompted.

**Important**: This will delete:
- The private VM
- The bastion host
- The private subnet
- The firewall rules

The VPC from Chapter 2 will remain intact.

## Cost Estimation

Approximate monthly costs (as of 2024):

| Resource | Type | Estimated Cost |
|----------|------|----------------|
| Bastion Host | e2-micro | $7.11/month (free tier: $0) |
| Private VM | e2-micro | $7.11/month (free tier: $0) |
| External IP (Bastion) | Ephemeral | $0 (while VM running) |
| Private Subnet | Standard | Free |

**Free Tier**: You can run 1 e2-micro instance for free. The second e2-micro will be charged.

**Total**: ~$7.11/month (or $0 if using only 1 free tier instance)

## Common Issues

### Issue: "Cannot connect to private VM from bastion"

**Solutions**:

1. Verify firewall rule is applied:
   ```bash
   gcloud compute firewall-rules describe cl-fw-sandbox-private-sub-allow-ssh-icmp
   ```

2. Check both VMs have correct tags:
   ```bash
   # Bastion should have: cl-vm-bastion-allow-ssh
   gcloud compute instances describe cl-vm-sandbox-bastion-01 \
     --zone=europe-north2-a \
     --format="get(tags.items)"

   # Private VM should have: cl-vm-private-sub-allow-ssh-icmp
   gcloud compute instances describe cl-vm-sandbox-private-db-01 \
     --zone=europe-north2-a \
     --format="get(tags.items)"
   ```

3. Test connectivity from bastion:
   ```bash
   # From bastion host
   ping 10.100.2.2
   telnet 10.100.2.2 22
   ```

### Issue: "VPC not found"

**Error**: `Error: google_compute_network.vpc: network "cl-vpc-sandbox" not found`

**Solution**:

1. Verify Chapter 2's VPC exists:
   ```bash
   gcloud compute networks list
   ```

2. If it doesn't exist, go back and complete Chapter 2:
   ```bash
   cd ../chapter-02-vpc-networking-compute
   terraform apply
   ```

### Issue: "Subnet CIDR conflicts"

**Error**: `Error: overlapping CIDR ranges`

**Solution**: The private subnet (10.100.2.0/24) must not overlap with Chapter 2's subnet (10.100.1.0/24). They are already configured correctly.

### Issue: "SSH ProxyJump not working"

**Solutions**:

1. Ensure your SSH client supports ProxyJump (OpenSSH >= 7.3):
   ```bash
   ssh -V
   ```

2. Use older `-o ProxyCommand` syntax if needed:
   ```bash
   ssh -o ProxyCommand="ssh -W %h:%p rahulwagh@<BASTION_IP>" rahulwagh@<PRIVATE_VM_IP>
   ```

3. Check SSH keys are added to agent:
   ```bash
   ssh-add -l
   ssh-add ~/.ssh/id_ed25519
   ```

## Best Practices

1. **Network Segmentation**:
   - Keep public-facing resources in public subnets
   - Keep backend resources (databases, app servers) in private subnets
   - Use bastion hosts as the only entry point

2. **Bastion Host Hardening**:
   - Restrict SSH source IPs to known locations
   - Enable audit logging for all connections
   - Regularly update and patch the bastion host
   - Use OS Login for centralized access management

3. **Firewall Rules**:
   - Use network tags instead of IP ranges
   - Follow principle of least privilege
   - Document all firewall rules clearly

4. **SSH Key Management**:
   - Rotate SSH keys regularly
   - Use different keys for different environments
   - Never commit private keys to git
   - Consider using SSH certificates

5. **Monitoring**:
   - Enable VPC Flow Logs on private subnet
   - Set up alerts for unusual SSH activity
   - Monitor bastion host for unauthorized access attempts

## Alternative Architectures

### 1. Cloud IAP (Identity-Aware Proxy)

Instead of a bastion host, use Cloud IAP for zero-trust access:

```bash
gcloud compute ssh cl-vm-sandbox-private-db-01 \
  --zone=europe-north2-a \
  --tunnel-through-iap
```

**Pros**:
- No bastion host to manage
- Built-in IAM integration
- Better security with context-aware access

**Cons**:
- Requires additional IAP setup
- May have latency overhead

### 2. Cloud VPN

Use Cloud VPN to connect your on-premises network to GCP:

**Pros**:
- Private VMs accessible as if local
- No public bastion host needed

**Cons**:
- More complex setup
- Additional costs

### 3. Dedicated Bastion Subnet

Create a dedicated subnet just for bastion hosts:

```hcl
resource "google_compute_subnetwork" "bastion_subnet" {
  name          = "cl-sub-sandbox-bastion-eu-nrth2-01"
  ip_cidr_range = "10.100.254.0/24"
  region        = "europe-north2"
  network       = data.google_compute_network.vpc.id
}
```

**Pros**:
- Better network isolation
- Easier to apply specific security controls

## Next Steps

Now that you have a bastion host setup, you can:

- Add more private VMs in the private subnet
- Set up Cloud NAT for private VMs to access the internet (outbound only)
- Deploy databases (Cloud SQL, self-hosted PostgreSQL, MySQL)
- Implement Cloud IAP as an alternative to bastion hosts
- Set up VPN for site-to-site connectivity
- Configure load balancers for private backends

## Security Considerations

### Production Recommendations

1. **Restrict Bastion Access**:
   ```hcl
   source_ranges = ["YOUR_OFFICE_IP/32"]
   ```

2. **Use Cloud IAP** instead of public bastion:
   ```bash
   gcloud compute instances add-iam-policy-binding private-vm \
     --member=user:you@example.com \
     --role=roles/iap.tunnelResourceAccessor
   ```

3. **Enable OS Login**:
   ```hcl
   metadata = {
     enable-oslogin = "TRUE"
   }
   ```

4. **Implement MFA** for SSH access using OS Login with 2FA

5. **Use Service Accounts** with minimal permissions for VMs

6. **Regular Security Audits**:
   ```bash
   gcloud compute instances list --format="table(name,zone,networkInterfaces[].accessConfigs[0].natIP)"
   ```

## Additional Resources

- [VPC Network Documentation](https://cloud.google.com/vpc/docs)
- [Bastion Host Best Practices](https://cloud.google.com/solutions/connecting-securely)
- [Cloud IAP for TCP Forwarding](https://cloud.google.com/iap/docs/using-tcp-forwarding)
- [OS Login Documentation](https://cloud.google.com/compute/docs/oslogin)
- [Private Google Access](https://cloud.google.com/vpc/docs/private-google-access)

## Troubleshooting Commands

Quick reference for troubleshooting:

```bash
# List all VMs and their IPs
gcloud compute instances list --format="table(name,zone,networkInterfaces[].networkIP,networkInterfaces[].accessConfigs[0].natIP)"

# Describe bastion host
gcloud compute instances describe cl-vm-sandbox-bastion-01 --zone=europe-north2-a

# Describe private VM
gcloud compute instances describe cl-vm-sandbox-private-db-01 --zone=europe-north2-a

# List firewall rules
gcloud compute firewall-rules list --filter="network:cl-vpc-sandbox"

# Test SSH connectivity
gcloud compute ssh cl-vm-sandbox-bastion-01 --zone=europe-north2-a

# Test IAP tunnel
gcloud compute ssh cl-vm-sandbox-private-db-01 --zone=europe-north2-a --tunnel-through-iap

# View VPC Flow Logs
gcloud logging read "resource.type=gce_subnetwork AND resource.labels.subnetwork_name=cl-sub-sandbox-private-eu-nrth2-01" \
  --limit 10 \
  --format json
```

## Diagram: Network Tags and Firewall Flow

```
Internet (0.0.0.0/0)
        │
        │ SSH (TCP:22)
        ▼
┌─────────────────────────────────────────┐
│ Firewall Rule:                          │
│ cl-fw-sandbox-bastion-allow-ssh         │
│ • Allow: TCP:22                         │
│ • Source: 0.0.0.0/0                     │
│ • Target Tag: cl-vm-bastion-allow-ssh   │
└─────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────┐
│ Bastion Host                            │
│ • Tag: cl-vm-bastion-allow-ssh          │
│ • External IP: ✅                       │
│ • Subnet: Public (10.100.1.0/24)        │
└─────────────────────────────────────────┘
        │
        │ SSH (TCP:22) + ICMP
        ▼
┌─────────────────────────────────────────────────┐
│ Firewall Rule:                                  │
│ cl-fw-sandbox-private-sub-allow-ssh-icmp        │
│ • Allow: TCP:22, ICMP                           │
│ • Source Tag: cl-vm-bastion-allow-ssh           │
│ • Target Tag: cl-vm-private-sub-allow-ssh-icmp  │
└─────────────────────────────────────────────────┘
        │
        ▼
┌─────────────────────────────────────────┐
│ Private VM                              │
│ • Tag: cl-vm-private-sub-allow-ssh-icmp │
│ • External IP: ❌                       │
│ • Subnet: Private (10.100.2.0/24)       │
└─────────────────────────────────────────┘
```

---

**Congratulations!** You've successfully implemented a secure bastion host architecture with private VMs. This is a fundamental pattern used in production GCP deployments.
