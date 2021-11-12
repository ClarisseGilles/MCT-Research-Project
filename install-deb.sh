#!/bin/bash

# Install script for Debian/Ubuntu

# Install curl
apt update
apt install -y curl

# Download and run Docker install script
curl -fsSL https://get.docker.com | sh -

# Download Docker-compose and make it executable
curl -sL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Setup the Nvidia Docker repository
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
curl -fsSL https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list

# Install packages
apt update
apt install -y nvidia-docker2

# Restart Docker daemon
systemctl restart docker