# ☁️ GCP Zero to Expert - Complete Terraform Course

> 🚀 Master Google Cloud Platform with Infrastructure as Code! From beginner to expert with hands-on Terraform examples.

[![Terraform](https://img.shields.io/badge/Terraform-1.0+-623CE4?style=flat&logo=terraform&logoColor=white)](https://www.terraform.io/)
[![GCP](https://img.shields.io/badge/Google_Cloud-4285F4?style=flat&logo=google-cloud&logoColor=white)](https://cloud.google.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

---

## 📚 About This Course

This repository provides **comprehensive, real-world examples** for building and deploying solutions across the entire GCP ecosystem using **Terraform**. Whether you're a beginner or looking to master advanced GCP services, this course has you covered!

### 🎯 What You'll Learn

- ✅ **Infrastructure as Code** with Terraform best practices
- ✅ **GCP Project Management** and organization
- ✅ **Networking** - VPC, Subnets, Firewalls, Load Balancers
- ✅ **Compute Services** - Compute Engine, GKE, Cloud Run
- ✅ **Storage Solutions** - Cloud Storage, Cloud SQL, Filestore
- ✅ **Serverless** - Cloud Functions, Cloud Run
- ✅ **Data & Analytics** - BigQuery, Dataflow, Pub/Sub
- ✅ **AI/ML Services** - Vertex AI, AutoML
- ✅ **Security & IAM** - Best practices and implementation
- ✅ **Monitoring & Logging** - Cloud Monitoring, Cloud Logging

---

## 🗂️ Course Structure

Each chapter is self-contained with:
- 📝 Complete Terraform configuration files
- 📖 Detailed README with step-by-step instructions
- 🔧 Real-world examples and use cases
- 🐛 Troubleshooting guides
- 💡 Best practices and tips

---

## 📖 Chapters

### 🏗️ Foundation

#### [Chapter 1: Creating a GCP Project](./chapter-01-create-gcp-project/)
> **Learn**: Project creation with Terraform, random suffix for testing, API enablement

**What's Inside:**
- 🎲 Random project ID suffix to bypass GCP's 30-day deletion restriction
- 🔧 Google Cloud provider configuration
- 📦 API service enablement automation
- 🏷️ Project labeling and organization
- ✅ Complete setup and verification steps

**Key Files:**
- `main.tf` - Project resource definitions
- `provider.tf` - Terraform and GCP provider config
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `terraform.tfvars` - Configuration values

**Quick Start:**
```bash
cd chapter-01-create-gcp-project
terraform init
terraform plan
terraform apply
```

[📚 Full Chapter Documentation →](./chapter-01-create-gcp-project/README.md)

---

### 🌐 Networking & Compute

#### [Chapter 2: VPC, Networking, and Compute Instance](./chapter-02-vpc-networking-compute/)
> **Learn**: Custom VPC setup, subnets, firewall rules, compute instances, SSH access

**What's Inside:**
- 🌐 Custom VPC network creation (no auto-subnets)
- 🗺️ Subnet configuration with specific CIDR ranges
- 🔥 Firewall rules for SSH and ICMP
- 💻 Compute instance deployment with nginx
- 🔑 SSH key management for secure access
- 🏷️ Network tags for firewall targeting
- 📊 VPC flow logs for network monitoring

**Key Files:**
- `main.tf` - VPC, subnet, firewall, and VM definitions
- `provider.tf` - Google Cloud provider configuration
- `variables.tf` - Input variables for customization
- `outputs.tf` - Network and VM information outputs
- `terraform.tfvars` - Configuration values with SSH key

**Architecture:**
- VPC: `cl-vpc-sandbox`
- Subnet: `cl-sub-sandbox-web-eu-nrth2-01` (10.100.1.0/24)
- VM: `cl-vm-sandbox-web-01` (e2-micro with nginx)
- Firewall: SSH (22) and ICMP allowed

**Quick Start:**
```bash
cd chapter-02-vpc-networking-compute
terraform init
terraform plan
terraform apply
# SSH into VM
ssh rahulwagh@$(terraform output -raw vm_external_ip)
```

[📚 Full Chapter Documentation →](./chapter-02-vpc-networking-compute/README.md)

---

### 🔐 Security & Access Control

#### [Chapter 3: Bastion Host / Jump Server for Private VMs](./chapter-03-bastion-jump-host/)
> **Learn**: Bastion host setup, private subnets, secure access to private VMs, SSH ProxyJump

**What's Inside:**
- 🔐 Bastion host / jump server deployment with public access
- 🔒 Private subnet creation without internet access
- 💻 Private VM deployment (no external IP)
- 🔥 Firewall rules for bastion-to-private-VM access
- 🚀 SSH ProxyJump configuration for seamless connections
- 🛡️ Security best practices for jump hosts
- 🌐 Private Google Access for VMs without external IPs

**Key Files:**
- `main.tf` - Private subnet, bastion host, private VM, and firewall rules
- `provider.tf` - Google Cloud provider configuration
- `variables.tf` - Input variables for customization
- `outputs.tf` - Connection instructions and network information
- `terraform.tfvars` - Configuration values with SSH key

**Architecture:**
- VPC: `cl-vpc-sandbox` (from Chapter 2)
- Private Subnet: `cl-sub-sandbox-private-eu-nrth2-01` (10.100.2.0/24)
- Bastion Host: `cl-vm-sandbox-bastion-01` (e2-micro with public IP)
- Private VM: `cl-vm-sandbox-private-db-01` (e2-micro, no external IP)
- Firewall: Bastion SSH from internet, Private VM SSH from bastion only

**Quick Start:**
```bash
cd chapter-03-bastion-jump-host
terraform init
terraform plan
terraform apply
# Connect to bastion
ssh rahulwagh@$(terraform output -raw bastion_external_ip)
# Connect to private VM via ProxyJump
ssh -J rahulwagh@$(terraform output -raw bastion_external_ip) rahulwagh@$(terraform output -raw private_vm_internal_ip)
```

[📚 Full Chapter Documentation →](./chapter-03-bastion-jump-host/README.md)

---

### 🔐 Security Advanced (Coming Soon)

#### Chapter 4: IAM and Service Accounts
> **Learn**: Identity management, service accounts, roles, and permissions

---

### ⚖️ Load Balancing (Coming Soon)

#### Chapter 5: HTTP(S) Load Balancers
> **Learn**: HTTP(S) Load Balancing, SSL certificates, backend services

---

### 💻 Compute Advanced (Coming Soon)

#### Chapter 5: Compute Engine Instances
> **Learn**: VM creation, instance templates, metadata

#### Chapter 6: Managed Instance Groups
> **Learn**: Auto-scaling, health checks, rolling updates

#### Chapter 7: Google Kubernetes Engine (GKE)
> **Learn**: GKE cluster creation, node pools, workload deployment

---

### 🗄️ Storage & Databases (Coming Soon)

#### Chapter 8: Cloud Storage Buckets
> **Learn**: Bucket creation, lifecycle policies, versioning

#### Chapter 9: Cloud SQL
> **Learn**: MySQL/PostgreSQL instances, high availability

#### Chapter 10: Cloud Filestore
> **Learn**: NFS file shares, performance tiers

---

### ⚡ Serverless (Coming Soon)

#### Chapter 11: Cloud Functions
> **Learn**: Serverless functions, event triggers

#### Chapter 12: Cloud Run
> **Learn**: Container deployment, auto-scaling, traffic splitting

---

### 📊 Data & Analytics (Coming Soon)

#### Chapter 13: BigQuery
> **Learn**: Data warehouse setup, datasets, tables

#### Chapter 14: Pub/Sub
> **Learn**: Message queuing, topic/subscription patterns

---

### 🤖 AI/ML (Coming Soon)

#### Chapter 15: Vertex AI
> **Learn**: ML model deployment, training pipelines

---

### 🔐 Security & IAM (Coming Soon)

#### Chapter 16: IAM and Security
> **Learn**: Service accounts, roles, permissions, best practices

---

## 🚀 Getting Started

### Prerequisites

Before starting, ensure you have:

1. **Google Cloud Account** with billing enabled
   - [Create a GCP account](https://cloud.google.com/free)
   - Set up billing account

2. **Terraform** (version >= 1.0)
   ```bash
   # macOS
   brew install terraform

   # Linux
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/

   # Verify installation
   terraform --version
   ```

3. **Google Cloud SDK**
   ```bash
   # macOS
   brew install google-cloud-sdk

   # Linux
   curl https://sdk.cloud.google.com | bash

   # Initialize
   gcloud init
   ```

4. **Authentication**
   ```bash
   # Login with your Google account
   gcloud auth application-default login
   ```

### 📥 Clone the Repository

```bash
git clone https://github.com/rahulwagh/gcp-zero-to-expert-by-rahulwagh.git
cd gcp-zero-to-expert-by-rahulwagh
```

### 🎓 How to Use This Course

1. **Sequential Learning**: Start with Chapter 1 and progress through chapters in order
2. **Hands-On Practice**: Each chapter includes working Terraform code - deploy it!
3. **Experiment**: Modify the code, break things, learn by doing
4. **Clean Up**: Always run `terraform destroy` after completing a chapter to avoid charges

---

## 💰 Cost Management

> ⚠️ **Important**: Running GCP resources will incur costs!

- 💵 Most chapters use minimal resources suitable for the free tier
- 🧹 Always run `terraform destroy` when done with a chapter
- 📊 Monitor your billing in the [GCP Console](https://console.cloud.google.com/billing)
- 🎁 New users get $300 in free credits for 90 days

---

## 🤝 Contributing

Contributions are welcome! If you find issues or want to add improvements:

1. 🍴 Fork the repository
2. 🌿 Create a feature branch (`git checkout -b feature/amazing-feature`)
3. 💾 Commit your changes (`git commit -m 'Add amazing feature'`)
4. 📤 Push to the branch (`git push origin feature/amazing-feature`)
5. 🔀 Open a Pull Request

---

## 📺 Video Course

This repository is part of the **GCP Zero to Expert** video course series:

- 🎬 **YouTube**: [Coming Soon]
- 🎓 **Udemy**: [Coming Soon]

Subscribe to stay updated with new chapters and content!

---

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙋 Support & Questions

- 💬 **Issues**: [GitHub Issues](https://github.com/rahulwagh/gcp-zero-to-expert-by-rahulwagh/issues)
- 📧 **Email**: [Your Email]
- 🐦 **Twitter**: [@rahulwagh](https://twitter.com/rahulwagh) (if applicable)
- 💼 **LinkedIn**: [Your LinkedIn]

---

## ⭐ Show Your Support

If you find this course helpful, please consider:
- ⭐ Starring this repository
- 🔄 Sharing it with others
- 📺 Subscribing to the YouTube channel
- ☕ [Buy me a coffee](https://buymeacoffee.com/rahulwagh) (optional)

---

## 🗺️ Roadmap

- [x] Chapter 1: GCP Project Creation
- [x] Chapter 2: VPC, Networking, and Compute Instance
- [x] Chapter 3: Bastion Host / Jump Server for Private VMs
- [ ] Chapter 4: IAM and Service Accounts
- [ ] Chapter 5: Load Balancers
- [ ] Chapter 6: Google Kubernetes Engine
- [ ] Chapter 7: Cloud Storage
- [ ] Chapter 8: Cloud SQL
- [ ] Chapter 9: Cloud Functions
- [ ] Chapter 10: Cloud Run
- [ ] More chapters coming soon...

---

## 📚 Additional Resources

- 📖 [Terraform GCP Provider Documentation](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- 📖 [Google Cloud Documentation](https://cloud.google.com/docs)
- 📖 [Terraform Best Practices](https://www.terraform-best-practices.com/)
- 🎯 [GCP Free Tier](https://cloud.google.com/free)

---

<div align="center">

**Happy Learning! 🚀**

Made with ❤️ by [Rahul Wagh](https://github.com/rahulwagh)

⭐ Star this repo if you find it helpful!

</div>
