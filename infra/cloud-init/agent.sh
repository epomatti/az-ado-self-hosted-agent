#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export NEEDRESTART_MODE=a

sudo apt update
sudo apt upgrade -y

sudo wget https://packages.microsoft.com/config/ubuntu/22.04/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
sudo dpkg -i packages-microsoft-prod.deb
sudo rm packages-microsoft-prod.deb

sudo apt-get update
sudo apt-get install moby-engine -y
sudo touch /etc/docker/daemon.json
echo '{ "log-driver": "local", "log-opts": { "max-size": "10m", "max-file": "3" }, "dns": ["168.63.129.16"] }' | sudo tee -a /etc/docker/daemon.json
sudo systemctl restart docker

# Gives permission to the Agent
sudo chmod 666 /var/run/docker.sock