# Launching AWS EC2 instances, pushing images to AWS ECR, creating IAM access and deploying containers via shell scripts in jenkins pipelines.

Basic AWS resource creation as an entrypoint for scripted automation.

Collection of Config files and shell scripts interacting with the AWS CLI, creating IAM users and policies, launching EC2 instances and deploying ECR images via declarative Jenkins pipeline.

<u>The main projects are:</u>
1. Create an EC2 instance from AWS Management Console and Install Docker Engine via ssh shell script
2. Build a local docker image, push it to a private docker hub repo and then automatically pull and run it on your EC2 instance via ssh shell scripts
3. Jenkins pipeline automatically increments the artifact version, adds docker image tag, pushes the image to docker hub, ssh's into AWS EC2 to pull and run the image via scp'd docker compose and commits the version change
4. Create AWS IAM User Group, User and assign policies, create access keys used to launch an ec2 instance with ssh access

## Setup

### 1. Pull SCM

    Pull the repository locally by running
    ```
    git clone https://github.com/hangrybear666/09-devops-bootcamp__aws.git
    ```

### 2. Make sure to have a jenkins server running and a docker hub account created prior

    a. Follow Setup and Demo Project Step 0 in https://github.com/hangrybear666/08-devops-bootcamp__jenkins.git to start a jenkins server within a docker image (DinD)

### 3. Create EC2 instance with Red Hat Linux and configure VPC/Security Group for ssh access

    Ensure to have your jenkins ip and your local ip whitelisted for inbound access.

### 4. Create environment variables

    Add an `.env` file in your repository's root directory and add the following key value-pairs:
    ```
    DOCKER_HUB_USER=xxx
    DOCKER_HUB_TOKEN=xxx
    ```

### 5. Install docker locally.

    Make sure to install docker and docker-compose (typically built-in) for local development. See https://docs.docker.com/engine/install/

## Usage (Demo Projects)

<details closed>
<summary><b>1. Create an EC2 instance from AWS Management Console and Install Docker Engine via ssh shell script</b></summary>

#### a. This repository's shell scripts are designed to work with Red Hat Enterprise Linux 9 (HVM) 64-bit (x86) Amazon Machine Image with instance type of t2.micro.

#### b. Create a key-value pair for ssh connection and store the downloaded private key in `.pem` format in your `/home/user/.ssh/` directory named `docker-runner-devops-bootcamp.pem`.

#### c. Change permissions on your private key file by running `sudo chmod 400 /home/user/.ssh/docker-runner-devops-bootcamp.pem`

#### d. Add your ec2 instance's public ip address and your docker hub private repository url to `config/remote.properties`

*NOTE:* don't use quotation marks, as readProperties plugin parses these as part of values
```bash
EC2_PUBLIC_IP_1=3.79.237.46
EC2_USER_1=ec2-user
DOCKER_HUB_REPO=hangrybear/devops_bootcamp
```

#### e. Install docker on your EC2 instance by running
```bash
cd scripts
./ec2-install-docker.sh
```

#### f. Dont forget to open ports in your EC2 instance's security group: 8080 for java, 3080 for node-app, 22 for ssh, ideally only for your own ip-address and the ip address of jenkins server

#### g. Install `jq` locally, so our aws scripts can manipulate returned json output from aws cli shell scripts

</details>

-----

<details closed>
<summary><b>2. Build a local docker image, push it to a private docker hub repo and then automatically pull and run it on your EC2 instance via ssh shell scripts</b></summary>

Simply run
```bash
./build-and-push-local-docker-img.sh
./ec2-pull-and-run-docker-img.sh
```

</details>

-----

<details closed>
<summary><b>setup for 3. Jenkins Plugins and Github Webhook</b></summary>

*NOTE:* if you have followed Demo Project 1 from https://github.com/hangrybear666/08-devops-bootcamp__jenkins.git you can skip steps a-e

#### a. Add `docker-hub-repo` credential-id to jenkins with your username and password you can find in your `.env` file after having run setup step 4.

#### b. Add your git credentials with the id `git-creds` and the username `x-token-auth` and fetch a personal access token from your git account.

#### c. Add Maven under Manage Jenkins -> Tools -> Maven and name it `Maven`.

#### d. Setup Github for Jenkins

Navigate to Manage Jenkins -> System -> Add Github Server with name `Github`, check the "Manage Hooks" checkbox and and add the API_URL https://api.github.com with a Github API Token as Jenkins credentials and add it to your `.env` file to not lose access. NOTE: The github token must have only webhook permissions, the rest is optional.

#### e. Manage Jenkins -> Available Plugins -> Ignore Committer Strategy -> Install. This allows us to ignore commits by the jenkins pipeline itself for build triggering.

#### f. Manage Jenkins -> Available Plugins -> SSH Agent to install Plugin for ssh connection to remote instances

#### g. Manage Jenkins -> Available Plugins -> Pipeline Utility Steps for reading property files from repository to receive key-value pairs from config

#### h. In your Github Repository add your own jenkins repo url on push events as hook

*Insert your IP*
Navigate to Settings -> Webhooks -> http://165.227.155.148:8080/github-webhook/

</details>

-----

<details closed>
<summary><b>3. Jenkins pipeline automatically increments the artifact version, adds docker image tag, pushes the image to docker hub, ssh's into AWS EC2 to pull and run the image via scp'd docker compose and commits the version change</b></summary>

#### a. Create a multibranch pipeline

New Item -> Multibranch Pipeline -> `ec2-java-app-multibranch` and set it to get `java-app/Jenkinsfile` (!) from SCM under Definition and add your Git Credentials with the branch specifier `*`.

#### b. Configure your pipeline

To avoid builds after version commits from jenkins itself via Plugin by navigating to your multibranch pipeline settings and adding `jenkins@example.com` under Configuration -> Branch Sources -> Add -> Ignore Committer Strategy. NOTE: Make sure to check the `Allow builds when a changeset contains non-ignored author(s)` Flag!

#### c. In your multibranch pipeline navigate to Credentials and add SSH Username with private key and add the private key's contents of your AWS EC2 instance with the id `ec2-server-key`

#### d. Add your docker hub credentials with the id `docker-hub-creds`.

#### e. Add a secret text credential to your pipeline named `postgres-pw` for the later docker-compose file

#### f. Push a code change to remote to trigger Github webhook build invocation or simply build the pipeline manually.

#### g. To deploy the java-app only as a docker container using docker pull command, simply push a code change or build the app with default parameters.

#### h. To deploy both the java-app and postgres container via `docker-compose.yaml` file simply build the pipeline with parameters and change your choice in the dropdown to 'docker compose (/w postgres)'

*NOTE:* You might have to execute the pipeline twice, because it will not know the Jenkinsfile parameter `DEPLOYMENT_STRATEGY` during first invocation, before Jenkinsfile has been loaded once.

</details>

-----

<details closed>
<summary><b>4. Create AWS IAM User Group, User and assign policies, create access keys used to launch an ec2 instance with ssh access</b></summary>

#### a. Install AWS CLI on your local machine. See https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html

#### b. Create and Configure AWS Admin Access Keys

- Create an IAM user with the policies `AdministratorAccess` and `IAMUserChangePassword`
- create an access key-pair for the CLI under Security Credentials and securely store the key pair.
- Login once with the provided default credentials, change the password
- and then run `aws configure` in your local console to setup aws cli access with the key-pair, region of your choosing and json as output format.

#### c. Simply navigate to `scripts/` folder and execute the shell scripts.
```bash
# ensure to have jq installed locally so the script can parse json
./aws-create-user-group-and-policies.sh
./aws-create-and-setup-ec2-instance.sh
sudo chmod 400 ../config/aws-ec2-ssh-key.pem
# the ip address is logged at the end of the ec2 shell script
ssh -i ../config/aws-ec2-ssh-key.pem ec2-user@3.70.253.69
```

*Note:* To change EC2 setup parameters you can change any of the key-value pairs in `config/aws.properties`
```bash
AWS_USER_NAME=MyDemoUser
AWS_DEMO_GROUP=MyDemoGroup
AWS_REGION=eu-central-1
AWS_SUBNET=eu-central-1a
AWS_IMAGE_ID=ami-007c3072df8eb6584
AWS_EC2_INSTANCE_TYPE=t2.micro
AWS_EC2_INSTANCE_NAME=MyDemoEc2Instance
AWS_OUTPUT_FORMAT=json
AWS_TEMP_PSWD=changeIt_1
```

</details>

-----
