#!/bin/bash

VALID_ARGS=$(getopt -o n:m:f:p:r --long network:,mysql:,flask:,password:,prune -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -n | --network)
        docker_bridge_network_name=$2
        shift 2
        ;;
    -m | --mysql)
        mysql_image_name=$2
        shift 2
        ;;
    -f | --flask)
        flask_image_name=$2
        shift 2
        ;;
    -p | --password)
        mysql_password=$2
        shift 2
        ;;
    -r | --prune)
        docker network rm $docker_bridge_network_name
        docker volume rm mysql-data
        docker stop mysql-flaskr
        docker stop flaskr-app
        shift 1
        ;;
    --) shift; 
        break 
        ;;
  esac
done

if docker network create $docker_bridge_network_name > /dev/null 2>&1; then
    echo "Successfully created a docker bridge network $docker_bridge_network_name"
else
    echo "Error creating a docker bridge network: $docker_bridge_network_name. Does the network already exist?"
    exit 1
fi

echo "Building mysql image $mysql_image_name:latest..."
docker build \
    -t $mysql_image_name:latest \
    --build-arg MYSQL_ROOT_PASS=$mysql_password \
    -f $(pwd)/db/Dockerfile \
    .

echo "Successfully built a flaskr mysql image"

echo "Building flask application image $flask_image_name:latest..."
docker build \
    -t $flask_image_name:latest \
    -f $(pwd)/app/Dockerfile \
    .

echo "Successfully built a flaskr app image"

echo "Running mysql database inside a container..."
docker run \
    -p 3306:3306 \
    --mount type=volume,src=mysql-data,target=/var/lib/mysql \
    --rm \
    -d \
    --network $docker_bridge_network_name \
    --name mysql-flaskr \
    $mysql_image_name:latest

sleep 2

echo "Running Flask app inside a container..."
docker run -p 5000:5000 \
    --rm \
    --network $docker_bridge_network_name \
    --name flaskr-app \
    -d \
    $flask_image_name:latest