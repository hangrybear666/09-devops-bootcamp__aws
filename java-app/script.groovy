#!/user/bin/env groovy

def buildApp() {
  echo 'building the application...'
  sh 'mvn clean package'
}

return this