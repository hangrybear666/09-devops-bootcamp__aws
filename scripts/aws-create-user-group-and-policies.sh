#!/bin/bash

# extract the current directory name from pwd command (everything behind the last backslash
CURRENT_DIR=$(pwd | sed 's:.*/::')
if [ "$CURRENT_DIR" != "scripts" ]
then
  echo "please change directory to scripts folder and execute the shell script again."
  exit 1
fi

# load key value pairs from config file
source ../config/aws.properties

# Create Group, User and assign Group
aws iam create-group --group-name "$AWS_DEMO_GROUP"
aws iam create-user --user-name "$AWS_USER_NAME"
aws iam add-user-to-group --user-name "$AWS_USER_NAME" --group-name "$AWS_DEMO_GROUP"
echo "created $AWS_USER_NAME and assigned $AWS_DEMO_GROUP"

# Assign the password change policy to the user directly
CHANGE_PASSWORD_POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`"IAMUserChangePassword"`].Arn' --output text)
aws iam attach-user-policy --user-name "$AWS_USER_NAME" --policy-arn "$CHANGE_PASSWORD_POLICY_ARN"
echo "assigned IAMUserChangePassword policy to user $AWS_USER_NAME"

# Assign the EC2 full access policy to the entire user group
EC2_FULL_ACCESS_POLICY_ARN=$(aws iam list-policies --query 'Policies[?PolicyName==`"AmazonEC2FullAccess"`].Arn' --output text)
aws iam attach-group-policy --group-name "$AWS_DEMO_GROUP" --policy-arn "$EC2_FULL_ACCESS_POLICY_ARN"
echo "assigned AmazonEC2FullAccess policy to user $AWS_DEMO_GROUP"

# creates access key pair for user and saves as local variable
output=$(aws iam create-access-key --user-name "$AWS_USER_NAME")
AccessKeyId=$(echo $output | jq -r '.AccessKey.AccessKeyId')
SecretAccessKey=$(echo $output | jq -r '.AccessKey.SecretAccessKey')

# allows $AWS_USER_NAME to login to aws console 
aws iam create-login-profile --user-name "$AWS_USER_NAME" --password "$AWS_TEMP_PSWD" --password-reset-required
EC2_ACCOUNT_ID=$(aws iam get-user --user-name "$AWS_USER_NAME" --query 'User.Arn' --output text | cut -d ':' -f 5)

# saves local variable access key pair in ~/.aws/credentials as default
#aws configure set aws_access_key_id  "$AccessKeyId"
#aws configure set aws_secret_access_key  "$SecretAccessKey"
#echo "peristed aws access keys in ~/.aws/credentials"

# stores acces key pair for future use in /config/aws.secrets which is in .gitignore
echo "aws_access_key_id=$AccessKeyId
aws_secret_access_key=$SecretAccessKey" > ../config/aws.secrets

# saves region and output format in ~/.aws/config
aws configure set region "$AWS_REGION"
aws configure set output "$AWS_OUTPUT_FORMAT"
echo "peristed options in ~/.aws/config:
set region to $AWS_REGION
set cli output to $AWS_OUTPUT_FORMAT"

# Notify User to change password
echo "Please login to AWS Console and change your password: https://aws.amazon.com/console/"
echo "Account ID: $EC2_ACCOUNT_ID
Username: $AWS_USER_NAME
Password: $AWS_TEMP_PSWD"