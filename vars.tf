
variable region {
  description = "The region where to deploy the droplet."
  type    = string
}

variable resource_prefix {
  description = "A prefix that will be used for all created resource names in addition to a random postfix."
  type    = string
  default = "dokku"
}

variable tags {
  description = "Tags that are added to all resources."
  type    = set(string)
  default = []
}

variable size {
  description = "Size of the droplet."
  type    = string
  default = "s-1vcpu-1gb"
}

variable backups {
  description = "Whether backups should be created."
  type    = bool
  default = false
}

variable public_key {
  description = "Public key used for SSH access to the admin `doadm` and `dokku` user."
  type    = string
}

variable dokku_config {
  description = "Configuration options used for the dokku installation. See locals.dokku_config in main.tf for the defaults and configuration options. See http://dokku.viewdocs.io/dokku/getting-started/install/debian/#debconf-options for more detailed explanations."
    type = map
    default = {}
}

variable upgrade {
  description = "Whether all packages should be upgraded on first launch. Takes a while and can therefore be disabled for demo purposes."
  type    = bool
  default = true
}

variable vpc_uuid {
  description = "VPC for the droplet."
  type = string
  default = null
}

variable resize_disk {
  description = "Whether the disk should be expanded when scaling up the droplet - makes it impossible to scale down afterwards."
  type = bool
  default = true
}

variable floating_ip {
  description = "Whether a static floating IP should allocated for the dokku instance."
  type = bool
  default = false
}