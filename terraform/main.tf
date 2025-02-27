terraform {
  backend "gcs" {
    bucket = "pedro-nos-challenge-2702251429"
    prefix = "terraform/state"
  }
}

provider "google" {
  project = var.project_id
  region  = "us-central1"
}

# Enable required APIs
resource "google_project_service" "services" {
  for_each = toset(
    ["secretmanager.googleapis.com", "run.googleapis.com", "artifactregistry.googleapis.com", "storage.googleapis.com"]
  )
  project = var.project_id
  service = each.value
}


# Create a Cloud Storage bucket for the service
resource "google_storage_bucket" "storage_bucket" {
  name     = var.function_bucket
  location = "US"
  depends_on = [google_project_service.services]
}

# Create a service account for Cloud Run
resource "google_service_account" "cloud_run_sa" {
  account_id   = "cloud-run-sa"
  display_name = "Cloud Run Service Account"
}

# Grant the service account read access to the storage bucket
resource "google_storage_bucket_iam_member" "bucket_access" {
  bucket = google_storage_bucket.storage_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}

# Deploy the Cloud Run service
resource "google_cloud_run_service" "default" {
  name     = var.service_name
  location = "us-central1"

  template {
    spec {
      service_account_name = google_service_account.cloud_run_sa.email

      containers {
        image = var.container_image

        # Optionally, define environment variables if required
        # env {
        #   name  = "EXAMPLE_VAR"
        #   value = "value"
        # }
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
