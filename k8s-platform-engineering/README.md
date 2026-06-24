# Kubernetes Platform Engineering: Gateway API and Automated TLS

## Overview
This repository demonstrates a production-ready Kubernetes routing architecture using the modern Gateway API. It decouples infrastructure configuration (managed by Platform Engineers) from application routing (managed by Application Developers) and implements automated SSL/TLS certificate provisioning using cert-manager and Let's Encrypt.

## Architecture and Technologies
* Cloud Provider: Azure Kubernetes Service (AKS)
* Package Manager: Helm
* Routing Layer: NGINX Gateway Fabric (Gateway API)
* Certificate Automation: cert-manager
* Certificate Authority: Let's Encrypt 
* DNS: nip.io (Wildcard DNS for IP resolution)

## Repository Structure
The project is structured to enforce separation of concerns between the platform layer and the application layer:

* /platform/
  * /gateway-api/: Contains the shared Gateway instance (public-gateway) that listens for external traffic.
  * /cert-manager/: Contains the ClusterIssuer configuration for Let's Encrypt ACME challenges.
* /applications/
  * /nginx-app/: Contains the application-specific Deployments, Services, and HTTPRoutes.
* /scripts/: Contains PowerShell scripts used to bootstrap the cluster controllers.
* /bin/: Contains local binary dependencies (e.g., Helm) ignored by version control.

## Prerequisites
To deploy this architecture, you will need:
* An active Azure subscription with an AKS cluster running.
* Azure CLI (az) authenticated to your tenant.
* kubectl configured to communicate with your AKS cluster.
* Helm installed (or available in the /bin/ directory).

## Deployment Instructions

### 1. Bootstrap the Controllers
First, install the required custom resource definitions (CRDs) and controllers into the cluster using Helm. Run the installation script:

.\scripts\install-controllers.ps1

### 2. Deploy the Platform Layer
Apply the infrastructure configurations to create the shared Gateway and the Let's Encrypt ClusterIssuer.

kubectl apply -f platform/cert-manager/cluster-issuer.yaml
kubectl apply -f platform/gateway-api/platform-gateway.yaml

Wait for the cloud provider to assign a public IP address to the Gateway:

kubectl get gateway public-gateway -n platform-gateway -w

### 3. Deploy the Application Layer
Update the hostname in applications/nginx-app/httproute.yaml and platform/gateway-api/platform-gateway.yaml to match your newly assigned Gateway IP (e.g., <YOUR-IP>.nip.io).

Apply the application manifests:

kubectl apply -f applications/nginx-app/namespace.yaml
kubectl apply -f applications/nginx-app/deployment.yaml
kubectl apply -f applications/nginx-app/service.yaml
kubectl apply -f applications/nginx-app/httproute.yaml

### 4. Verify TLS Automation
Check the status of the automated certificate provisioning. Cert-manager will intercept the Gateway annotation and solve the ACME HTTP-01 challenge.

kubectl get certificate -n platform-gateway

Once the status reports "READY: True", you can access the secure endpoint via a web browser at https://<YOUR-IP>.nip.io.

## Cleanup
To prevent unnecessary cloud billing, remove the resources when testing is complete.

Delete the Kubernetes resources:
kubectl delete -f applications/nginx-app/
kubectl delete -f platform/gateway-api/
kubectl delete -f platform/cert-manager/

Alternatively, delete the entire Azure Resource Group:
az group delete --name <YourResourceGroupName> --yes --no-wait