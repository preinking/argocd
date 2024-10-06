#!/bin/bash
DIRNAME=`dirname $0`

if [ -z ${ARGOCD_NS+x} ];then
  ARGOCD_NS='argocd'
fi

if [ -z ${1+x} ]; then
  VALUES_FILE="${DIRNAME}/argo-cd/values.yaml"
  echo "INFO: Using default values file './argo-cd/values.yaml'"
else
  if [ -f $1 ]; then
    echo "INFO: Using values file $1"
    VALUES_FILE=$1
  else
    echo "ERROR: No file exist $1"
    exit 1
  fi
fi

echo "INFO: Argocd will be installed on $ARGOCD_NS namespace with values file $VALUES_FILE"
echo -n "Do you want to proceed? [y/n]: "
read ans
if [ "$ans" == "y" ]; then
  # Run Helm upgrade or install
  helm upgrade --install argocd ./argo-cd \
    --namespace="$ARGOCD_NS" \
    --create-namespace \
    -f "$VALUES_FILE"

  # Check if Helm command was successful
  if [ $? -eq 0 ]; then
    echo "INFO: Helm upgrade/install successful."

    # Apply the kubectl patch to the argocd-server service
    kubectl patch service argocd-server -n "$ARGOCD_NS" \
      --patch '{
        "metadata": {
          "annotations": {
            "omni-kube-service-exposer.sidero.dev/port": "50080",
            "omni-kube-service-exposer.sidero.dev/label": "ArgoCD",
            "omni-kube-service-exposer.sidero.dev/icon": "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"
          }
        }
      }'

    # Check if the patch was successful
    if [ $? -eq 0 ]; then
      echo "INFO: Successfully patched argocd-server service."
    else
      echo "ERROR: Failed to patch argocd-server service."
    fi
  else
    echo "ERROR: Helm upgrade/install failed."
    exit 1
  fi
else
  echo "INFO: Exit without any action."
  exit 0
fi
