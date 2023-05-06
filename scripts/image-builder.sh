#!/bin/bash

#
# Script for building Flask App Docker image and loading it into kind cluster
# The required argument is the tag of an image
#

DOCKER_IMAGE_NAME=blog
DOCKERFILE_PATH=app/Dockerfile
DOCKERFILE_CONTEXT=.

echo "Building docker image $DOCKER_IMAGE_NAME:$1."
docker build \
    -t $DOCKER_IMAGE_NAME:$1 \
    --build-arg DOCKER_TAG=$1 \
    -f $DOCKERFILE_PATH $DOCKERFILE_CONTEXT

echo "Loading $DOCKER_IMAGE_NAME:$1 into kind cluster."
kind load docker-image $DOCKER_IMAGE_NAME:$1
echo "Done loading image into cluster."
