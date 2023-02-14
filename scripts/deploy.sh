#!/bin/bash

VALID_ARGS=$(getopt -o n:m:p:f:r --long network:,mysql:,password:,flask:,prune -- "$@")
if [[ $? -ne 0 ]]; then
    exit 1;
fi

eval set -- "$VALID_ARGS"
while [ : ]; do
  case "$1" in
    -r | --prune)
        echo "Removing existing resources..."
        echo "Stopping MySQL container..."
        docker stop $(docker ps --filter "name=mysql-flaskr" --format "{{.ID}}")
        echo "Stopping Flask container..."
        docker stop $(docker ps --filter "name=flask-app" --format "{{.ID}}")
        echo "Removing MySQL named volume..."
        docker volume rm mysql-data
        echo "Removing bridged docker network..."
        docker network rm $docker_network
        echo "Removing MySQL image..."
        docker image rm $mysql_img_name
        echo "Removing Flask image..."
        docker image rm $flask_img_name
        shift 1
        ;;
    -n | --network)
        docker_network=$2
        shift 2
        ;;
    -m | --mysql)
        mysql_img_name=$2
        shift 2
        ;;
    -p | --password)
        mysql_password=$2
        shift 2
        ;;
    -f | --flask)
        flask_img_name=$2
        shift 2
        ;;
    --) shift; 
        break 
        ;;
  esac
done

if docker network create $docker_network > /dev/null 2>&1; then
    echo "Creating docker network: $docker_network"
else
    echo "Error creating docker network: $docker_network. Does the network already exist?"
fi

echo "Creating MySQL image $mysql_img_name:latest"
docker build \
    -t $mysql_img_name:latest \
    --build-arg MYSQL_ROOT_PASS=$mysql_password \
    -f $(pwd)/db/Dockerfile \
    .

echo "Creating Flask app image $flask_img_name:latest"
docker build \
    -t $flask_img_name:latest \
    -f $(pwd)/app/Dockerfile \
    .

echo "Running MySQL container.."
docker run \
    -p 3306:3306 \
    --mount type=volume,src=mysql-data,target=/var/lib/mysql \
    --rm \
    -d \
    --network $docker_network \
    --name mysql-flaskr \
    $mysql_img_name:latest

echo "Running Flask app container.."
docker run \
    -p 5000:5000 \
    --rm \
    -d \
    --network $docker_network \
    --name flask-app \
    $flask_img_name:latest