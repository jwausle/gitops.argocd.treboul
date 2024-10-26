SCRIPT_DIR=$(dirname "$0")
SCRIPT_PATH="$( cd -- "$SCRIPT_DIR" >/dev/null 2>&1 ; pwd -P )"

CONTAINER_NAME="registry"

if docker stats --no-stream $CONTAINER_NAME; then
  echo "Docker $CONTAINER_NAME is already running"
  exit 0
fi

docker run -d --rm \
    -p 5001:5000 \
    --name $CONTAINER_NAME \
    -v "$SCRIPT_PATH"/data:/var/lib/registry \
    -v "$SCRIPT_PATH"/auth:/auth \
    -e "REGISTRY_AUTH=htpasswd" \
    -e "REGISTRY_AUTH_HTPASSWD_REALM=Registry Realm" \
    -e REGISTRY_AUTH_HTPASSWD_PATH=/auth/htpasswd \
    registry:2