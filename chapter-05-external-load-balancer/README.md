# Chapter 5: External HTTP(S) Load Balancer

> ⚖️ **Learn**: Set up a global HTTP load balancer with auto-healing and high availability

## 📚 What You'll Learn

In this chapter, you'll learn how to:
- ✅ Create an **Instance Template** for uniform VM creation
- ✅ Set up a **Managed Instance Group (MIG)** with auto-healing
- ✅ Configure **Health Checks** for backend monitoring
- ✅ Deploy an **External HTTP Load Balancer**
- ✅ Implement **Traffic Distribution** across multiple instances
- ✅ Enable **Auto-Healing** for failed instances
- ✅ Monitor and test load balancer performance

---

## 🎯 Chapter Objectives

By the end of this chapter, you will:
1. Understand GCP load balancer architecture
2. Create instance templates and managed instance groups
3. Configure health checks and backend services
4. Set up URL maps and forwarding rules
5. Test load distribution and failover
6. Monitor load balancer metrics

---

## 🏗️ Architecture Overview

```
                          ┌─────────────────┐
                          │    Internet     │
                          └────────┬────────┘
                                   │
                                   │ HTTP Traffic
                                   ▼
                    ┌──────────────────────────┐
                    │  Global Load Balancer    │
                    │  (Forwarding Rule)       │
                    │  External IP: X.X.X.X    │
                    └──────────┬───────────────┘
                               │
                               │ Routes via HTTP Proxy
                               ▼
                    ┌──────────────────────┐
                    │     URL Map          │
                    │  (Routing Rules)     │
                    └──────────┬───────────┘
                               │
                               │ Forwards to
                               ▼
                    ┌──────────────────────┐
                    │  Backend Service     │
                    │  (Health Checks)     │
                    └──────────┬───────────┘
                               │
              ┌────────────────┼────────────────┐
              │                                 │
              ▼                                 ▼
    ┌──────────────────┐            ┌──────────────────┐
    │  Backend VM 1    │            │  Backend VM 2    │
    │  (nginx)         │            │  (nginx)         │
    │  Health: ✓       │            │  Health: ✓       │
    └──────────────────┘            └──────────────────┘
              ▲                                 ▲
              └─────────────────┬───────────────┘
                                │
                    ┌───────────────────────┐
                    │ Managed Instance Group│
                    │  (Auto-Healing)       │
                    └───────────────────────┘
```

---

## 📋 Prerequisites

Before starting this chapter, ensure you have completed:

1. ✅ **Chapter 2**: VPC, Networking, and Compute Instance
   - VPC network `cl-vpc-sandbox` must exist
   - Subnet `cl-sub-sandbox-web-eu-nrth2-01` must exist

---

## 🚀 Quick Start

### 1️⃣ Initialize Terraform

```bash
cd chapter-05-external-load-balancer
terraform init
```

### 2️⃣ Review Configuration

```bash
# Check the terraform.tfvars file
cat terraform.tfvars

# Review the execution plan
terraform plan
```

### 3️⃣ Deploy Load Balancer

```bash
terraform apply

# Review the changes and type 'yes' to confirm
```

### 4️⃣ Wait for Deployment

⏱️ **Important**: Load balancer deployment takes 5-10 minutes!

```bash
# Check deployment status
gcloud compute forwarding-rules list

# Monitor backend health
gcloud compute backend-services get-health cl-lb-sandbox-web-backend-service --global
```

### 5️⃣ Test the Load Balancer

```bash
# Get the load balancer IP
LB_IP=$(terraform output -raw load_balancer_ip)

# Access in browser
echo "Open this URL in your browser: http://$LB_IP"

# Test with curl
curl http://$LB_IP

# Test load distribution (run multiple times)
for i in {1..10}; do
  curl -s http://$LB_IP | grep "Instance Name"
  sleep 1
done
```

---

## 📁 Files in This Chapter

| File | Purpose |
|------|---------|
| `main.tf` | Load balancer components configuration |
| `provider.tf` | Terraform and GCP provider setup |
| `variables.tf` | Input variables for customization |
| `outputs.tf` | Output values and instructions |
| `terraform.tfvars` | Configuration values |
| `README.md` | This documentation file |

---

## 🔍 What's Being Created

### 1. Instance Template

**Resource**: `google_compute_instance_template`
- **Name**: `cl-template-sandbox-web-lb`
- **Machine Type**: e2-micro
- **OS Image**: Debian 11
- **Startup Script**: Installs nginx with custom page
- **Network Tag**: `web-backend`

### 2. Managed Instance Group (MIG)

**Resource**: `google_compute_instance_group_manager`
- **Name**: `cl-mig-sandbox-web-lb`
- **Instance Count**: 2 (configurable)
- **Auto-Healing**: Enabled with 5-minute initial delay
- **Update Policy**: Rolling updates (max 1 surge, 1 unavailable)

### 3. Health Check

**Resource**: `google_compute_health_check`
- **Protocol**: HTTP
- **Port**: 80
- **Path**: `/health`
- **Check Interval**: 5 seconds
- **Healthy Threshold**: 2 consecutive successes
- **Unhealthy Threshold**: 2 consecutive failures

### 4. Backend Service

**Resource**: `google_compute_backend_service`
- **Load Balancing Mode**: UTILIZATION
- **Max Utilization**: 80%
- **Session Affinity**: None (for even distribution)
- **Connection Draining**: 300 seconds

### 5. URL Map

**Resource**: `google_compute_url_map`
- **Default Service**: Backend service
- **Routing**: All traffic to backend

### 6. HTTP Proxy

**Resource**: `google_compute_target_http_proxy`
- **Protocol**: HTTP
- **URL Map**: Routes to backend service

### 7. Global Forwarding Rule

**Resource**: `google_compute_global_forwarding_rule`
- **External IP**: Auto-assigned
- **Port**: 80
- **Load Balancing Scheme**: EXTERNAL_MANAGED

### 8. Firewall Rules

**Resources**: 2 firewall rules
- **Health Check Rule**: Allows Google health checkers (35.191.0.0/16, 130.211.0.0/22)
- **Web Traffic Rule**: Allows HTTP from internet (0.0.0.0/0)

---

## 🎓 Key Concepts

### What is an External HTTP(S) Load Balancer?

An External HTTP(S) Load Balancer is a **global** load balancer that:
- Distributes HTTP/HTTPS traffic across multiple backend instances
- Provides a single global IP address
- Automatically routes to the nearest healthy backend
- Scales seamlessly with traffic

### Load Balancer Components

```
┌──────────────────────┐
│ Forwarding Rule      │ ← External IP address (entry point)
└──────────┬───────────┘
           │
┌──────────▼───────────┐
│ Target Proxy         │ ← HTTP/HTTPS termination
└──────────┬───────────┘
           │
┌──────────▼───────────┐
│ URL Map              │ ← Routing rules
└──────────┬───────────┘
           │
┌──────────▼───────────┐
│ Backend Service      │ ← Health checks, session affinity
└──────────┬───────────┘
           │
┌──────────▼───────────┐
│ Instance Group       │ ← Your backend VMs
└──────────────────────┘
```

### Managed Instance Groups (MIG)

A MIG is a collection of identical VM instances managed as a single entity:

**Benefits:**
- ✅ **Auto-Healing**: Recreates unhealthy instances
- ✅ **Auto-Scaling**: Adjusts instance count based on load
- ✅ **Rolling Updates**: Deploy updates without downtime
- ✅ **Multi-Zone**: Distribute across zones for HA

### Health Checks

Health checks determine if backends can serve traffic:

**Health Check Flow:**
```
1. Load Balancer → HTTP GET /health → Backend
2. Backend → HTTP 200 OK → Load Balancer
3. Load Balancer marks backend as HEALTHY ✓
```

**If check fails:**
```
1. Load Balancer → HTTP GET /health → Backend
2. Backend → No response / Error → Load Balancer
3. After 2 failures → Backend marked UNHEALTHY ✗
4. MIG recreates the instance (auto-healing)
```

---

## 🧪 Testing & Validation

### Test 1: Basic Connectivity

```bash
LB_IP=$(terraform output -raw load_balancer_ip)
curl http://$LB_IP
```

**Expected**: HTML page with instance details

### Test 2: Load Distribution

```bash
# Run 20 requests and see different backends respond
for i in {1..20}; do
  echo "Request $i:"
  curl -s http://$LB_IP | grep "Instance Name"
  echo ""
  sleep 0.5
done
```

**Expected**: Requests distributed across different instances

### Test 3: Backend Health

```bash
gcloud compute backend-services get-health cl-lb-sandbox-web-backend-service --global
```

**Expected**: All instances showing `HEALTHY`

### Test 4: Auto-Healing

```bash
# 1. List instances
gcloud compute instance-groups managed list-instances cl-mig-sandbox-web-lb \
  --zone=europe-north2-a

# 2. SSH into one instance and stop nginx
gcloud compute ssh <instance-name> --zone=europe-north2-a
sudo systemctl stop nginx
exit

# 3. Watch health check fail
gcloud compute backend-services get-health cl-lb-sandbox-web-backend-service --global

# 4. Watch instance get recreated (takes ~5 minutes)
watch -n 10 'gcloud compute instance-groups managed list-instances cl-mig-sandbox-web-lb --zone=europe-north2-a'
```

**Expected**: Failed instance is automatically recreated

### Test 5: Performance Testing

```bash
# Install Apache Bench (if not installed)
# macOS: brew install apache-bench
# Ubuntu: sudo apt-get install apache2-utils

# Run load test
ab -n 1000 -c 10 http://$LB_IP/
```

**Expected**: See request distribution and latency metrics

---

## 📊 Monitoring & Observability

### Cloud Console Monitoring

1. **Load Balancer Dashboard**:
   ```
   https://console.cloud.google.com/net-services/loadbalancing/list/loadBalancers
   ```

2. **Backend Health**:
   ```
   https://console.cloud.google.com/net-services/loadbalancing/backends/list
   ```

3. **Instance Group**:
   ```
   https://console.cloud.google.com/compute/instanceGroups/list
   ```

### CLI Monitoring

```bash
# Backend service details
gcloud compute backend-services describe cl-lb-sandbox-web-backend-service --global

# Instance group status
gcloud compute instance-groups managed describe cl-mig-sandbox-web-lb \
  --zone=europe-north2-a

# List all instances
gcloud compute instances list --filter="name~web-backend"

# View load balancer metrics
gcloud monitoring time-series list \
  --filter='resource.type="http_load_balancer"'
```

### Key Metrics to Monitor

| Metric | Description | Alert Threshold |
|--------|-------------|-----------------|
| Request Count | Total requests/sec | - |
| Error Rate | 5xx errors | > 1% |
| Latency | Response time | > 1000ms |
| Backend Health | Healthy instances | < 50% |
| Traffic Distribution | Even distribution | - |

---

## 🔧 Scaling the Instance Group

### Manual Scaling

```bash
# Scale up to 4 instances
terraform apply -var="mig_target_size=4"

# Scale down to 1 instance
terraform apply -var="mig_target_size=1"
```

### Auto-Scaling (Manual Configuration)

To enable auto-scaling, add to `main.tf`:

```hcl
resource "google_compute_autoscaler" "web_backend" {
  name   = "cl-autoscaler-sandbox-web-lb"
  zone   = var.zone
  target = google_compute_instance_group_manager.web_backend.id

  autoscaling_policy {
    max_replicas    = 10
    min_replicas    = 2
    cooldown_period = 60

    cpu_utilization {
      target = 0.6
    }
  }
}
```

---

## 💡 Best Practices

### Load Balancer Design

- ✅ Use managed instance groups for auto-healing
- ✅ Configure appropriate health check intervals
- ✅ Set connection draining timeout (300s recommended)
- ✅ Use session affinity only when required
- ✅ Enable Cloud CDN for static content

### Instance Template

- ✅ Use startup scripts for consistent configuration
- ✅ Keep images up-to-date
- ✅ Tag instances for firewall rules
- ✅ Use small machine types initially, scale as needed

### Health Checks

- ✅ Create dedicated health check endpoint
- ✅ Set realistic healthy/unhealthy thresholds
- ✅ Use initial delay for slow-starting apps
- ✅ Monitor health check failures

### Security

- ✅ Restrict firewall rules to necessary ports
- ✅ Use HTTPS in production (configure SSL certs)
- ✅ Implement Cloud Armor for DDoS protection
- ✅ Use VPC Service Controls for additional security

---

## 🚀 Production Enhancements

### 1. HTTPS Support

Add SSL certificate and HTTPS proxy:

```hcl
resource "google_compute_managed_ssl_certificate" "lb_cert" {
  name = "lb-ssl-cert"

  managed {
    domains = ["example.com"]
  }
}

resource "google_compute_target_https_proxy" "web_lb" {
  name             = "cl-lb-sandbox-web-https-proxy"
  url_map          = google_compute_url_map.web_lb.id
  ssl_certificates = [google_compute_managed_ssl_certificate.lb_cert.id]
}
```

### 2. Cloud CDN

Enable in backend service:

```hcl
resource "google_compute_backend_service" "web_backend" {
  # ... existing config ...

  enable_cdn = true

  cdn_policy {
    cache_mode  = "CACHE_ALL_STATIC"
    default_ttl = 3600
    max_ttl     = 86400
  }
}
```

### 3. Multi-Region Deployment

Deploy instance groups in multiple regions for global distribution.

### 4. Cloud Armor

Add DDoS protection and WAF rules:

```hcl
resource "google_compute_security_policy" "policy" {
  name = "lb-security-policy"

  rule {
    action   = "deny(403)"
    priority = "1000"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["1.2.3.4/32"]  # Block specific IPs
      }
    }
  }
}
```

---

## 🐛 Troubleshooting

### Issue: Load balancer returns 502 errors

**Possible Causes:**
1. Backends are unhealthy
2. Firewall blocking health checks
3. Backend service not responding

**Troubleshooting:**
```bash
# Check backend health
gcloud compute backend-services get-health cl-lb-sandbox-web-backend-service --global

# Verify firewall rules
gcloud compute firewall-rules list --filter="name~health-check"

# Check instance logs
gcloud compute instances get-serial-port-output <instance-name> --zone=europe-north2-a
```

### Issue: Traffic not distributed evenly

**Possible Causes:**
1. Session affinity enabled
2. Connection draining in progress
3. Uneven backend capacity

**Solution:**
```bash
# Check backend service configuration
gcloud compute backend-services describe cl-lb-sandbox-web-backend-service --global

# Ensure session_affinity = "NONE" in main.tf
```

### Issue: Health checks failing

**Check:**
```bash
# Verify health check configuration
gcloud compute health-checks describe cl-lb-sandbox-web-health-check

# Test health endpoint manually
gcloud compute ssh <instance-name> --zone=europe-north2-a
curl http://localhost/health
```

### Issue: Load balancer takes too long to deploy

**Expected**: 5-10 minutes is normal for initial deployment
- Forwarding rule: ~1 minute
- Backend service: ~3-5 minutes
- Health checks to pass: ~2-3 minutes

---

## 💰 Cost Considerations

### Pricing Components

1. **Forwarding Rules**: $0.025/hour (~$18/month)
2. **Data Processing**: $0.008-0.016/GB
3. **Backend Instances**: $0.0104/hour per e2-micro (~$15/month each)
4. **Egress Traffic**: Varies by destination

**Example Monthly Cost** (2 backend instances, 100GB traffic):
- Forwarding rule: $18
- 2 × e2-micro: $30
- Data processing: $1-2
- **Total**: ~$50-52/month

💡 **Tip**: Use e2-micro for testing, scale up for production!

---

## 🔗 Use Cases

### 1. Web Applications
- Distribute traffic across multiple web servers
- Ensure high availability
- Handle traffic spikes

### 2. API Services
- Load balance API requests
- Implement rate limiting (with Cloud Armor)
- Monitor API performance

### 3. Microservices
- Route to different services via URL paths
- Blue/green deployments
- A/B testing

### 4. Global Applications
- Serve users from nearest region
- Low-latency access worldwide
- Geographic redundancy

---

## 📖 Additional Resources

- [Load Balancing Documentation](https://cloud.google.com/load-balancing/docs)
- [Managed Instance Groups](https://cloud.google.com/compute/docs/instance-groups)
- [Health Checks](https://cloud.google.com/load-balancing/docs/health-checks)
- [Cloud CDN](https://cloud.google.com/cdn/docs)
- [Cloud Armor](https://cloud.google.com/armor/docs)

---

## 🧹 Cleanup

When you're done testing:

```bash
# Destroy all resources
terraform destroy

# Confirm by typing 'yes'
```

**Cleanup Verification:**
```bash
# Verify forwarding rules are deleted
gcloud compute forwarding-rules list

# Verify instance group is deleted
gcloud compute instance-groups managed list

# Verify backend services are deleted
gcloud compute backend-services list
```

---

## 🎯 Next Steps

You've completed Chapter 5! You now know how to:
- ✅ Create instance templates and managed instance groups
- ✅ Configure external HTTP load balancers
- ✅ Implement auto-healing and health checks
- ✅ Monitor and test load distribution

Continue learning with upcoming chapters on:
- Cloud Storage and databases
- Kubernetes (GKE)
- Serverless computing (Cloud Run, Cloud Functions)

---

## 🤝 Questions or Issues?

If you encounter any issues:
1. Check the troubleshooting section above
2. Review Terraform logs: `terraform show`
3. Check GCP Cloud Console for load balancer status
4. Open an issue in the repository

---

**Happy Learning! 🚀**

*Chapter 5 of GCP Zero to Expert*
