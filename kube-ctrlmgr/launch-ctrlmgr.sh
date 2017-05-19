#!/bin/bash
set -e -u

source /etc/hyades/ctrlmgr.conf

# use known apiserver
SRVOPT="--kubeconfig=/etc/hyades/kubeconfig"

SRVOPT="$SRVOPT --cluster-cidr=${CLUSTER_CIDR}"
SRVOPT="$SRVOPT --node-cidr-mask-size=24"
SRVOPT="$SRVOPT --service-cluster-ip-range=${SERVICE_CIDR}"
SRVOPT="$SRVOPT --cluster-name=hyades"

SRVOPT="$SRVOPT --leader-elect"

# granting service tokens
SRVOPT="$SRVOPT --service-account-private-key-file=/etc/hyades/serviceaccount.key"
SRVOPT="$SRVOPT --root-ca-file=/etc/hyades/kubeca.pem"

# FOR DEBUGGING
# SRVOPT="-v4 $SRVOPT"

/usr/lib/hyades/kube-controller-manager $SRVOPT
