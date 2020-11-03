module dokku {
  source = "../"

  region          = "fra1"
  public_key      = file("~/.ssh/id_rsa.pub")
  resource_prefix = "${terraform.workspace}-dokku"
  size            = "s-1vcpu-1gb" # dokku recommends at least 1GB of RAM
  floating_ip     = true

  # upgrade         = true
  # dokku_config = {
  #  vhost_enable = false
  #  hostname = "dokku.me"
  #  nginx_enable = true
  #}
  # tags {
  #     owner = "alex"
  # }
  # backups = false
  # vpc_uuid = null
  # resize_disk = true
}

output "ip" {
  value = module.dokku.ip
}

output "admin_connect" {
  value = "ssh doadm@${module.dokku.ip}"
}

output "follow_installation" {
  value = "ssh doadm@${module.dokku.ip}  'tail -f /var/log/cloud-init-output.log'"
}

output "wait_until_up" {
  value = "until $(ssh -o LogLevel=QUIET -o ConnectTimeout=5 -o PasswordAuthentication=no -o StrictHostKeyChecking=no -t dokku@${module.dokku.ip} apps list > /dev/null ); do; printf '.'; sleep 5; done"
}
