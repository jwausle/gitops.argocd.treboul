#!/bin/sh

SCRIPT_DIR=$(dirname "$0")

bash "$SCRIPT_DIR"/docker-registry/docker-run.sh
echo
bash "$SCRIPT_DIR"/helm-repository/docker-run.sh
echo
bash "$SCRIPT_DIR"/k3s-cluster/docker-run.sh