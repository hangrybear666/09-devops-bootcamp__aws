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

    Ensure to have your jenkins ip and your local ip whitelisted for inbound access.

4. Create environment files 
        
    Add an `.env` file in your repository's root directory and add the following key value-pairs:
    ```
    DOCKER_HUB_USER=xxx
    DOCKER_HUB_TOKEN=xxx
    DOCKER_HUB_REPO=hangrybear/devops_bootcamp
    ```

5. Install docker locally.

    Make sure to install docker and docker-compose (typically built-in) for local development. See https://docs.docker.com/engine/install/


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

    f. Dont forget to open ports in your EC2 instance's security group 3080 for node-app, 22 for ssh, ideally only for your own ip-address

1. To build a local docker image, push it to a private docker hub repo and then automatically pull and run it on your EC2 instance

    Simply run
    ```
    ./build-and-push-local-docker-img.sh
    ./ec2-pull-and-run-docker-img.sh
    ```

2. 

    NOTE: if you have followed Demo Project 1 from https://github.com/hangrybear666/08-devops-bootcamp__jenkins.git you can skip steps a-e

    a. Add `docker-hub-repo` credential-id to jenkins with your username and password you can find in your `.env` file after having run setup step 4.
    
    b. Add your git credentials with the id `git-creds` and the username `x-token-auth` and fetch a personal access token from your git account.

    c. Add Maven under Manage Jenkins -> Tools -> Maven and name it `Maven`.

    d. Navigate to Manage Jenkins -> System -> Add Github Server with name `Github`, check the "Manage Hooks" checkbox and and add the API_URL https://api.github.com with a Github API Token as Jenkins credentials and add it to your `.env` file to not lose access. NOTE: The github token must have only webhook permissions, the rest is optional.

    e. Manage Jenkins -> Available Plugins -> Ignore Committer Strategy -> Install. This allows us to ignore commits by the jenkins pipeline itself for build triggering.

    f. Create a multibranch pipeline under New Item -> Multibranch Pipeline -> `ec2-java-app-multibranch` and set it to get `java-app/Jenkinsfile` (!) from SCM under Definition and add your Git Credentials with the branch specifier `*`.

    g. In your Github Repository add your jenkins repo url on push events as hook, navigate to Settings -> Webhooks -> http://165.227.155.148:8080/github-webhook/ 

    h. Configure your pipeline to avoid builds after version commits from jenkins itself via Plugin by navigating to your multibranch pipeline settings and adding `jenkins@example.com` under Configuration -> Branch Sources -> Add -> Ignore Committer Strategy. NOTE: Make sure to check the `Allow builds when a changeset contains non-ignored author(s)` Flag!

    i. Install Plugin for ssh connection under Manage Jenkins -> Available Plugins -> SSH Agent

    j. Install Plugin for pipeline utils, especially readProperties under Manage Jenkins -> Available Plugins -> Pipeline Utility Steps

    k. Change the default value of `DOCKER_HUB_REPO_URL`  in your `java-app/Jenkinsfile` file to your own and push the changes or simply provide it as user input when building the pipeline with parameters.#

    l. In your multibranch pipeline navigate to Credentials and add SSH Username with private key and add the private key's contents of your AWS EC2 instance as `ec2-server-key`

    m. 




## Usage (Exercises)

