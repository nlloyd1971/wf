#!/bin/sh -a

set -euo pipefail

wf kubeconfig --cluster ${CLUSTER_NAME} -w ${WAYFINDER_WORKSPACE}

mkdir -p /tmp/manifests
#cp -fR /source/manifests/deployment.yaml /tmp/manifests/deployment.yaml
#cp -fR /source/manifests/* /tmp/manifests/ - IS THIS IN THE NEW IMAGE
cat <<EOF >/home/kustomization.yaml
resources:
- deployment.yaml
spec:
  containers:
  - image: ghcr.io/nlloyd1971/wf:${IMAGE_TAG}
    imagePullPolicy: Always
    name: demo
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  terminationGracePeriodSeconds: 30
EOF

echo "Getting pods"
kubectl get pods -n ${NAMESPACE_NAME}

#echo "Applying manifests"
kubectl -n ${NAMESPACE_NAME} apply --v=6 -k /home

#kubectl -n ${NAMESPACE_NAME} apply --v=6 -f /home/deployment.yaml
