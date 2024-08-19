#!/user/bin/env groovy

def extractRemoteProperties() {
  def props = readProperties file: 'config/remote.properties'
  env.EC2_USER = props["EC2_USER_1"]
  env.EC2_PUBLIC_IP = props["EC2_PUBLIC_IP_1"]
  env.DOCKER_HUB_REPO_URL = props["DOCKER_HUB_REPO"]
}

return this