#!/bin/sh

SCRIPT_DIR=$(dirname "$0")
EXTERNAL_IP=${EXTERNAL_IP:-$1}

if [[ -z $EXTERNAL_IP ]]; then
  echo "Please set EXTERNAL_IP"
  exit 1
fi

bash "$SCRIPT_DIR"/docker-registry/docker-run.sh
echo
bash "$SCRIPT_DIR"/helm-repository/docker-run.sh
echo
bash "$SCRIPT_DIR"/k3s-cluster/docker-run.sh "$EXTERNAL_IP"