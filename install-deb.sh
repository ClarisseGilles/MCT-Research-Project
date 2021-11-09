#!/bin/bash

# Install script for Debian/Ubuntu only!

# Store distribution
distribution=$(. /etc/os-release;echo $ID$VERSION_ID | sed -e 's/\.//g')

# Install curl
apt install -y curl

# Download and run Docker install script
curl -fsSL https://get.docker.com | sh -

# Download Docker-compose and make it executable
curl -sL "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Setup the CUDA network repository
curl -fsSL https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/cuda-$distribution.pin -o /etc/apt/preferences.d/cuda-repository-pin-600
apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64/7fa2af80.pub
echo "deb http://developer.download.nvidia.com/compute/cuda/repos/$distribution/x86_64 /" | tee /etc/apt/sources.list.d/cuda.list

# Setup the Nvidia Docker repository
curl -fsSL https://nvidia.github.io/nvidia-docker/gpgkey | apt-key add -
curl -fsSL https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | tee /etc/apt/sources.list.d/nvidia-docker.list

apt update
apt install -y \
    linux-headers-$(uname -r) \
    cuda-drivers
    nvidia-docker2

# Restart Docker daemon
systemctl restart docker

