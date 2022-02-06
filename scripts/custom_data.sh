#!/bin/bash

# Install java
sudo apt update
sudo apt install openjdk-11-jdk -y

java -version

# install Jenkins
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

sudo apt-get update
sudo apt-get install jenkins -y


# Setup Jenkins as a daemon launched on start. See /etc/init.d/jenkins for more details.
# Create a ‘jenkins’ user to run this service.
# Direct console log output to the file /var/log/jenkins/jenkins.log. Check this file if you are troubleshooting Jenkins.
# Populate /etc/default/jenkins with configuration parameters for the launch, e.g JENKINS_HOME
# Set Jenkins to listen on port 8080. Access this port with your browser to start configuration.

#sudo cat /var/lib/jenkins/secrets/initialAdminPassword

