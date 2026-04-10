output "vpc_id" {
  value = aws_vpc.jay_vpc.id
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private_subnet_id" {
  value = aws_subnet.private_subnet.id
}

# -----------------------------
# S3 Bucket
# -----------------------------
output "gcs_export_bucket_name" {
  description = "GCS bucket for BigQuery export staging"
  value       = google_storage_bucket.bitcoin_bq_export.name
}

output "input_btc_bq_bucket_name" {
  description = "The name of the Bitcoin BQ ingestion S3 bucket"
  value       = aws_s3_bucket.input_btc_bq.bucket
}