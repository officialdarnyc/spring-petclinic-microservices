# Distributed version of Spring PetClinic

[![Open in Gitpod](https://gitpod.io/button/open-in-gitpod.svg)](https://gitpod.io/#https://github.com/officialdarnyc/spring-petclinic-microservices) [![Open in GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://github.com/codespaces/new?hide_repo_select=true&ref=main&repo=7517918)

This repository is derived from the [Spring PetClinic Microservices](https://github.com/spring-petclinic/spring-petclinic-microservices) version. It has been modified describing how to build the container image for each of the microservice (vets, visits, customers, and petclinic-frontend) and deploy them to a managed K8s service, AKS.

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

### Set up MySQL databases

Using the K8s package manager, Helm, deploy separate database statefulset for each microservice.

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
helm install vets-db-mysql bitnami/mysql --namespace spring-petclinic --set auth.database=service_instance_db
helm install visits-db-mysql bitnami/mysql --namespace spring-petclinic --set auth.database=service_instance_db
helm install customers-db-mysql bitnami/mysql --namespace spring-petclinic --set auth.database=service_instance_db
```

### Deploying the microservices

Apply the Kubernetes manifests located in the `k8s-manifests/deploy` directory to create the Kubernetes objects, ServiceAccount, Deployment, and Service, for each microservice.

```bash
cat k8s-manifests/deploy/*.yaml | envsubst | kubectl apply -f -
```

You can now browse to that IP in your browser and see the application running.


## License
This project is licensed under the [MIT License](LICENSE).

