#!/bin/bash

# extract the current directory name from pwd command (everything behind the last backslash
CURRENT_DIR=$(pwd | sed 's:.*/::')
if [ "$CURRENT_DIR" != "scripts" ]
then
  echo "please change directory to scripts folder and execute the shell script again."
  exit 1
fi

# load key value pairs from config file
source ../config/remote.properties
source ../.env

PRIVATE_KEY_PATH="$HOME/.ssh/docker-runner-devops-bootcamp.pem"

if [ ! -f $PRIVATE_KEY_PATH ]
then
  echo "docker-runner-devops-bootcamp.pem private key file not found in $HOME/.ssh/ folder."
  exit 1
fi

ssh -i $PRIVATE_KEY_PATH $EC2_USER_1@$EC2_PUBLIC_IP_1 <<EOF
# Older versions of Docker went by docker or docker-engine. Uninstall any such older versions before attempting to install a new version, along with associated dependencies. 
sudo yum remove docker \
                  docker-client \
                  docker-client-latest \
                  docker-common \
                  docker-latest \
                  docker-latest-logrotate \
                  docker-logrotate \
                  docker-engine \
                  podman \
                  runc

# Install the yum-utils package (which provides the yum-config-manager utility) and set up the repository.
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/rhel/docker-ce.repo

# Install Docker Engine, containerd, and Docker Compose:
sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker
sudo systemctl start docker

echo "Installed docker version: \$(docker -v)"
echo "Installed docker compose version: \$(docker compose version)"

# add user to docker group so docker commands can be run without sudo
sudo usermod -aG docker \$USER
EOF
