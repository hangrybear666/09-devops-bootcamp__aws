#!/user/bin/env groovy

import com.example.Docker

def call(String appName) {
    return new Docker(this).buildImage(appName)
}
