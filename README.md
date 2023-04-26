# Flask Blog Application using Dockerfiles

Sample Flask app from documentation's tutorial, deployed as microservices using containers via Docker.

Link to the Flask app on GitHub: <https://github.com/pallets/flask/tree/main/examples/tutorial>
Link to the Flask app on Flask Documentation: <https://flask.palletsprojects.com/en/2.2.x/tutorial/>

The Application is being gradually moved from local setup to the container setup and finally, to the Kubernetes cluster.

Stages of improvements:

1. **Docker (Building docker images manually and deploying using bash scripts) [current setup].**
2. Docker-compose (Building and deploying using Docker-compose).
3. Kind + Kubernetes (Building and deploying using YAML manifests and kubectl) [current setup].
4. Kind + Kubernetes + Helm (Building and deploying using Helm Charts).

## App setup

Application is modified to use external MySQL database instead of in-memory SQLite3.
MySQL database instance is listening on port `3306` (default) and initialized by `db/schema.sql` file, which is responsible for creating the database, tables and user, used by Flask application.

## Deployment

To deploy the Blog Application and MySQL Database a `deploy.sh` bash script in `scripts/` directory can be used.\
The script is responsible for creating a shared docker network, building images of both applications and running the containers.

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh \
    <network> \
    <docker network name> \
    <blog app image name> \
    <blog app image tag> \
    <blog app dockerfile path> \
    <mysql image name> \
    <mysql image tag> \
    <mysql dockerfile path> \
    <mysql root password> \
    <blog app container name> \
    <mysql container name>
```

e.g.

```bash
./scripts/deploy.sh \
  docker_deployment_network \
   flask-blog-app-docker \
   latest \
   app/Dockerfile \
   flask-db-docker \
   latest \
   db/Dockerfile \
   admin \
   flaskr-mysql \
   flask-blog-container \
   flask-mysql-container
```
