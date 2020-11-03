
resource "digitalocean_droplet" "dokku" {
  name               = local.env
  image              = "ubuntu-20-04-x64"
  region             = var.region
  size               = var.size
  backups            = var.backups
  monitoring         = true
  ipv6               = true
  vpc_uuid           = var.vpc_uuid
  resize_disk        = var.resize_disk
  user_data          = <<-EOF
      #cloud-config
      write_files:
      - content: ${base64encode(var.public_key)}
        encoding: b64
        path: /home/doadm/.ssh/id_pub
        permissions: '0655'
      - content: ${base64encode(local.init_script)}
        encoding: b64
        path: /home/doadm/init.sh
        permissions: '0744'
      users:
      - default
      - name: doadm
        groups: users, admin
        sudo: ALL=(ALL) NOPASSWD:ALL
        shell: /bin/bash
        ssh_authorized_keys:
        - ${var.public_key}
      package_update: ${var.upgrade}
      package_upgrade: ${var.upgrade}
      runcmd:
      - [bash, /home/doadm/init.sh]
      EOF
  tags               = local.tags
}

resource "digitalocean_floating_ip" "dokku" {
  count      = var.floating_ip ? 1 : 0
  droplet_id = digitalocean_droplet.dokku.id
  region     = digitalocean_droplet.dokku.region
}

locals {
  init_script = templatefile("${path.module}/init.sh", {
    vhost_enable = local.dokku_config.vhost_enable
    hostname     = local.dokku_config.hostname
    nginx_enable = local.dokku_config.nginx_enable
  })
}
