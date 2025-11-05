output "project_id" {
  description = "The ID of the created project"
  value       = google_project.demo_project.project_id
}

output "project_number" {
  description = "The project number"
  value       = google_project.demo_project.number
}

output "project_name" {
  description = "The name of the created project"
  value       = google_project.demo_project.name
}

output "enabled_apis" {
  description = "List of enabled APIs"
  value       = [for service in google_project_service.project_services : service.service]
}
