# Terraform Variables Configuration
# Update the values below with your GCP account details

project_name    = "cl-demo-sandboxterraform"
project_id      = "cl-demo-sandboxterraform"  # Must be globally unique
org_id          = ""  # Leave empty if not using organization, or add your org ID
billing_account = "012747-CD506E-00761D"  # Your billing account ID

# Optional: Customize the APIs to enable
enabled_apis = [
  "compute.googleapis.com",
  "storage.googleapis.com",
  "cloudbuild.googleapis.com"
]
