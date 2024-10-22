docker run --rm -d \
  --name chartmuseum \
  -p 5002:8080 \
  -e DEBUG=1 \
  -e STORAGE=local \
  -e STORAGE_LOCAL_ROOTDIR=/charts \
  -v $(pwd)/data:/charts \
  ghcr.io/helm/chartmuseum:v0.16.2 


#  --basic-auth-user=admin \
#  --basic-auth-pass=password
