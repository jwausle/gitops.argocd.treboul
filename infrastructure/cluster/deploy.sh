#!/bin/sh

SCRIPT_DIR=$(dirname "$0")
SCRIPT_PATH="$(cd -- "$SCRIPT_DIR" >/dev/null 2>&1 ; pwd -P )"

EXTERNAL_IP=${EXTERNAL_IP:-$1}

if [[ -z $EXTERNAL_IP ]]; then
  echo "Please set EXTERNAL_IP"
  exit 1
fi

export KUBECONFIG="$SCRIPT_PATH/k3s-cluster/.k3s/kubeconfig.yaml"

bash "$SCRIPT_PATH"/k3s-cluster/deploy-traefik.sh "$EXTERNAL_IP"
echo
bash "$SCRIPT_PATH"/k3s-cluster/deploy-argocd.sh

