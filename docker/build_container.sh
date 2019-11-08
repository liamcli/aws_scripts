#!/bin/bash

DOCKER_IMG_NAME=$1
DOCKERFILE_PATH=$2
ECR_URL=$3

# Login into ECR.
# Need to install awscli and configure with account credentials.
$(aws ecr get-login --no-include-email --region us-east-2)

# Assume that the script runs from the root directory.
docker build -t ${DOCKER_IMG_NAME} -f ${DOCKERFILE_PATH} .
docker tag ${DOCKER_IMG_NAME} ${ECR_URL}/${DOCKER_IMG_NAME}
docker push ${ECR_URL}/${DOCKER_IMG_NAME}

