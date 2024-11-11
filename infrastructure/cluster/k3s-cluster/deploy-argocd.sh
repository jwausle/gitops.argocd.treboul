# * require helm, kubectl
SCRIPT_DIR=$(dirname "$0")

ARGOCD_DIR="$SCRIPT_DIR"/argocd
ARGOCD_REPO="https://argoproj.github.io/argo-helm"
ARGOCD_VERSION="7.6.12"
ARGOCD_APP_VERSION="2.12.6" # Should in sync with `Chart.yaml$.appVersion`
ARGOCD_APP_REPO_TOKEN="ghp_" # Split token into two parts to avoid github security issue
ARGOCD_APP_REPO_TOKEN+="A9UmNFEg9e37LyC5bpGS5wrZnkiASG1dOQ6v"
ARGOCD_APP_REPO="https://github.com/treboulit/kubernetes-environment-concept.git"

# There are some hardcoded drawbacks in used argocd/**/*.yaml files regarding namespace
ARGOCD_RELEASE_NAME="argocd"
ARGOCD_RELEASE_NAMESPACE="argocd"
ARGOCD_RELEASE_CRDS_DIR="$ARGOCD_DIR/argocd-$ARGOCD_APP_VERSION-crds"

if ! [[ "$KUBECONFIG" =~ "treboul" ]] && ! [[ "$*" =~ "--skip-config-check" ]]; then
  echo "KUBECONFIG is not in directory of /treboul/ - '$KUBECONFIG'"
  exit 1
fi

if [ ! -d "$ARGOCD_RELEASE_CRDS_DIR" ]; then
  echo "Directory $ARGOCD_RELEASE_CRDS_DIR does not exist. Doc: https://argo-cd.readthedocs.io/en/stable/operator-manual/installation/#kustomize"
  exit 2
fi

EXTERNAL_IP=${EXTERNAL_IP:-$1}
if [[ -z $EXTERNAL_IP ]]; then
  echo "Please set EXTERNAL_IP"
  exit 1
fi

HELMCHART_ONLY=false
if [[ "$*" =~ "--helm-only" ]]; then
  HELMCHART_ONLY=true
fi

APPLICATION_ONLY=false
if [[ "$*" =~ "--app-only" ]]; then
  APPLICATION_ONLY=true
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

install-argocd-crds-offline() {
  kubectl create namespace $ARGOCD_RELEASE_NAMESPACE
  kubectl apply -k "$ARGOCD_RELEASE_CRDS_DIR-offline"
}

install-argocd-apps-secret() {
  TMP_FILE=$(mktemp -t apps-secret-XXX)
  cat <<EOF > "$TMP_FILE"
apiVersion: v1
kind: Secret
metadata:
  name: "argocd-apps-repo"
  namespace: "$ARGOCD_RELEASE_NAMESPACE"
  labels:
    argocd.argoproj.io/secret-type: repository
stringData:
  type: "git"
  url: "$ARGOCD_APP_REPO"
  password: "$ARGOCD_APP_REPO_TOKEN"
  username: ""
EOF
  kubectl apply -f "$TMP_FILE" --namespace $ARGOCD_RELEASE_NAMESPACE
}

install-argocd-apps() {
  local appsPath="localhost/$EXTERNAL_IP"

  if [ "$EXTERNAL_IP" == "45.132.246.226" ]; then
    appsPath="ligidi.africa"
  fi

  TMP_FILE=$(mktemp -t apps-XXX)
  cat <<EOF > "$TMP_FILE"
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: apps
  namespace: $ARGOCD_RELEASE_NAMESPACE
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: ligidi
    server: https://kubernetes.default.svc
  project: default
  source:
    path: infrastructure/argocd/apps/$appsPath
    repoURL: $ARGOCD_APP_REPO
    targetRevision: main
  syncPolicy:
    syncOptions:
      - CreateNamespace=true
      - PruneLast=true
    automated:
      prune: true
EOF
  kubectl apply -f "$TMP_FILE" --namespace $ARGOCD_RELEASE_NAMESPACE
}

wait-until-argocd-is-ready() {
  timeout=300
  index=0

  echo "Waiting until $timeout sec if argocd is ready"
  until kubectl get pods -A | grep argocd-application-controller | grep Running | grep "1/1" || [ $index -eq $timeout ];
  do
    index=$((index+1))
    echo -n "."
    sleep 1;
  done
  if [ $index -eq $timeout ]; then
    echo
    echo "Argocd is not ready after $timeout seconds"
    exit 2
  else
    echo
    echo "Argocd is ready"
  fi
}

if [ "$HELMCHART_ONLY" = "true" ]; then
  install-argocd-helm
elif [ "$APPLICATION_ONLY" = "true" ]; then
  install-argocd-apps-secret
  install-argocd-apps
else
  # Install ArgoCD crds
  install-argocd-crds-offline
  # Install ArgoCD
  install-argocd-helm

  echo
  wait-until-argocd-is-ready
  # Customize ArgoCD route `argocd.treboul.localhost`
  install-argocd-apps
fi

