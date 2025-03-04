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
    ["cloudapis.googleapis.com", "secretmanager.googleapis.com", "run.googleapis.com", "artifactregistry.googleapis.com", "storage.googleapis.com", "cloudresourcemanager.googleapis.com", "iam.googleapis.com", "cloudresourcemanager.googleapis.com"]
  )
  project = var.project_id
  service = each.value
}

# Create a Cloud Storage bucket for the service
resource "google_storage_bucket" "storage_bucket" {
  name       = var.function_bucket
  location   = "US"
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

