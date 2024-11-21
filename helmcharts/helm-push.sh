#!/bin/sh
SCRIPT_DIR=$(dirname "$0")
HELMCHART=$1

if [ -z "$HELMCHART" ]; then
  echo "Usage: bash $0 <helm-chart>"
  exit 1
fi

if [ ! -d "$SCRIPT_DIR/$HELMCHART" ]; then
  echo "Helmchart directory not found: $SCRIPT_DIR/$HELMCHART"
  exit 2
fi

TMP_DIR=$(mktemp -d -t helm-XXX)
if ! helm package $SCRIPT_DIR/$HELMCHART -d $TMP_DIR ; then
  echo "Helmchart packaging failed: $HELMCHART"
  exit 3
fi

HELMCHART_FILE=$(find $TMP_DIR | grep .tgz)
curl -k --data-binary "@$HELMCHART_FILE"  https://admin:admin@helm.ligidi.africa/api/charts
