# Flask Tutorial Blog Application on Kubernetes

Sample Flask app from documentation's tutorial, deployed on multi-node Kubernetes cluster using Kind.

Link to the Flask app on GitHub: https://github.com/pallets/flask/tree/main/examples/tutorial  
Link to the Flask app on Flask Documentation: https://flask.palletsprojects.com/en/2.2.x/tutorial/

The Application is being gradually moved from local setup to the Kubernetes cluster.

The steps include:

* Deployment of MySQL and Flask app using **separate Dockerfiles** and Bash scripts for automatic provisioning
* Deployment of MYSQL and Flask app using **Docker-Compose**
* Deployment of dockerized MySQL and Flask app in **Kubernetes cluster** using **simple YAML configuration**
* Deployment o dockerized MySQL and Flask app in Kubernetes cluster using YAML configuration + **Kustomize templating**
* Deployment o dockerized MySQL and Flask app in Kubernetes cluster using **Helm Charts**

Apart from moving the application to Kubernetes, future planned additions include:

* Adding ELK/EFK stack for centralized and standarized monitoring
* Adding Prometheus/Grafana setup for application monitoring
* Adding HPA (for app) / VPA (for DB)

## Flask app setup

Application is modified to use external MySQL database instead of in-memory SQLite3.  
MySQL database instance is listening on port `3306` (default).  
In directory `db/` there is an init script `schema.sql`, which is responsible for creating the database, tables and user to be used by Flask application.

### Running Application using deployment script (separate Dockerfiles) - v1.0.0

```bash
chmod +x scripts/deploy.sh
./scripts/deploy.sh \
    --network <network>
    --mysql <image_name>
    --password <mysql_root_password>
    --flask <image_name>
```

You can pass an additional `--prune` flag to remove all the existing resources before provisioning new ones using the script.

### Running Application using docker compose - v2.0.0

File `docker-compose.yaml` defined at root directory of the project can be used to deploy a containerized stack of Flask and MySQL instances.  
It works out the same way as `scripts/deploy.sh`, but with addition of automatic network creation, easy env variable support and health checks, as well as restarting the containers on failure automatically.

To validate the compose file, with resolved environment variable:

```bash
docker-compose convert
```

To run a stack in detached mode (including building any missing images):

```bash
docker-compose up --build -d
```

To remove stack and any related volumes / orphan containers:

```bash
docker compose down -v --remove-orphans
```

### Kubernetes setup - Kind

Kubernetes cluster consists of two worker nodes and one control-plane node, all running K8s v1.26.0, deployed using [Kind](https://kind.sigs.k8s.io/).  
The config file for Kind Cluster is defined in `kind-example-config.yaml`. The following addition:  

```yaml
  extraPortMappings:
    - containerPort: 30423
      hostPort: 30423
      listenAddress: "0.0.0.0"
      protocol: TCP
```

Is required to be able to reach the pods behind a NodePort service type, which exposes the same port on worker node as defined in `hostPort` key-value pair, using the port exposed by a Pod. You can create the cluster running `kind create cluster --config kind-example-config.yaml`.  

The basic setups consists of two replicas of Flask application, which state is controlled by Deployment Controller, exposed by a NodePort type service to the user.  
The Flask communicates with a MySQL instance through headless service, which exposes a Stateful Set, destined to manage the state of MySQL.

```mermaid
graph LR
subgraph flask-blog namespace
subgraph Flask app
A[Service - App] --> |exposes|B[Deployment]
B --> |controls state|E([Flask Pod])
B --> |controls state|F([Flask Pod])
end
subgraph MySQL
C[Service headless - Mysql] --> |exposes|D[Stateful Set]
D --> |controls state|G[(MySQL Instance)]
E -.-> |headless service DNS|C
F -.-> |headless service DNS|C
end
end
```

You are able to reach the Flask Blog app by visiting localhost on port exposed by the pods (**5000**), which will go through NodePort (**30423**) on worker node.

```bash
curl localhost:5000 # or open browser and enter localhost:5000
```

All files used for deployment of the application are defined in `deployment/` folder:

* `config-maps.yaml` - Describes all non-secret related data that the app requires to function properly - this includes DNS of the MySQL service, init script for database or environment variables for defining database name and operating port.
* `secrets.yaml` - Describes all secret data that the app requires to function properly - this includes username and password of flask user, which will interact with MySQL database, root account credentials and secret keys.
* `namespace.yaml` - Describes the namespace in kubernetes cluster, in which everything should be deployed.
* `services.yaml` - Describes two services for exposing pods matching certain labels - one for Flask app pods, second for MySQL instance respectively.
* `deplyoment.yaml` - Describes the Deplyoment Controller for managing state of Flask Blog pods.
* `stateful-set.yaml` - Describes the Stateful Set Controller for managing state of MySQL instance.

The order in which the infrastructure should be deployed is:  
**namespace -> config-maps & secrets -> services -> statefulset -> deployment**

It is possible to use `kubectl apply -f deployment/` to deploy all of them using single command, but the files are executed in **alphabetical order** (which may yield errors like trying to create resource in a namespace which is not yet created).

### Kubernetes setup - Ingress Controller

### Kubernetes setup - K8s Dashboard