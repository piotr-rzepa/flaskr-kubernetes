# Flask Blog Application on Kubernetes

Sample Flask app from documentation's tutorial, deployed on multi-node Kubernetes cluster using Kind.

Link to the Flask app on GitHub: <https://github.com/pallets/flask/tree/main/examples/tutorial>
Link to the Flask app on Flask Documentation: <https://flask.palletsprojects.com/en/2.2.x/tutorial/>

The Application is being gradually moved from local setup to the container setup and finally, to the Kubernetes cluster.

Stages of improvements:

1. Docker (Building docker images manually and deploying using bash scripts).
2. Docker-compose (Building and deploying using Docker-compose).
3. Kind + Kubernetes (Building and deploying using YAML manifests and kubectl) [current setup].
4. **Kind + Kubernetes + Helm (Building and deploying using Helm Charts) [current setup].**

## App setup

Application is modified to use external MySQL database instead of in-memory SQLite3.
MySQL database instance is listening on port `3306` (default) and initialized by `db/schema.sql` file, which is responsible for creating the database, tables and user, used by Flask application.

## Kubernetes Kind Cluster setup

Kubernetes cluster consists of two worker nodes and one control-plane node, all running K8s _v1.26.0_, deployed using [Kind](https://kind.sigs.k8s.io/).
The config file for Kind Cluster is defined in `kind-example-config.yaml`. You can create the cluster running `kind create cluster --config kind-example-config.yaml`.
The following addition in the config file:

```yaml
  extraPortMappings:
    - containerPort: 30423
      hostPort: 30423
      listenAddress: "0.0.0.0"
      protocol: TCP
```

Is required if you want to reach the pods via a _NodePort_ service type, which exposes the same port on worker node as defined in `hostPort` key-value pair.
The Application does not have a Ingress Controller for managing external HTTP traffic, so it's the recommended way for reaching the service.

Alternatively, you can reach the pods behind a service by using `kubectl port-forward svc/<service name> <port on host>:5000`. You can then open the browser and visit `localhost:<port on host>`.

The default setup consists of **two** replicas of Flask application, which state is controlled by _Deployment Controller_, exposed by a _NodePort_ type service to the user.
The Flask communicates with a MySQL instance through headless service, which exposes a Stateful Set, desired to manage the state of MySQL database.

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

## Deployment of the Application using Helm

First, a namespace where the resources should be placed has to be created (if it's different from the default namespace):

```bash
kubectl create ns <name of namespace>
```

Then, we can install the blog application using Helm package manager

```bash
# In project's root directory
helm install flask-blog --generate-name --atomic --namespace <YOUR_NAMESPACE> --dependency-update
```

`--atomic` flag removes the resources in case of an installation failure.

Helm Chart notes contain important information regarding application, including access, retrieving the IP address and/or ports. It also explain how to create and visualize data source from fluentd logs in Kibana Dashboard.\
The Helm Chart notes will be displayed each time a new chart release is being installed or upgraded.
To see the notes at any point, run

```bash
helm get notes <YOUR_RELEASE_NAME> -n <YOUR_NAMESPACE>
```
