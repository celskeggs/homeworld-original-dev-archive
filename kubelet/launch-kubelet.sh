#!/bin/bash
set -e -u

source /etc/hyades/kubelet.conf

cat >/etc/hyades/kubeconfig <<EOCONFIG
current-context: hyades
apiVersion: v1
kind: Config
clusters:
- cluster:
    api-version: v1
    certificate-authority: /etc/hyades/kubeca.pem
    server: ${APISERVER}
  name: hyades-cluster
users:
- name: kubelet-auth
  user:
    client-certificate: /etc/hyades/kubelet.pem
    client-key: /etc/hyades/kubelet-key.pem
contexts:
- context:
    cluster: hyades-cluster
    user: kubelet-auth
  name: hyades
EOCONFIG

KUBEOPT=""
# just use one API server for now -- TODO: BETTER HIGH-AVAILABILITY
KUBEOPT="$KUBEOPT --kubeconfig=/etc/hyades/kubeconfig --require-kubeconfig"
# don't register as schedulable
KUBEOPT="$KUBEOPT --register-schedulable=false"
# turn off anonymous authentication
KUBEOPT="$KUBEOPT --anonymous-auth=false"
# add kubelet auth certs
KUBEOPT="$KUBEOPT --tls-cert-file=/etc/hyades/kubelet.pem --tls-private-key-file=/etc/hyades/kubelet-key.pem"
# add client certificate authority
KUBEOPT="$KUBEOPT --client-ca-file=/etc/hyades/kubeca.pem"
# turn off cloud provider detection
KUBEOPT="$KUBEOPT --cloud-provider="
# use rkt
KUBEOPT="$KUBEOPT --container-runtime rkt"
# pod manifests
KUBEOPT="$KUBEOPT --pod-manifest-path=/etc/hyades/manifests/"
# DNS
KUBEOPT="$KUBEOPT --cluster-dns $CLUSTER_DNS --cluster-domain $CLUSTER_DOMAIN"
# experimental options to better enforce env config
KUBEOPT="$KUBEOPT --experimental-fail-swap-on"

/usr/lib/hyades/kubelet $KUBEOPT
