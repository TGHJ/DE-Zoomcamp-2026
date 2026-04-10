variable "env" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
  default = "prod"
}

variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "ap-southeast-1"
}

variable "gcp_project_id" {
  description = "GCP project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "US"
}

variable "gcp_credentials_file" {
  description = "Path to GCP service account key file"
  type        = string
}

variable "gcp_service_account" {
  description = "GCP service account email"
  type        = string
}