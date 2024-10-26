#!/bin/sh

SCRIPT_DIR=$(dirname "$0")
SCRIPT_PATH="$(cd -- "$SCRIPT_DIR" >/dev/null 2>&1 ; pwd -P )"

export KUBECONFIG="$SCRIPT_PATH/k3s-cluster/.k3s/kubeconfig.yaml"

bash "$SCRIPT_PATH"/k3s-cluster/deploy-traefik.sh
echo
bash "$SCRIPT_PATH"/k3s-cluster/deploy-argocd.sh

