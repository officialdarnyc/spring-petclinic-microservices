#!/bin/bash

local_setup=false  # TODO: configure me

if [ "$local_setup" = true ] ; then
  export LB_IP=localhost
  export PUSH_IMAGE_REGISTRY=localhost:5010
  export PULL_IMAGE_REGISTRY=my-cluster-registry:5000
else
  export LB_IP=$(kubectl get svc -n kube-system addon-http-application-routing-nginx-ingress -ojsonpath='{.status.loadBalancer.ingress[0].ip}')
  export PUSH_IMAGE_REGISTRY=officialdarnyc  # TODO: set this environment variable to the value of your image registry
  export PULL_IMAGE_REGISTRY=${PUSH_IMAGE_REGISTRY}
fi

# For Istio ingress gateway, replace line 10 with the following:
# export LB_IP=$(kubectl get svc istio-ingressgateway -n istio-system -o jsonpath='{.status.loadBalancer.ingress[0].ip}')