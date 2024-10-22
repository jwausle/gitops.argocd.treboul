#!/bin/sh
# * require helm
SCRIPT_DIR=$(dirname "$0")
TRAEFIK_DIR="$SCRIPT_DIR/traefik"

if ! [[ "$KUBECONFIG" =~ "treboul" ]]; then
  echo "KUBECONFIG is not in directory of /treboul/ - '$KUBECONFIG'"
  exit 1
fi