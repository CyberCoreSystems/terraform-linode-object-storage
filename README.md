# Linode Object Storage Bucket

[![IaC Bazaar: plan-validated](https://www.iac-bazaar.com/api/artifacts/linode-object-storage/badge)](https://www.iac-bazaar.com/catalog/linode-object-storage?utm_source=syndication&utm_medium=readme&utm_campaign=artifact)

S3-compatible bucket with scoped access keys, versioning, lifecycle rules, and optional static-site hosting.

This module passes static validation (`tofu validate`, tflint and checkov) but has not yet been applied to a live account.

## Usage

```hcl
module "object_storage" {
  source  = "registry.terraform.io/CyberCoreSystems/object-storage/linode"
  version = "~> 1.0"

  # See variables.tf for the full input contract.
}
```

## Why this module

Every module we publish goes through the same checks before release:

| check | what it means |
|---|---|
| `tofu validate` + `tflint` | it parses and lints clean |
| `checkov` | scanned for insecure defaults |
| **live test** | **really applied to a cloud account, outputs verified, then destroyed** |

That last row is the one most module catalogues skip. A module that has never
been applied has never been proven.

## Provider compatibility

```
linode >= 3.14, < 4.0
```

## More modules

This is one of **673 Terraform modules across 19 cloud platforms** on
IaC Bazaar, 113 of them live-tested:
AWS, Azure, GCP, Oracle OCI, Cloudflare, Akamai, DigitalOcean, Linode, Hetzner,
Vultr, Scaleway, Alibaba, IBM, UpCloud, Civo, Exoscale, OVH, Tencent and Huawei.

Browse the full catalogue at **[www.iac-bazaar.com](https://www.iac-bazaar.com)**, including
production landing zones for AWS, Azure and GCP that have each been live-tested
as a single composed apply.

- Terraform module 1.0.0, plan-validated on IaC Bazaar: [Linode Object Storage Bucket](https://www.iac-bazaar.com/catalog/linode-object-storage?utm_source=syndication&utm_medium=readme&utm_campaign=artifact)
- How verification works: [https://www.iac-bazaar.com/verified](https://www.iac-bazaar.com/verified)

## Licence

See [LICENSE](./LICENSE).
