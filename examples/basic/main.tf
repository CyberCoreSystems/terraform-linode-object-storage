terraform {
  required_version = ">= 1.6"
  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">= 3.14, < 4.0"
    }
  }
}

provider "linode" {
  # Credentials come from the LINODE_TOKEN environment variable (the provider's
  # documented default). A hardcoded token — even a fake one — is what secret
  # scanners flag (checkov CKV_LIN_1) and what leaks when an example is copied.
}

module "bucket" {
  source = "../../"

  label  = "iacbazaar-example-assets"
  region = "us-ord-1"

  # Private + versioned by default; scoped read-write key for an app.
  versioning             = true
  access_key_permissions = "read_write"

  lifecycle_rules = {
    expire-tmp = {
      prefix          = "tmp/"
      expiration_days = 7
    }
    prune-old-versions = {
      noncurrent_version_expiration_days     = 30
      abort_incomplete_multipart_upload_days = 3
    }
  }
}

output "bucket_hostname" {
  value = module.bucket.hostname
}

output "s3_endpoint" {
  value = module.bucket.s3_endpoint
}

output "access_key_id" {
  value = module.bucket.access_key_id
}

output "secret_key" {
  value     = module.bucket.secret_key
  sensitive = true
}
