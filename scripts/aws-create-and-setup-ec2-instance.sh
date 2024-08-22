#!/bin/bash

# extract the current directory name from pwd command (everything behind the last backslash
CURRENT_DIR=$(pwd | sed 's:.*/::')
if [ "$CURRENT_DIR" != "scripts" ]
then
  echo "please change directory to scripts folder and execute the shell script again."
  exit 1
fi

# check if secret file exists
if [ ! -f  "../config/aws.secrets" ]
then 
    echo "no secret key pair found. Please run ./aws-create-user-group-and-policies.sh"
    exit 1
fi

# ask for desired ports to be opened
read -p "Please provide the 1st port you want to be accessible from your current ip address (or leave empty to skip): " PORT_1
read -p "Please provide the 2nd port you want to be accessible from your current ip address (or leave empty to skip): " PORT_2

# load key value pairs from config
source ../config/aws.secrets
source ../config/aws.properties

# sets up aws cli to run with newly created user in this shell script only
export AWS_ACCESS_KEY_ID="$aws_access_key_id"
export AWS_SECRET_ACCESS_KEY="$aws_secret_access_key"

VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[*].VpcId' --output text)
SECURITY_GRP_ID=$(aws ec2 create-security-group --group-name "$AWS_DEMO_GROUP" --description "$AWS_DEMO_GROUP Default EC2 Security Group" --vpc-id "$VPC_ID" --output text)
SUBNET_ID=$(aws ec2 describe-subnets --query 'Subnets[?AvailabilityZone==`'"$AWS_SUBNET"'`].SubnetId' --output text)

# create ssh key pair and save in ../config/aws-ec2-ssh-key.pem file which is in .gitignore
aws ec2 create-key-pair --key-name "MyDemoKey" --key-type ed25519 --key-format pem --query "KeyMaterial" --output text > "../config/aws-ec2-ssh-key.pem"

# to autoscroll when running an ec2 instance in cli without waiting for user input we have to overwrite the cli_pager default config
aws configure set cli_pager cat

# launch ec2 instance 
aws ec2 run-instances --image-id "$AWS_IMAGE_ID" \
 --count "1" \
 --instance-type "$AWS_EC2_INSTANCE_TYPE" \
 --key-name "MyDemoKey" \
 --security-group-ids "$SECURITY_GRP_ID" \
 --subnet-id "$SUBNET_ID" \
 --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value='"$AWS_EC2_INSTANCE_NAME"'}]'

# query local ip 
CURRENT_LOCAL_IP=$(curl https://ipinfo.io/ip)
# whitelist current local ip for ssh connections into ec2 instance via port 22
aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GRP_ID" --protocol "tcp" --port "22" --cidr "$CURRENT_LOCAL_IP/32"

# open further ports based on user input
if [ ! -z "$PORT_1" ]
then 
    aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GRP_ID" --protocol "tcp" --port "$PORT_1" --cidr "$CURRENT_LOCAL_IP/32"
fi
if [ ! -z "$PORT_2" ]
then
    aws ec2 authorize-security-group-ingress --group-id "$SECURITY_GRP_ID" --protocol "tcp" --port "$PORT_2" --cidr "$CURRENT_LOCAL_IP/32"
fi

# extract public ip of newly created ec2 instance
EC2_INSTANCE_PUBLIC_IP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=$AWS_EC2_INSTANCE_NAME" --query "Reservations[].Instances[].PublicIpAddress" --output text)
echo "you can ssh into the server (after changing key permissions to 400) by running:
ssh -i ../config/aws-ec2-ssh-key.pem ec2-user@$EC2_INSTANCE_PUBLIC_IP"