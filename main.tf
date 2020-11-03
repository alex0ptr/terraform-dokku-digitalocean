terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = ">= 2.0.2"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
    template = {
      source  = "hashicorp/cloudinit"
      version = ">= 2.0.0"
    }
  }
}

resource random_string id_suffix {
  length  = 4
  special = false
  upper   = false
}

locals {
  env  = "${var.resource_prefix}-${random_string.id_suffix.result}"
  tags = setunion([local.env], var.tags)
  dokku_config = merge({
    vhost_enable = false
    hostname = "dokku.me"
    nginx_enable = true
  }, var.dokku_config)
}

