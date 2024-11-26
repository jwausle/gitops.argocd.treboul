SCRIPT_DIR=$(dirname "$0")
SCRIPT_PATH="$( cd -- "$SCRIPT_DIR" >/dev/null 2>&1 ; pwd -P )"

CONTAINER_NAME="docker-registry"
CONTAINER_IMAGE="registry:2"
CONTAINER_VOLUME="docker-registry"
CONTAINER_PORT=5001

if docker stats --no-stream $CONTAINER_NAME; then
  echo "Docker $CONTAINER_NAME is already running"
  exit 0
fi

if ! docker volume ls | grep -q $CONTAINER_VOLUME; then
  docker volume create $CONTAINER_VOLUME
fi

docker run -d --rm \
    -p $CONTAINER_PORT:5000 \
    --name $CONTAINER_NAME \
    -v "$CONTAINER_VOLUME":/var/lib/registry \
    -v "$SCRIPT_PATH"/auth:/auth \
    -e "REGISTRY_AUTH=htpasswd" \
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
    $CONTAINER_IMAGE