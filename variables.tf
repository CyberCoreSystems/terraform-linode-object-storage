variable "label" {
  description = "Bucket name/label. 3-63 chars, lowercase letters, numbers, hyphens, dots; must start and end with a letter or number (S3 bucket-naming rules)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.label))
    error_message = "label must be 3-63 chars: lowercase letters, numbers, hyphens, dots; start and end alphanumeric."
  }

  validation {
    condition     = !can(regex("\\.\\.", var.label)) && !can(regex("^[0-9.]+$", var.label))
    error_message = "label must not contain consecutive dots or be formatted like an IP address (S3 naming rules)."
  }
}

variable "region" {
  description = "Object Storage region/endpoint slug, e.g. us-east-1, us-ord-1, fr-par-1. (The deprecated 'cluster' field is not used by this module.)"
  type        = string

  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+-[0-9]+$", var.region))
    error_message = "region must be an Object Storage region slug, e.g. us-east-1, us-ord-1, eu-central-1."
  }
}

variable "acl" {
  description = <<-EOT
    Canned ACL for the bucket. Defaults to "private" (no anonymous access).
    Only set a public value when the bucket is intentionally serving public
    content (e.g. a static site or public asset CDN origin).
  EOT
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "public-read", "authenticated-read", "public-read-write"], var.acl)
    error_message = "acl must be one of private, public-read, authenticated-read, public-read-write."
  }

  validation {
    condition     = var.acl != "public-read-write"
    error_message = "acl = \"public-read-write\" grants anonymous WRITE to anyone and is disallowed by this module. Use \"public-read\" for public assets."
  }
}

variable "versioning" {
  description = "Enable object versioning (keep prior versions). Recommended for data protection; pairs with noncurrent_version_expiration to bound storage cost."
  type        = bool
  default     = true
}

variable "cors_enabled" {
  description = "Enable permissive CORS (all origins) on the bucket. Off by default — only enable for browser-facing public assets, and prefer a narrower policy via the S3 API for production."
  type        = bool
  default     = false
}

variable "lifecycle_rules" {
  description = <<-EOT
    Lifecycle rules keyed by a stable rule id. Each rule can expire current
    objects (by age in days or an absolute date), expire noncurrent versions,
    and abort stale multipart uploads. Apply to a key prefix or the whole
    bucket (prefix = null).
  EOT
  type = map(object({
    enabled                                = optional(bool, true)
    prefix                                 = optional(string)
    abort_incomplete_multipart_upload_days = optional(number)
    expiration_days                        = optional(number)
    expiration_date                        = optional(string)
    expired_object_delete_marker           = optional(bool)
    noncurrent_version_expiration_days     = optional(number)
  }))
  default = {}

  validation {
    condition     = alltrue([for r in values(var.lifecycle_rules) : r.expiration_days == null || r.expiration_date == null])
    error_message = "Each lifecycle rule may set expiration_days OR expiration_date, not both."
  }

  validation {
    condition     = alltrue([for r in values(var.lifecycle_rules) : r.expiration_days == null || r.expiration_days >= 1])
    error_message = "lifecycle rule expiration_days must be >= 1 when set."
  }

  validation {
    condition     = alltrue([for r in values(var.lifecycle_rules) : r.expiration_date == null || can(regex("^[0-9]{4}-[0-9]{2}-[0-9]{2}$", r.expiration_date))])
    error_message = "lifecycle rule expiration_date must be an RFC3339 date (YYYY-MM-DD) when set."
  }

  validation {
    condition     = alltrue([for r in values(var.lifecycle_rules) : r.noncurrent_version_expiration_days == null || r.noncurrent_version_expiration_days >= 1])
    error_message = "lifecycle rule noncurrent_version_expiration_days must be >= 1 when set."
  }
}

variable "cert" {
  description = <<-EOT
    Optional TLS certificate to serve the bucket over HTTPS on a custom domain.
    Both fields are required together. PEM-encoded; kept sensitive.
  EOT
  type = object({
    certificate = string
    private_key = string
  })
  default   = null
  sensitive = true
}

variable "create_access_key" {
  description = "Create a scoped Object Storage access key for this bucket. The key is limited to this bucket (least privilege) with the permission set in access_key_permissions."
  type        = bool
  default     = true
}

variable "access_key_label" {
  description = "Label for the generated Object Storage access key. Defaults to \"<label>-key\" when null."
  type        = string
  default     = null
}

variable "access_key_permissions" {
  description = "Permission granted to the scoped access key for this bucket: read_only or read_write."
  type        = string
  default     = "read_write"

  validation {
    condition     = contains(["read_only", "read_write"], var.access_key_permissions)
    error_message = "access_key_permissions must be read_only or read_write."
  }
}
