#!/bin/bash

sudo timedatectl set-timezone Europe/Zagreb

sudo apt update && sudo apt upgrade -y

sudo apt install \
	ubuntu-drivers-common \
	htop \
	python3-pip \
	python3-venv \
	git \
	vim

sudo pip install -r requirements.txt

# NVIDIA drivers
# https://ubuntu.com/server/docs/nvidia-drivers-installation
sudo ubuntu-drivers install nvidia:535-server
sudo apt install nvidia-utils-535-server


# Docker + docker compose
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update


sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo groupadd docker
sudo usermod -aG docker $USER

echo "Remember to add other users to the 'docker' group!"
