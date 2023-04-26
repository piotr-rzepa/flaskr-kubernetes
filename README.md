# Flask Blog Application using Docker Compose

Sample Flask app from documentation's tutorial, deployed as microservices using Docker compose.

Link to the Flask app on GitHub: <https://github.com/pallets/flask/tree/main/examples/tutorial> Link to the Flask app on Flask Documentation: <https://flask.palletsprojects.com/en/2.2.x/tutorial/>

The Application is being gradually moved from local setup to the container setup and finally, to the Kubernetes cluster deployed using Helm.

Stages of improvements:

1. Docker (Building docker images manually and deploying using bash scripts).
2. **Docker-compose (Building and deploying using Docker-compose) [current setup].**
3. Kind + Kubernetes (Building and deploying using YAML manifests and kubectl).
4. Kind + Kubernetes + Helm (Building and deploying using Helm Charts).

## App setup

Application is modified to use external MySQL database instead of in-memory SQLite3.
MySQL database instance is listening on port `3306` (default) and initialized by `db/schema.sql` file, which is responsible for creating the database, tables and user, used by Flask application.

## Docker Compose setup (No EFK stack)

File `docker-compose.yaml` defined at root directory of the project can be used to deploy a containerized stack of Flask and MySQL instances.

### Validating compose YAML manifest

To validate the compose file, with resolved environment variable:

```bash
docker compose convert
```

### Running the stack

To run a stack in _detached_ mode (including building any missing images):

```bash
docker compose up --build -d

# Or to wait for container to be healthy and running
docker compose up --build --wait
```

After the stack is built successfully and the status of both flask app and mysql containers is _healthy_, you can access the Blog Application on `http://localhost:5000`.

### Removing stack

To remove stack and any related volumes/orphan containers:

```bash
docker compose down -v --remove-orphans
```

The logging stack is not included in `docker-compose.yaml` file, and will be added in the future.
