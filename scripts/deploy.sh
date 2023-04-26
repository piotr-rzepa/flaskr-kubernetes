#!/bin/bash

#
# Script for creating docker images for both Blog app and MySQL database and running them in containers
# it also creates a shared network between two containers and has capabilities of removing provisioned infrastructure
#

if [[ -z $1 ]];
then
    echo "No docker network name argument passed."
    exit 1
fi
if [[ -z $2 ]];
then
    echo "No Blog App image name argument passed."
    exit 1
fi
if [[ -z $3 ]];
then
    echo "No Blog App image tag argument passed."
    exit 1
fi
if [[ -z $4 ]];
then
    echo "No Blog App dockerfile path argument passed (relative)."
    exit 1
fi
if [[ -z $5 ]];
then
    echo "No MySQL image name argument passed."
    exit 1
fi
if [[ -z $6 ]];
then
    echo "No MySQL image tag argument passed."
    exit 1
fi
if [[ -z $7 ]];
then
    echo "No MySQL dockerfile path argument passed (relative)."
    exit 1
fi
if [[ -z $8 ]];
then
    echo "No MySQL root password passed."
    exit 1
fi
if [[ -z $9 ]];
then
    echo "No MySQL volume name argument passed."
    exit 1
fi
if [[ -z $10 ]];
then
    echo "No Blog App container name argument passed."
    exit 1
fi
if [[ -z $11 ]];
then
    echo "No MySQL container name name argument passed."
    exit 1
fi

if docker network create $1 > /dev/null 2>&1;
then
    echo "Creating docker network: $1"
else
    echo "Error creating docker network: $1. Does the network already exist?"
fi

echo "Creating Blog App image $2:$3"
docker build \
    -t $2:$3 \
    -f $(pwd)/$4 \
    .

echo "Creating MySQL image $5:$6"
docker build \
    -t $5:$6 \
    --build-arg MYSQL_ROOT_PASS=$8 \
    -f $(pwd)/$7 \
    .


echo "Running MySQL container.."
docker run \
    -p 3306:3306 \
    --mount type=volume,src=$9,target=/var/lib/mysql \
    --rm \
    -d \
    --network $1 \
    --name $11 \
    $5:$6

echo "Running Flask app container.."
docker run \
    -p 5000:5000 \
    --rm \
    -d \
    --network $1 \
    --name $10 \
    $2:$3
