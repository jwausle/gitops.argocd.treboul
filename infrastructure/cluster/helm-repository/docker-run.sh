SCRIPT_DIR=$(dirname "$0")
SCRIPT_PATH="$( cd -- "$SCRIPT_DIR" >/dev/null 2>&1 ; pwd -P )"

CONTAINER_NAME="helm-repository"
CONTAINER_IMAGE="ghcr.io/helm/chartmuseum:v0.16.2"
CONTAINER_VOLUME="helm-repository"
CONTAINER_PORT=5002
USERNAME="admin"
PASSWORD="admin"

if docker stats --no-stream $CONTAINER_NAME; then
  echo "Helm repository $CONTAINER_NAME is already running"
  exit 0
fi

if ! docker volume ls | grep -q $CONTAINER_VOLUME; then
  docker volume create $CONTAINER_VOLUME
  chmod -R 777 $(docker volume inspect $CONTAINER_VOLUME --format '{{ .Mountpoint }}')
fi

docker run --rm -d \
    --name $CONTAINER_NAME \
    -p $CONTAINER_PORT:8080 \
    -e DEBUG=1 \
    -e STORAGE=local \
    -e STORAGE_LOCAL_ROOTDIR=/charts \
    -v "$CONTAINER_VOLUME":/charts \
    $CONTAINER_IMAGE \
    --basic-auth-user=$USERNAME \
    --basic-auth-pass=$PASSWORD \
    --auth-anonymous-get
