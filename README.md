# Flask Blog Application on Kubernetes Cluster using Kind

Sample Flask app from documentation's tutorial, deployed on multi-node Kubernetes cluster using Kind.

Link to the Flask app on GitHub: <https://github.com/pallets/flask/tree/main/examples/tutorial>
Link to the Flask app on Flask Documentation: <https://flask.palletsprojects.com/en/2.2.x/tutorial/>

The Application is being gradually moved from local setup to the container setup and finally, to the Kubernetes cluster deployed using Helm.

Stages of improvements:

1. Docker (Building docker images manually and deploying using bash scripts).
2. Docker-compose (Building and deploying using Docker-compose).
3. **Kind + Kubernetes (Building and deploying using YAML manifests and `kubectl`) [current setup].**
4. Kind + Kubernetes + Helm (Building and deploying using Helm Charts).

## Kubernetes Kind Cluster setup

Kubernetes cluster consists of two worker nodes and one control-plane node, all running K8s v1.26.0, deployed using [Kind](https://kind.sigs.k8s.io/).
The config file for Kind Cluster is defined in `kind-example-config.yaml`. You can create the cluster running `kind create cluster --config kind-example-config.yaml`.
The following addition in the config file:

```yaml
  extraPortMappings:
    - containerPort: 30423
      hostPort: 30423
      listenAddress: "0.0.0.0"
      protocol: TCP
```

is required to be able to reach the pods via a _NodePort_ service type, which exposes the same port on worker node as defined in `hostPort` key-value pair.
The Application does not have a Ingress Controller for managing external HTTP traffic, so it's the recommended way for reaching the service.

Alternatively, you can reach the pods behind a service by using `kubectl port-forward svc/<service name> <port on host>:5000`. You can then open the browser and visit `localhost:<port on host>`.

The basic setups consists of **two** replicas of Flask application, which state is controlled by _Deployment Controller_, exposed by a _NodePort_ type service to the user.\
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

## MySQL Database setup

Application is modified to use external MySQL database instead of in-memory SQLite3.\
MySQL database instance is listening on port `3306` (default) and initialized by `mysql-init-script` file coming from config map, responsible for creating the database, tables and user, used by Flask application.

### Flask Blog App Setup

You are able to reach the Flask Blog app by visiting _localhost_ on port exposed by the service (**30423**), which will go through NodePort on one o the worker nodes and reach the pod (**5000**).

```bash
curl localhost:30423 # or open browser and enter localhost:30423
```

All files used for deployment of the application are defined in `application/` folder:

* `config-maps.yaml` - Describes all non-secret related data that the app requires to function properly - this includes DNS of the MySQL service, init script for database or environment variables for defining database name and operating port.
* `secrets.yaml` - Describes all secret data that the app requires to function properly - this includes username and password of flask user, which will interact with MySQL database, root account credentials and secret keys.
* `namespace.yaml` - Describes the namespace in kubernetes cluster, in which all application resources are deployed.
* `services.yaml` - Describes two services for exposing pods matching certain labels - one for Flask app pods, second for MySQL instance respectively.
* `deplyoment.yaml` - Describes the Deployment Controller for managing state of Flask Blog pods.
* `stateful-set.yaml` - Describes the Stateful Set Controller for managing state of MySQL instance.

The order in which the infrastructure should be deployed is:
**namespace -> config-maps & secrets -> services -> statefulset -> deployment**.

#### Application Deployment on Kind Kubernetes Cluster

It is possible to use `kubectl apply -f deployment/` to deploy all of above resources using single command, but the files are executed in **alphabetical order** (which may yield errors like trying to create resource in a namespace which is not yet created).

### EFK stack for logging

EFK stands for ElasticSearch (analyzing), Fluentd (collecting) and Kibana (visualizing). It's popular stack used to deploy standarized and centralized logging solution.

All of the above resources are deployed on a Kubernetes cluster and defined inside `logging/` directory:

* `config-maps.yaml` - Describes all _Fluentd_ configuration files, which are responsible for enriching logs with kubernetes metadata and sending them to elasticsearch
* `fluentd.yaml` - Deploys Fluentd as a daemon set, which runs on every node and collects logs from all the containers inside each pod
* `namespace.yaml` - Describes the namespace in kubernetes cluster, in which all logging resources are deployed.
* `elasticsearch.yaml` - Deploys ElasticSearch single node cluster for logs analytics
* `kibana.yaml` - Deploys single replica of Kibana for logs visualizing

Kubernetes plugin, already installed in _Fluentd_ image for _ElasticSearch_, enriches the collected logs with additional kubernetes-related metadata, such as _pod id_, _namespace_, _node name_, _image name_ etc.

#### Logging Stack Deployment on Kind Kubernetes Cluster

It is possible to use `kubectl apply -f logging/` to deploy all of above resources using single command, but the files are executed in **alphabetical order** (which may yield errors like trying to create resource in a namespace which is not yet created).\
Note, that you can deploy the logging stack independently from an Blog Application. In this case, all the logs will be related to only fluentd service itself.
