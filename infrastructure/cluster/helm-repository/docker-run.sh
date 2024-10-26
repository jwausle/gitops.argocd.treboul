SCRIPT_DIR=$(dirname "$0")
SCRIPT_PATH="$( cd -- "$SCRIPT_DIR" >/dev/null 2>&1 ; pwd -P )"

CONTAINER_NAME="chartmuseum"

if docker stats --no-stream $CONTAINER_NAME; then
  echo "Helm repository $CONTAINER_NAME is already running"
  exit 0
fi

docker run --rm  \
    --name $CONTAINER_NAME \
    -p 5002:8080 \
    -e DEBUG=1 \
    -e STORAGE=local \
    -e STORAGE_LOCAL_ROOTDIR=/charts \
    -v "$SCRIPT_PATH"/data:/charts \
    ghcr.io/helm/chartmuseum:v0.16.2
    --basic-auth-user=admin \
    --basic-auth-pass=admin \
    --auth-anonymous-get
