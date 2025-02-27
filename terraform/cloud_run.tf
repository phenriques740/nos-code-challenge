# Deploy the Cloud Run service
resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = "us-central1"

  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email

      containers {
        image = var.container_image

        # Set the container port to 5000
        ports {
          container_port = 5000
        }

        # Define liveness and readiness probes
        liveness_probe {
          http_get {
            path = "/healthz"
            port = 5000
          }
          initial_delay_seconds = 3
          period_seconds        = 10
        }

      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}


# Allow unauthenticated invocations (user invocation)
resource "google_cloud_run_service_iam_member" "invoker" {
  service  = google_cloud_run_service.default.name
  location = google_cloud_run_service.default.location
  role     = "roles/run.invoker"
  member   = "allUsers"
}

# Grant the specified developer permissions for Cloud Run deployment/updating
resource "google_project_iam_member" "developer_run" {
  project = var.project_id
  role    = "roles/run.developer"
  member  = "user:${var.developer_email}"
}

output "cloud_run_url" {
  description = "The URL of the deployed Cloud Run service"
  value       = google_cloud_run_service.default.status[0].url
}
