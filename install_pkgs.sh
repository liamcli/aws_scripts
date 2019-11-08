#!/bin/sh

# Install AWSCLI
# visit https://docs.aws.amazon.com/cli/latest/userguide/install-cliv1.html for
# more installation instructions
pip3 install awscli

# TODO: You'll have to run aws configure to get aws setup with your credentials
aws configure


# Install docker
# visit https://docs.docker.com/v17.09/engine/installation/linux/docker-ce/ubuntu/
# for more detailed installation instructions
sudo apt-get update
sudo apt-get install \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"

sudo apt-get update

sudo apt-get install docker-ce

sudo docker run hello-world
