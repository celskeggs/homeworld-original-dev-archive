#!/bin/bash
set -e

if [ "X$1" = "X" ]
then
	echo "Usage: init-flannel.sh <NETWORK>" 1>&2
	exit 1
fi

set -u

source /etc/hyades/flannel.conf

AUTHOPT="--ca-file /etc/etcd/ca.pem --key-file /etc/hyades/flannel-etcd-key.pem --cert-file /etc/hyades/flannel-etcd.pem"

export ETCDCTL_API=2

/tmp/etcdctl --endpoints ${ETCD_ENDPOINTS} ${AUTHOPT} set /coreos.com/network/config "{ \"network\": \"$1\" }"
