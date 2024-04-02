# Distributed version of the Spring PetClinic application

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/officialdarnyc/spring-petclinic-microservices) [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=7517918)

This repository is derived from the open source [Spring PetClinic Microservices](https://github.com/spring-petclinic/spring-petclinic-microservices) application. It has been modified describing how to build the container image for each of the microservice (vets, visits, customers, and petclinic-frontend) and deploy them to a managed K8s service, AKS.

For general information about the PetClinic sample application, see the [Spring PetClinic](https://spring-petclinic.github.io/) website.


## Building Container Image and Pushing to Docker Registry

### Choose your Docker registry

Setup an environment variable to target your Docker registry. If you're targeting Docker Hub, provide your username, for example:

```bash
export PUSH_IMAGE_REGISTRY=officialdarnyc
```

For other Docker registries, provide the full URL to your repository, for example:

```bash
export PUSH_IMAGE_REGISTRY=harbor.myregistry.com/test
```

Build all images and push them to the Docker registry:

1. Compile the apps and run the tests:

    ```bash
    mvn clean package
    ```
2. Build the images:

    ```bash
    mvn spring-boot:build-image
    ```

3. Publish the images to the container registry:

    ```bash
    ./push-images.sh
    ```

## Deploying to Kubernetes

Create the `spring-petclinic` namespace for the deployment:

```bash
kubectl apply -f k8s-manifests/namespace.yaml
```

### Install Nginx Ingess Controller

Run:

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.3.0/deploy/static/provider/cloud/deploy.yaml
```

Verify Nginx Ingress Controller has been assigned a Public IP:

```bash
kubectl get service ingress-nginx-controller -n ingress-nginx
```

### Set up MySQL databases

Using the K8s package manager, Helm, deploy separate database statefulset for each microservice.

Add the bitnami repository to your helm client:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Update the bitnami charts:

```bash
helm repo update bitnami
```

Deploy the databases for each microservice with `service_instance_db` set as the DB name:

1. Vets service:
    ```bash
    helm install vets-db-mysql bitnami/mysql --namespace spring-petclinic --set auth.database=service_instance_db
    ```
2. Visits service:
    ```bash
    helm install visits-db-mysql bitnami/mysql --namespace spring-petclinic --set auth.database=service_instance_db
    ```
3. Customers service:
    ```bash
    helm install customers-db-mysql bitnami/mysql --namespace spring-petclinic --set auth.database=service_instance_db
    ```

### Deploying the microservices

Apply the Kubernetes manifests located in the `k8s-manifests/deploy` directory to create the Kubernetes objects - ServiceAccount, Deployment, and Service, for each microservice. The manifests reference the image registry environment variable, and so are passed through `envsubst` for resolution before being applied to the K8s cluster.

```bash
cat k8s-manifests/deploy/*.yaml | envsubst | kubectl apply -f -
```

### Expose the services through an Ingress

The `k8s-manifests/ingress/ingress.yaml` will be used to configure path-based routing to direct traffic to the appropriate application endpoints.

```bash
kubectl apply -f k8s-manifests/ingress/ingress.yaml
```

Access the app via the Public IP assigned to the ingress controller and see the application running.


## License
This project is licensed under the [MIT License](LICENSE).

