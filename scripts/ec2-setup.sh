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

# ask for desired image version
read -p "Please provide your desired image version: " VERSION_NUM

PRIVATE_KEY_PATH="$HOME/.ssh/docker-runner-devops-bootcamp.pem"

if [ ! -f $PRIVATE_KEY_PATH ]
then
  echo "docker-runner-devops-bootcamp.pem private key file not found in $HOME/.ssh/ folder."
  exit 1
fi

