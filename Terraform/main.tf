# Create VPC
resource "aws_vpc" "jay_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.jay_vpc.id
  cidr_block = "10.0.0.0/24"
}

# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id     = aws_vpc.jay_vpc.id
  cidr_block = "10.0.1.0/24"
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.jay_vpc.id
}

# Public Route Table
resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.jay_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate Public Subnet with Public Route Table
resource "aws_route_table_association" "public_subnet" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rtb.id
}

# Enable required GCP APIs
resource "google_project_service" "cloudresourcemanager" {
  project            = var.gcp_project_id
  service            = "cloudresourcemanager.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "bigquery" {
  project            = var.gcp_project_id
  service            = "bigquery.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "storage" {
  project            = var.gcp_project_id
  service            = "storage.googleapis.com"
  disable_on_destroy = false
}

# IAM roles for service account
resource "google_project_iam_member" "storage_admin" {
  project    = var.gcp_project_id
  role       = "roles/storage.admin"
  member     = "serviceAccount:${var.gcp_service_account}"
  depends_on = [google_project_service.cloudresourcemanager]
}

resource "google_project_iam_member" "bigquery_admin" {
  project    = var.gcp_project_id
  role       = "roles/bigquery.admin"
  member     = "serviceAccount:${var.gcp_service_account}"
  depends_on = [google_project_service.cloudresourcemanager]
}

resource "google_project_iam_member" "bigquery_job_user" {
  project    = var.gcp_project_id
  role       = "roles/bigquery.jobUser"
  member     = "serviceAccount:${var.gcp_service_account}"
  depends_on = [google_project_service.cloudresourcemanager]
}

# GCS bucket for BigQuery export staging
resource "google_storage_bucket" "bitcoin_bq_export" {
  name                        = "bitcoin-bq-export-${var.gcp_project_id}"
  project                     = var.gcp_project_id
  location                    = var.gcp_region
  force_destroy               = true
  uniform_bucket_level_access = true
  depends_on                  = [google_project_service.storage]
}

# S3 bucket for Bitcoin BigQuery ingestion
resource "aws_s3_bucket" "input_btc_bq" {
  bucket = "input-btc-bq"

  tags = {
    Name        = "input-btc-bq"
    Environment = var.env
    Project     = "practice-project"
  }
}