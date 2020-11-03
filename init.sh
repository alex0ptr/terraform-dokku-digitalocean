#!/bin/bash
set -euo pipefail

echo "This is cloud-init user-data 👋"

echo "make admin user own his home"
chown doadm:doadm -R /home/doadm/

# disabling default PAM setting of DO
# https://stackoverflow.com/questions/33803566/error-you-are-required-to-change-your-password-immediately-root-enforced
sed -i 's/^root:.*$/root:*:16231:0:99999:7:::/' /etc/shadow

echo "reconfigure ssh..."
sed -i -e '/^PermitRootLogin/s/^.*$/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i -e '/^PasswordAuthentication/s/^.*$/PasswordAuthentication no/' /etc/ssh/sshd_config
sed -i -e '/^X11Forwarding/s/^.*$/X11Forwarding no/' /etc/ssh/sshd_config
sed -i -e '/^#AllowTcpForwarding/s/^.*$/AllowTcpForwarding no/' /etc/ssh/sshd_config
sed -i -e '/^#AllowAgentForwarding/s/^.*$/AllowAgentForwarding no/' /etc/ssh/sshd_config
systemctl restart ssh

echo "configuring dokku pre-install..."
echo "dokku dokku/web_config boolean false" | debconf-set-selections
echo "dokku dokku/vhost_enable boolean ${vhost_enable}" | debconf-set-selections
echo "dokku dokku/hostname string ${hostname}" | debconf-set-selections
echo "dokku dokku/nginx_enable boolean ${nginx_enable}" | debconf-set-selections
echo "dokku dokku/key_file string /home/doadm/.ssh/id_pub" | debconf-set-selections

# install prerequisites
sudo apt-get update -qq >/dev/null
sudo apt-get install -qq -y apt-transport-https

# install docker
wget -nv -O - https://get.docker.com/ | sh

# install dokku
wget -nv -O - https://packagecloud.io/dokku/dokku/gpgkey | apt-key add -
OS_ID="$(lsb_release -cs 2>/dev/null || echo "bionic")"
echo "xenial bionic focal" | grep -q "$OS_ID" || OS_ID="bionic"
echo "deb https://packagecloud.io/dokku/dokku/ubuntu/ $${OS_ID} main" | sudo tee /etc/apt/sources.list.d/dokku.list
sudo apt-get update -qq >/dev/null
sudo apt-get install -qq -y dokku
sudo dokku plugin:install-dependencies --core

echo "installing dokku postgres plugin..."
dokku plugin:install https://github.com/dokku/dokku-postgres.git postgres

echo "installing lets encrypt plugin..."
dokku plugin:install https://github.com/dokku/dokku-letsencrypt.git