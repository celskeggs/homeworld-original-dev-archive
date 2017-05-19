#!/bin/bash
set -e -u

# use known apiserver
SRVOPT="--kubeconfig=/etc/hyades/kubeconfig"
# synchronize every minute (TODO: IS THIS A GOOD AMOUNT OF TIME?)
SRVOPT="$SRVOPT --config-sync-period=1m"

# FOR DEBUGGING
# SRVOPT="-v4 $SRVOPT"

/usr/lib/hyades/kube-proxy $SRVOPT
