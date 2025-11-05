variable "project_name" {
  description = "The display name of the project"
  type        = string
  default     = "cl-demo-sandboxterraform"
}

variable "project_id" {
  description = "The unique project ID (must be globally unique across GCP)"
  type        = string
  default     = "cl-demo-sandboxterraform"
}

variable "org_id" {
  description = "The organization ID (required if creating project under an organization)"
  type        = string
  default     = ""
}

variable "billing_account" {
  description = "The billing account ID to associate with the project"
  type        = string
}

variable "enabled_apis" {
  description = "List of APIs to enable for the project"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}
