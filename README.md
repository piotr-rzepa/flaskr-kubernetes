# Flask Tutorial Blog Application on Kubernetes

Sample Flask app from documentation's tutorial, deployed on multi-node Kubernetes cluster using Kind.

Link to the Flask app on GitHub: https://github.com/pallets/flask/tree/main/examples/tutorial

Link to the Flask app on Flask Documentation: https://flask.palletsprojects.com/en/2.2.x/tutorial/

The Application is being gradually moved from local on-premise setup to the Kubernetes cluster.

The steps include:

* Deployment of MySQL and Flask app using separate Dockerfiles and Bash scripts for automatic provisioning
* Deployment of MYSQL and Flask app using Docker-Compose
* Deployment of dockerized MySQL and Flask app in Kubernetes cluster using simple YAML configuration
* Deployment o dockerized MySQL and Flask app in Kubernetes cluster using YAML configuration + Kustomize templating
* Deployment o dockerized MySQL and Flask app in Kubernetes cluster using Helm Charts

Apart from moving the application to Kubernetes, future planned additions include:

* Adding ELK/EFK stack for centralized and standarized monitoring
* Adding Prometheus/Grafana setup for application monitoring
* Adding HPA (for app) / VPA (for MySQL)

## Flask app setup

Application is configured to use MySQL database instead of in-memory SQLite3.

## Kubernetes setup

Kubernetes cluster consists of two worker nodes and one control-plane node, all running K8s v1.26.0

## Running Application using deployment script (separate Dockerfiles)

```bash
$ chmod +x scripts/deploy.sh
$ ./scripts/deploy.sh \
    --network <network>
    --mysql <image_name>
    --password <mysql_root_password>
    --flask <image_name>
```

You can pass an additional `--prune` flag to remove all the existing resources before provisioning new ones using the script.
