#!/bin/sh
# * require helm, kubectl
SCRIPT_DIR=$(dirname "$0")

TRAEFIK_DIR="$SCRIPT_DIR/traefik"
TRAEFIK_REPO="https://traefik.github.io/charts"
TRAEFIK_VERSION="32.1.1"

REGISTRY_DIR="$SCRIPT_DIR/../docker-registry"
HELMREPO_DIR="$SCRIPT_DIR/../helm-repository"

if ! [[ "$KUBECONFIG" =~ "treboul" ]]; then
  echo "KUBECONFIG is not in directory of /treboul/ - '$KUBECONFIG'"
  exit 1
fi

EXTERNAL_IP=${EXTERNAL_IP:-$1}
if [[ -z $EXTERNAL_IP ]]; then
  echo "Please set EXTERNAL_IP"
  exit 1
fi

install-traefik-crds () {
  # Install Traefik Resource Definitions:
  kubectl apply -f "$TRAEFIK_DIR"/kubernetes-crd-definition-v1.yml

  # Install RBAC for Traefik:
  kubectl apply -f "$TRAEFIK_DIR"/kubernetes-crd-rbac.yml
}

# Install traefik
install-traefik () {
  echo
  helm repo add traefik "$TRAEFIK_REPO"
  echo
  helm upgrade --install traefik traefik/traefik \
     --version "$TRAEFIK_VERSION" \
     --namespace traefik --create-namespace \
     --skip-crds \
      -f "${TRAEFIK_DIR}"/helm-values.yaml
}

install-traefik-customize () {
  echo
  kubectl apply -f "${REGISTRY_DIR}/$EXTERNAL_IP"/ingressroute.yaml
  echo
  kubectl apply -f "${HELMREPO_DIR}/$EXTERNAL_IP"/ingressroute.yaml
}

install-traefik-crds
install-traefik
install-traefik-customize