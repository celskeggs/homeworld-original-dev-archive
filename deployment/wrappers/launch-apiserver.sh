#!/bin/bash
set -e -u

source /etc/hyades/cluster.conf
source /etc/hyades/local.conf

SRVOPT=""

# TODO: CHANGE THIS
SRVOPT="$SRVOPT --authorization-mode=AlwaysAllow"
# number of api servers
SRVOPT="$SRVOPT --apiserver-count ${APISERVER_COUNT}"
# public addresses
SRVOPT="$SRVOPT --bind-address=0.0.0.0 --advertise-address=${HOST_IP}"
# IP range
SRVOPT="$SRVOPT --service-cluster-ip-range ${SERVICE_CIDR}"
# use standard HTTPS port for secure port
SRVOPT="$SRVOPT --secure-port=443"
# etcd cluster to use
SRVOPT="$SRVOPT --etcd-servers=${ETCD_ENDPOINTS}"
# don't allow privileged containers: don't allow this kind of thing
SRVOPT="$SRVOPT --allow-privileged=false"
# disallow anonymous users
SRVOPT="$SRVOPT --anonymous-auth=false"
# various plugins for limitations and protection
SRVOPT="$SRVOPT --admission-control=NamespaceLifecycle,LimitRanger,ServiceAccount,DefaultStorageClass,ResourceQuota,DenyEscalatingExec,SecurityContextDeny"
# authenticate clients properly
SRVOPT="$SRVOPT --client-ca-file=/etc/hyades/kubeca.pem"
# do HTTPS properly
SRVOPT="$SRVOPT --tls-ca-file=/etc/hyades/kubeca.pem --tls-cert-file=/etc/hyades/kubeapi.pem --tls-private-key-file=/etc/hyades/kubeapi-key.pem"
# make sure account deletion works
SRVOPT="$SRVOPT --service-account-lookup"
# no cloud provider
SRVOPT="$SRVOPT --cloud-provider="
# authenticate the etcd cluster to us
SRVOPT="$SRVOPT --etcd-cafile /etc/etcd/ca.pem"
# authenticate us to the etcd cluster
SRVOPT="$SRVOPT --etcd-certfile /etc/hyades/kubeapi-etcd.pem --etcd-keyfile /etc/hyades/kubeapi-key.pem"
# disallow insecure port
SRVOPT="$SRVOPT --insecure-port=0"
# authenticate kubelet to us
SRVOPT="$SRVOPT --kubelet-certificate-authority /etc/hyades/kubeca.pem"
# authenticate us to kubelet
SRVOPT="$SRVOPT --kubelet-client-certificate=/etc/hyades/kubeapi.pem --kubelet-client-key=/etc/hyades/kubeapi-key.pem"
# let controller manager's service tokens work for us
SRVOPT="$SRVOPT --service-account-key-file=/etc/hyades/serviceaccount.key"

/usr/bin/hyperkube kube-apiserver $SRVOPT
