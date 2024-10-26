#!/bin/sh
# * require kubectl
SCRIPT_DIR=$(dirname "$0")
TRAEFIK_DIR="$SCRIPT_DIR/traefik"

if ! [[ "$KUBECONFIG" =~ "treboul" ]]; then
  echo "KUBECONFIG is not in directory of /treboul/ - '$KUBECONFIG'"
  exit 1
fi

# Install Traefik Resource Definitions:
kubectl apply -f "$TRAEFIK_DIR"/kubernetes-crd-definition-v1.yml

# Install RBAC for Traefik:
kubectl apply -f "$TRAEFIK_DIR"/kubernetes-crd-rbac.yml