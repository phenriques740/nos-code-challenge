# Grant Cloud Run service account permission to pull images from Artifact Registry
resource "google_artifact_registry_repository_iam_member" "cloud_run_pull" {
  repository = google_artifact_registry_repository.docker_registry.name
  location   = google_artifact_registry_repository.docker_registry.location
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.cloud_run_sa.email}"
}
# Create an Artifact Registry repository for storing container images
resource "google_artifact_registry_repository" "docker_registry" {
  project       = var.project_id
  location      = "us-central1" # Change to your desired region
  repository_id = "population-api"
  format        = "DOCKER"

  depends_on = [google_project_service.services]
}
