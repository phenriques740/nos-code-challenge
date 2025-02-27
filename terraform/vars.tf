variable "project_id" {
  type = string
}

variable "function_bucket" {
  type = string
}

variable "function_name" {
  type = string
}

variable "developer_email" {
  description = "Email of the developer for deployment permissions"
  type        = string
}
variable "service_name" {
  description = "The name of the Cloud Run service"
  type        = string
}
variable "container_image" {
  description = "The container image to deploy (e.g., gcr.io/your-project/your-image:tag)"
  type        = string
}