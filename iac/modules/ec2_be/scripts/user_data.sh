#!/bin/bash

snap start amazon-ssm-agent

apt update
apt upgrade -y
apt install -y unzip zip wget curl python3-pip lvm2 apt-transport-https curl gnupg-agent \
  ca-certificates software-properties-common netcat-openbsd apache2-utils

sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
apt update
apt install -y postgresql-client-17 apache2-utils

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

rm -rf ~/awscliv2.zip ~/aws

useradd -u 1100 docker -m -U -s /bin/bash
mkdir /var/lib/docker

# Add Docker's official GPG key:
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update

apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin \
  cgroupfs-mount cgroup-lite docker-model-plugin

chown -R docker:docker /var/lib/docker
         
systemctl start docker
systemctl enable docker
hostnamectl set-hostname ${hostname_ec2}

mkdir /var/log/traefik
chown -R docker:docker /var/log/traefik

# Escuchar en el puerto 8080 para el healthcheck, luego vemos si se me ocurre otra cosa
while true; do
  echo -e "HTTP/1.1 200 OK\n\nOK" | sudo nc -l -p 8080
done &