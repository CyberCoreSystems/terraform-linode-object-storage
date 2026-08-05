terraform {
  required_version = ">= 1.6"

  required_providers {
    linode = {
      source  = "linode/linode"
      version = ">= 3.14, < 4.0"
    }
  }
}
