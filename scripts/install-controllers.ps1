# NGINX Gateway Fabric Installation
helm install ngf oci://ghcr.io/nginx/charts/nginx-gateway-fabric --create-namespace -n nginx-gateway

# Cert-Manager Installation with Gateway API enabled
helm install cert-manager oci://quay.io/jetstack/charts/cert-manager --version v1.15.3 --namespace cert-manager --create-namespace --set config.apiVersion="controller.config.cert-manager.io/v1alpha1" --set config.kind="ControllerConfiguration" --set config.enableGatewayAPI=true --set crds.enabled=true