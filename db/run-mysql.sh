docker build \
    -t flaskr-mysql:latest \
    --build-arg MYSQL_ROOT_PASS=$1 \
    -f db/Dockerfile \
    .

echo "Successfully build a flaskr mysql image"

docker run \
    -p 3306:3306 \
    --mount type=volume,src=mysql-data,target=/var/lib/mysql \
    --rm \
    -d \
    --name mysql-flaskr \
    flaskr-mysql:latest

echo "Successfully build a flaskr mysql container"