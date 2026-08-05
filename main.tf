# S3-compatible Linode Object Storage bucket — private by default, versioned,
# with optional lifecycle rules, custom-domain TLS, and a least-privilege
# access key scoped to just this bucket. Works with Terraform and OpenTofu.

resource "linode_object_storage_bucket" "this" {
  region = var.region
  label  = var.label

  acl          = var.acl
  cors_enabled = var.cors_enabled
  versioning   = var.versioning

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    content {
      id                                     = lifecycle_rule.key
      enabled                                = lifecycle_rule.value.enabled
      prefix                                 = lifecycle_rule.value.prefix
      abort_incomplete_multipart_upload_days = lifecycle_rule.value.abort_incomplete_multipart_upload_days

      dynamic "expiration" {
        for_each = (lifecycle_rule.value.expiration_days != null || lifecycle_rule.value.expiration_date != null || lifecycle_rule.value.expired_object_delete_marker != null) ? [1] : []
        content {
          days                         = lifecycle_rule.value.expiration_days
          date                         = lifecycle_rule.value.expiration_date
          expired_object_delete_marker = lifecycle_rule.value.expired_object_delete_marker
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = lifecycle_rule.value.noncurrent_version_expiration_days != null ? [1] : []
        content {
          days = lifecycle_rule.value.noncurrent_version_expiration_days
        }
      }
    }
  }

  # Custom-domain TLS material (served over HTTPS). Sensitive.
  dynamic "cert" {
    for_each = var.cert == null ? [] : [var.cert]
    content {
      certificate = cert.value.certificate
      private_key = cert.value.private_key
    }
  }

  lifecycle {
    precondition {
      condition     = !var.versioning || alltrue([for r in values(var.lifecycle_rules) : r.expiration_date == null])
      error_message = "Versioned buckets should expire current objects by age (expiration_days), not an absolute expiration_date — set versioning = false or drop expiration_date."
    }
  }
}

# Least-privilege access key: scoped to THIS bucket only (not an account-wide
# key). secret_key is returned once at create and stored sensitive in state.
resource "linode_object_storage_key" "this" {
  count = var.create_access_key ? 1 : 0

  label = coalesce(var.access_key_label, "${var.label}-key")

  bucket_access {
    bucket_name = linode_object_storage_bucket.this.label
    region      = var.region
    permissions = var.access_key_permissions
  }
}
