#!/bin/bash
# This script sets up a Debian/Ubuntu based system to run Docker containers with AMD ROCm GPU support.

# Exit immediately if a command exits with a non-zero status.
set -e

echo "--- [Step 1/6] Removing old Docker and broken AMD repository configurations ---"
# Remove old versions of Docker to prevent conflicts.
sudo apt-get remove docker docker-engine docker.io containerd runc -y || true
# Remove potentially broken repository files from previous attempts. Use '|| true' to not fail if the file doesn't exist.
sudo rm /etc/apt/sources.list.d/rocm.list || true
sudo rm /etc/apt/sources.list.d/amdgpu.list || true

echo "--- [Step 2/6] Setting up Docker's official repository ---"
sudo apt-get update
sudo apt-get install ca-certificates curl -y
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "--- [Step 3/6] Installing the latest Docker Engine and Docker Compose ---"
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

echo "--- [Step 4/6] Setting up the AMD Container Toolkit repository ---"
curl -sL https://repo.radeon.com/rocm/rocm.gpg.key | sudo gpg --dearmor -o /usr/share/keyrings/rocm.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/rocm.gpg] https://repo.radeon.com/amd-container-toolkit/apt/ jammy main" | sudo tee /etc/apt/sources.list.d/amd-container-toolkit.list

echo "--- [Step 5/6] Installing and configuring the AMD Container Toolkit ---"
sudo apt-get update
sudo apt-get install amd-container-toolkit -y
sudo amd-ctk runtime configure --runtime=docker

echo "--- [Step 6/6] Restarting Docker to apply GPU configuration ---"
# A full restart of the socket and service is required to load the new runtime.
sudo systemctl stop docker.socket
sudo systemctl stop docker.service
sudo systemctl start docker.service

echo "--- Setup Complete! ---"
echo "Verifying Docker versions:"
docker --version
docker compose version
echo "Docker is now configured for ROCm support."
