# Constraints

List of hidden requirements that are not directly visible in the process/architecture.

## ArgoCD access token is bound to [jwausle](https://github.com/jwausle).

The access token from ArgoCD within the cluster to access 
[this](https://github.com/treboulit/kubernetes-environment-concept) repo 
is bound to [jwausle](https://github.com/jwausle). 

> The token is used in [deploy-argocd.sh](./infrastructure/cluster/k3s-cluster/deploy-argocd.sh) script. 

## Monitoring CRDs must be applied manually

```
VERSION=v0.78.1
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/monitoring.coreos.com_prometheuses.yaml --force-conflicts=true --server-side
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagerconfigs.yaml --force-conflicts=true --server-side
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/monitoring.coreos.com_alertmanagers.yaml --force-conflicts=true --server-side
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/monitoring.coreos.com_podmonitors.yaml --force-conflicts=true --server-side
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/monitoring.coreos.com_probes.yaml --force-conflicts=true --server-side
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/monitoring.coreos.com_prometheusagents.yaml --force-conflicts=true --server-side
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/monitoring.coreos.com_prometheusrules.yaml --force-conflicts=true --server-side
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/monitoring.coreos.com_scrapeconfigs.yaml --force-conflicts=true --server-side
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/monitoring.coreos.com_servicemonitors.yaml --force-conflicts=true --server-side
kubectl apply -f https://raw.githubusercontent.com/prometheus-operator/prometheus-operator/$VERSION/example/prometheus-operator-crd/monitoring.coreos.com_thanosrulers.yaml --force-conflicts=true --server-side
```

## The loki/grafana PVC must `chmod 0777` to be writeable

```
chmod -R 777 $(docker volume inspect docker-registry --format '{{ .Mountpoint }}')
chmod -R 777 $(docker volume inspect helm-repository --format '{{ .Mountpoint }}')
```

> Otherwise, show grafana the error message: `failed to load chunk 'ZmFrZS8yNmE2NmQzOTc0Y2M5MDMxOjE5MzkzMzFlODFjOjE5MzkzOWZjNTFlOmU5MGEwZTFl'`