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

# Create dynamic node-app docker tag

DOCKER_TAG="node-app-$VERSION_NUM"
cd node-app

# build image
docker build -f Dockerfile -t $DOCKER_HUB_REPO:$DOCKER_TAG .
# login to docker hub
echo $DOCKER_HUB_TOKEN | docker login -u $DOCKER_HUB_USER --password-stdin
# push image to docker hub
docker push $DOCKER_HUB_REPO:$DOCKER_TAG
