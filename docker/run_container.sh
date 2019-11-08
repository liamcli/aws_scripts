#!/bin/bash
$(aws ecr get-login --no-include-email --region us-east-2)
DOCKER_IMG_NAME=$1
ECR_URL=$2
docker pull ${ECR_URL}/${DOCKER_IMG_NAME}
docker run -it \ # run in interactive mode 
    --runtime nvidia \ # required for GPU support
    # pass data from AMI image to container
    --mount type=bind,source=/home/ec2-user/data,target=/data \ 
    --rm \ # remove container instance after session
    -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID} \  
    -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY} \
    ${DOCKER_IMG_NAME}

