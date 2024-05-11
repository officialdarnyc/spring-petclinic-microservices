## Deploying the microservices with Istio Service Mesh enabled in the cluster

1. Using [this](https://istio.io/latest/docs/setup/getting-started/#download) guide, download Istio and add the `istioctl` CLI to your system path

2. Install Istio in the Kubernetes cluster:
```bash
istioctl install -f k8s-manifests/ingress/istio/istio-install-manifest.yaml
```

3. Verify the Istio installation in the cluster
```bash
istioctl verify-install
```

4. Verify the Istio Ingress Gateway has been assigned a Public IP:
```bash
kubectl get svc istio-ingressgateway -n istio-system
```

5. Label the `spring-petclinic` namespace for sidecar injection:
```bash
kubectl label ns spring-petclinic istio-injection=enabled
```

6. Deploy the MySQL databases and each of the microservice following the guide in this [README](https://github.com/officialdarnyc/spring-petclinic-microservices?tab=readme-ov-file#set-up-mysql-databases)

## Expose the services using Istio Gateway

1. Apply the gateway configuration which creates a listener on the ingress gateway for HTTP traffic on port 80
```bash
kubectl apply -f k8s-manifests/ingress/istio/istio-gateway.yaml
```

2. Configure routing rules for incoming traffic to each of the microservice:
```bash
kubectl apply -f k8s-manifests/ingress/istio/routes.yaml
```
Visit the application using the public IP assigned to the Istio Ingress Gateway
