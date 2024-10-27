# * require helm, kubectl
SCRIPT_DIR=$(dirname "$0")

ARGOCD_DIR="$SCRIPT_DIR"/argocd
ARGOCD_REPO="https://argoproj.github.io/argo-helm"
ARGOCD_VERSION="7.6.12"
ARGOCD_APP_VERSION="2.12.6" # Should in sync with `Chart.yaml$.appVersion`

# There are some hardcoded drawbacks in used argocd/**/*.yaml files regarding namespace
ARGOCD_RELEASE_NAME="argocd"
ARGOCD_RELEASE_NAMESPACE="argocd"
ARGOCD_RELEASE_CRDS_DIR="$ARGOCD_DIR/argocd-$ARGOCD_APP_VERSION-crds"

if ! [[ "$KUBECONFIG" =~ "treboul" ]]; then
  echo "KUBECONFIG is not in directory of /treboul/ - '$KUBECONFIG'"
  exit 1
fi

if [ ! -d "$ARGOCD_RELEASE_CRDS_DIR" ]; then
  echo "Directory $ARGOCD_RELEASE_CRDS_DIR does not exist. Doc: https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#kustomize"
  exit 2
fi

HELMCHART_ONLY=false
if [[ "$*" =~ "--helm-only" ]]; then
  HELMCHART_ONLY=true
fi

install-argocd-helm() {
  helm repo add argocd-repo https://argoproj.github.io/argo-helm
  helm upgrade --install $ARGOCD_RELEASE_NAME \
       argocd-repo/argo-cd \
       --namespace $ARGOCD_RELEASE_NAMESPACE --create-namespace \
       --version $ARGOCD_VERSION \
       --skip-crds \
       -f "$ARGOCD_DIR"/helm-values.yaml
}

install-argocd-crds() {
  kubectl create namespace $ARGOCD_RELEASE_NAMESPACE

  # Install ArgoCD crds (only) - with a unclear workaround
  # - Unclear why it is not working with ...
  # - kubectl apply -k https://github.com/argoproj/argo-cd/manifests/crds\?ref\=$ARGOCD_APP_VERSION
  # - Then the argocd-applicationset-controller and argocd-server not starting (CrashLoopBackOff)
  kubectl apply -k "$ARGOCD_RELEASE_CRDS_DIR"
  kubectl delete ClusterRoleBindings --selector 'app.kubernetes.io/part-of=argocd'
  kubectl delete ClusterRoles --selector 'app.kubernetes.io/part-of=argocd'
  kubectl delete namespace $ARGOCD_RELEASE_NAMESPACE
}

if [ "$HELMCHART_ONLY" = true ]; then
  install-argocd-helm
else
  # Install ArgoCD crds
  install-argocd-crds
  # Install ArgoCD
  install-argocd-helm
  echo
  # Customize ArgoCD route `argocd.treboul.localhost`
  kubectl apply -f "$ARGOCD_DIR"/ingressroute.yaml --namespace $ARGOCD_RELEASE_NAMESPACE
fi

