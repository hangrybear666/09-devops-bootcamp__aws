#!/user/bin/env groovy

def extractRemoteProperties() {
  def props = readProperties file: 'config/remote.properties'
  env.EC2_USER = props["EC2_USER_1"]
  env.EC2_PUBLIC_IP = props["EC2_PUBLIC_IP_1"]
  env.DOCKER_HUB_REPO_URL = props["DOCKER_HUB_REPO"]
}

def commitVersionUpdate() {
    sh 'git config --global user.email "jenkins@example.com"'
    sh 'git config --global user.name "jenkins"'

    sh 'git status'
    sh 'git branch'
    sh 'git config --list'

    sh "git remote set-url origin https://${USER}:${PASS}@github.com/hangrybear666/09-devops-bootcamp__aws.git"
    sh 'git add .'
    sh "git commit -m 'Updated Version to ${VERSION}'"
    sh 'git push origin HEAD:main'
}

return this