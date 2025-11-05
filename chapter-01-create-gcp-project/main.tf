# Generate a random 4-character suffix for the project ID
# This allows recreating projects without waiting 30 days for GCP's soft delete period
resource "random_id" "project_suffix" {
  byte_length = 2  # 2 bytes = 4 hex characters
}

resource "google_project" "demo_project" {
  name            = var.project_name
  project_id      = "${var.project_id}-${random_id.project_suffix.hex}"
  org_id          = var.org_id != "" ? var.org_id : null
  billing_account = var.billing_account

  labels = {
    environment = "demo"
    purpose     = "learning"
    course      = "gcp-zero-to-expert"
  }

  auto_create_network = false
}

# Enable required APIs for the project
resource "google_project_service" "project_services" {
  for_each = toset(var.enabled_apis)

  project = google_project.demo_project.project_id
  service = each.value

  disable_on_destroy = false
}
