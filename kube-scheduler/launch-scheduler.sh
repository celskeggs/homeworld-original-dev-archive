#!/bin/bash
set -e -u

# use known apiserver
SRVOPT="--kubeconfig=/etc/hyades/kubeconfig"

SRVOPT="$SRVOPT --leader-elect"

# FOR DEBUGGING
# SRVOPT="-v4 $SRVOPT"

/usr/lib/hyades/kube-scheduler $SRVOPT
