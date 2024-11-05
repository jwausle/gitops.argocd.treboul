#!/bin/bash
K3S_IMAGE="rancher/k3s:v1.24.10-k3s1"
K3S_IMAGE="rancher/k3s:v1.31.1-k3s1"
K3S_IMAGE="rancher/k3s:v1.29.9-k3s1"

CONTAINER_NAME="k3s"
if docker stats --no-stream $CONTAINER_NAME; then
  echo "Cluster $CONTAINER_NAME is already running"
  exit 0
fi

EXTERNAL_IP=${EXTERNAL_IP:-$1}
if [[ -z $EXTERNAL_IP ]]; then
  echo "Please set EXTERNAL_IP"
  exit 1
fi

SCRIPT_DIR=$(dirname "$0")
SCRIPT_PATH="$( cd -- "$SCRIPT_DIR" >/dev/null 2>&1 ; pwd -P )"

# Should be start from project root (~pwd)
rm -rf "$SCRIPT_PATH"/.k3s
mkdir "$SCRIPT_PATH"/.k3s
rm -rf "$SCRIPT_PATH"/.k3s-pv
mkdir "$SCRIPT_PATH"/.k3s-pv

# Handle SIG_INT
function breakup() { docker stop k3s; }
trap breakup INT

sudo docker run \
  -d \
  --rm \
  --net=host \
  --name $CONTAINER_NAME \
  --tmpfs /run \
  --tmpfs /var/run \
  -p 6443:6443 \
  -p 443:443 \
  -p 80:80 \
  -e K3S_TOKEN=supersecret \
  -e K3S_KUBECONFIG_OUTPUT=/output/kubeconfig.yaml \
  -e K3S_KUBECONFIG_MODE=666 \
  -v "$SCRIPT_PATH"/.k3s:/output \
  -v "$SCRIPT_PATH"/.k3s-pv:/var/lib/rancher/k3s/storage \
  -v "$SCRIPT_PATH"/docker-volume-k3s/"$EXTERNAL_IP":/etc/rancher/k3s \
  --privileged "$K3S_IMAGE" \
  server --cluster-init --disable=traefik

sleep 1

echo
echo "export KUBECONFIG=$SCRIPT_PATH/.k3s/kubeconfig.yaml"

if [[ $* =~ --attach ]]; then
  docker logs -f k3s
fi
