#!/bin/bash
SCRIPT_DIR=$(dirname $0)

NAMESPACE="default"
NAME="${1:-whoami}"

TMP_FILE=$(mktemp -t mips-whoami-XXX)
cat <<EOF > $TMP_FILE
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${NAME}
spec:
  selector:
    matchLabels:
      app: ${NAME}
  template:
    metadata:
      labels:
        app: ${NAME}
    spec:
      containers:
        - name: ${NAME}
          image: docker.treboul.localhost/containous/whoami:latest
          imagePullPolicy: Always
          ports:
            - name: http
              containerPort: 80
              protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}
  labels:
    app: ${NAME}
spec:
  type: ClusterIP
  ports:
    - port: 80
      targetPort: http
      protocol: TCP
      name: http
  selector:
    app: ${NAME}

---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}
spec:
  entryPoints:
    - web
  routes:
    - match: PathPrefix(\`/whoami/\`)
      kind: Rule
      middlewares:
        - name: ${NAME}
      services:
        - name: whoami
          port: http
---
apiVersion: traefik.io/v1alpha1
kind: IngressRoute
metadata:
  name: ${NAME}-tls
  namespace: ${NAMESPACE}
spec:
  entryPoints:
    - websecure
  routes:
    - match: PathPrefix(\`/whoami/\`)
      kind: Rule
      middlewares:
        - name: ${NAME}
      services:
        - name: whoami
          port: http
  tls:
    store:
      name: mips-traefik-tls
---
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: ${NAME}
  namespace: ${NAMESPACE}
spec:
  stripPrefix:
    prefixes:
      - /whoami
      - /whoami/
EOF

# Install mips-postgres:5432
if [[ "$*" == *"--delete"* ]]; then
  kubectl delete --namespace ${NAMESPACE} deploy ${NAME}
  kubectl delete --namespace ${NAMESPACE} svc ${NAME}
  kubectl delete --namespace ${NAMESPACE} ingressRoute ${NAME}
  kubectl delete --namespace ${NAMESPACE} ingressRoute ${NAME}-tls
else
  kubectl apply --namespace ${NAMESPACE} --filename "${TMP_FILE}"
fi
