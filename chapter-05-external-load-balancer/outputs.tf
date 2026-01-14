output "load_balancer_ip" {
  description = "External IP address of the load balancer"
  value       = google_compute_global_forwarding_rule.web_lb.ip_address
}

output "load_balancer_url" {
  description = "URL to access the load balancer"
  value       = "http://${google_compute_global_forwarding_rule.web_lb.ip_address}"
}

output "instance_group_name" {
  description = "Name of the managed instance group"
  value       = google_compute_instance_group_manager.web_backend.name
}

output "instance_group_size" {
  description = "Number of instances in the group"
  value       = google_compute_instance_group_manager.web_backend.target_size
}

output "backend_service_name" {
  description = "Name of the backend service"
  value       = google_compute_backend_service.web_backend.name
}

output "health_check_name" {
  description = "Name of the health check"
  value       = google_compute_health_check.http_health_check.name
}

output "instructions" {
  description = "Instructions for testing the load balancer"
  value       = <<-EOT
    ╔═══════════════════════════════════════════════════════════════════════════╗
    ║                                                                           ║
    ║              🌐 External HTTP Load Balancer Deployed! 🌐                  ║
    ║                                                                           ║
    ╚═══════════════════════════════════════════════════════════════════════════╝

    📋 Load Balancer Details:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    • Load Balancer IP:    ${google_compute_global_forwarding_rule.web_lb.ip_address}
    • Load Balancer URL:   http://${google_compute_global_forwarding_rule.web_lb.ip_address}
    • Backend Instances:   ${google_compute_instance_group_manager.web_backend.target_size}
    • Health Check:        ${google_compute_health_check.http_health_check.name}
    • Region:              ${var.region}

    🧪 Testing the Load Balancer:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    1️⃣  Access the load balancer in your browser:
        http://${google_compute_global_forwarding_rule.web_lb.ip_address}

    2️⃣  Test load distribution with curl (refresh multiple times):
        curl http://${google_compute_global_forwarding_rule.web_lb.ip_address}

        # Run multiple requests to see different backends respond
        for i in {1..10}; do
          curl -s http://${google_compute_global_forwarding_rule.web_lb.ip_address} | grep "Instance Name"
        done

    3️⃣  Check backend instance health:
        gcloud compute backend-services get-health ${google_compute_backend_service.web_backend.name} --global

    4️⃣  List all instances in the managed instance group:
        gcloud compute instance-groups managed list-instances ${google_compute_instance_group_manager.web_backend.name} \
          --zone=${var.zone}

    5️⃣  View load balancer details in Cloud Console:
        https://console.cloud.google.com/net-services/loadbalancing/list/loadBalancers

    📊 Monitoring:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # View load balancer metrics
    gcloud monitoring dashboards list

    # Check backend service status
    gcloud compute backend-services describe ${google_compute_backend_service.web_backend.name} --global

    # Monitor instance group
    gcloud compute instance-groups managed describe ${google_compute_instance_group_manager.web_backend.name} \
      --zone=${var.zone}

    🔧 Testing Auto-Healing:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    # Stop nginx on one instance to trigger auto-healing
    # 1. SSH into one backend instance
    # 2. Run: sudo systemctl stop nginx
    # 3. Watch as the instance is marked unhealthy and recreated

    🎯 What's Happening:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    • Load balancer distributes traffic across ${google_compute_instance_group_manager.web_backend.target_size} backend instances
    • Health checks monitor instance health every 5 seconds
    • Unhealthy instances are automatically replaced
    • Each request may be served by a different backend
    • Global load balancer provides high availability

    💡 Next Steps:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    • Scale the instance group: terraform apply -var="mig_target_size=4"
    • Add HTTPS support with SSL certificates
    • Enable Cloud CDN for static content caching
    • Configure custom health check paths

    ⏱️  Note: It may take 5-10 minutes for the load balancer to be fully operational
             and for all health checks to pass. Be patient!

    🧹 Cleanup:
    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    When done testing, destroy resources to avoid charges:
        terraform destroy
  EOT
}
