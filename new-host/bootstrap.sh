#!/usr/bin/env bash
set -e
sudo apt update -y
sudo apt upgrade -y
curl -sSL https://get.docker.com | sh
sudo groupadd docker || true
sudo gpasswd -a "$USER" docker

sudo useradd -m -s /bin/bash runner
sudo gpasswd -a runner docker
sudo passwd -l runner

sudo reboot