#!/bin/sh -a

set -euo pipefail

wf kubeconfig --cluster ${CLUSTER_NAME} -w ${WAYFINDER_WORKSPACE}

mkdir -p /tmp/manifests
cp -fR ./source/manifests/deployment.yaml ./tmp/manifests/deployment.yaml
#cp -fR /source/manifests/* /tmp/manifests/
cat <<EOF >/tmp/manifests/kustomization.yaml
resources:
- deployment.yaml
- ingress.yaml
images:
- name: application
  newName: ghcr.io/appvia/application
  newTag: ${IMAGE_TAG}
patches:
  - target:
      kind: Ingress
      name: application-ingress
    patch: |-
      - op: replace
        path: /spec/rules/0/host
        value: main.${DNS_ZONE}
      - op: replace
        path: /spec/tls/0/hosts/0
        value: main.${DNS_ZONE}
EOF

echo "Getting pods"
kubectl get pods -n ${NAMESPACE_NAME}

echo "Applying manifests"
kubectl -n ${NAMESPACE_NAME} apply --v=6 -k /tmp/manifests
