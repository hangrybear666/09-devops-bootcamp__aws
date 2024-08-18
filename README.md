# Launching AWS EC2 instances, pushing images to AWS ECR and subsequently deploying them as containers via shell scripts in jenkins pipelines.

Collection of config files and shell scripts interacting with the AWS CLI, launching EC2 instances in AWS and automatically deploying images hosted on AWS ECR via declarative Jenkins pipelines. 

The main projects are:
- 

## Setup

1. Pull SCM

    Pull the repository locally by running
    ```
    git clone https://github.com/hangrybear666/09-devops-bootcamp__aws.git
    ```

2. Make sure to have a jenkins server running and a docker hub account created prior

    a. Follow Setup and Demo Project Step 0 in https://github.com/hangrybear666/08-devops-bootcamp__jenkins.git to start a jenkins server within a docker image (DinD)

3. Create EC2 instance with Red Hat Linux and configure VPC/Security Group for ssh access


3. Install additional dependencies on remote

    Some Linux distros ship without the `netstat` or `jq` commands we use. In that case run `apt install net-tools` or `dnf install net-tools` on fedora et cetera.

4. Create environment files 
        
    Add an `.env` file in your repository's root directory and add the following key value-pairs:
    ```
    DOCKER_HUB_USER=xxx
    DOCKER_HUB_TOKEN=xxx
    DOCKER_HUB_REPO=hangrybear/devops_bootcamp
    ```

5. Install docker locally.

    Make sure to install docker and docker-compose (typically built-in) for local development. See https://docs.docker.com/engine/install/

6. Dont forget to open ports in your remote firewall.

    3000 for node-app, 22 for ssh.

## Usage (Demo Projects)

0. Create an EC2 instance from AWS Management Console

    a. This repository's shell scripts are designed to work with Red Hat Enterprise Linux 9 (HVM) 64-bit (x86) Amazon Machine Image with instance type of t2.micro.

    b. Create a key-value pair for ssh connection and store the downloaded private key in `.pem` format in your `/home/user/.ssh/` directory named `docker-runner-devops-bootcamp.pem`.

    c. Change permissions on your private key file by running `sudo chmod 400 /home/user/.ssh/docker-runner-devops-bootcamp.pem`

    d. Add your ec2 instance's public ip address to `config/remote.properties` 
    ```
    EC2_PUBLIC_IP_1=3.79.237.46
    EC2_USER_1="ec2-user"
    ```

    e. Install docker on your EC2 instance by running
    ```
    cd scripts
    ./ec2-install-docker.sh
    ```

1. To build a local docker image, push it to a private docker hub repo and then automatically pull and run it on your EC2 instance

    Simply run
    ```
    ./build-and-push-local-docker-img.sh
    ./ec2-pull-and-run-docker-img.sh
    ```


## Usage (Exercises)

