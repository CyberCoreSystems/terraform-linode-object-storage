output "bucket_label" {
  description = "The bucket label/name."
  value       = linode_object_storage_bucket.this.label
}

output "bucket_id" {
  description = "The bucket resource ID (region:label)."
  value       = linode_object_storage_bucket.this.id
}

output "region" {
  description = "The Object Storage region of the bucket."
  value       = linode_object_storage_bucket.this.region
}

output "hostname" {
  description = "The bucket hostname (browser-accessible when the bucket is public)."
  value       = linode_object_storage_bucket.this.hostname
}

output "s3_endpoint" {
  description = "The S3-compatible endpoint URL for this bucket's region."
  value       = linode_object_storage_bucket.this.s3_endpoint
}

output "endpoint_type" {
  description = "The S3 endpoint type for this bucket's region (e.g. E0, E1)."
  value       = linode_object_storage_bucket.this.endpoint_type
}

output "access_key_id" {
  description = "The Object Storage access key ID (null when create_access_key = false)."
  value       = var.create_access_key ? linode_object_storage_key.this[0].access_key : null
}

output "secret_key" {
  description = "The Object Storage secret key (null when create_access_key = false). Returned only at create time."
  value       = var.create_access_key ? linode_object_storage_key.this[0].secret_key : null
  sensitive   = true
}
