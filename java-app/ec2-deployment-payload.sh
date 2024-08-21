#!/bin/bash

if [ -z "$EC2_USER" ] || [ -z "$EC2_PUBLIC_IP" ] || [ -z "$DOCKER_IMG_TAG" ] || [ -z "$DOCKER_HUB_USER" ] || [ -z "$DOCKER_HUB_TOKEN" ] || [ -z "$POSTGRES_PASSWORD" ] 
then
    echo "this script expects certain environment parameters to be set. Please provide them all in your jenkins stage or in global env var."
    exit 1
fi

echo "Copying files via scp..."
scp docker-compose.yaml $EC2_USER@$EC2_PUBLIC_IP:~

ssh $EC2_USER@$EC2_PUBLIC_IP <<EOF

# login to docker hub
echo $DOCKER_HUB_TOKEN | docker login -u $DOCKER_HUB_USER --password-stdin

# pull and run image from docker hub via docker compose
export DOCKER_HUB_IMG_URL=$DOCKER_IMG_TAG
export POSTGRES_PW=$POSTGRES_PASSWORD
docker compose up --detach

EOF