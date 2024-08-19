#!/bin/bash

# extract the current directory name from pwd command (everything behind the last backslash
CURRENT_DIR=$(pwd | sed 's:.*/::')
if [ "$CURRENT_DIR" != "scripts" ]
then
  echo "please change directory to scripts folder and execute the shell script again."
  exit 1
fi

source ec2-setup.sh

DOCKER_TAG="node-app-$VERSION_NUM"


ssh -i $PRIVATE_KEY_PATH $EC2_USER_1@$EC2_PUBLIC_IP_1 <<EOF

# login to docker hub
echo $DOCKER_HUB_TOKEN | docker login -u $DOCKER_HUB_USER --password-stdin

# pull and run image from docker hub
docker run -d -p 3080:3080 $DOCKER_HUB_REPO:$DOCKER_TAG

EOF