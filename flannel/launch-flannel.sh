#!/bin/bash
set -e -u

source /etc/hyades/flannel.conf

# if [ "X${ETCD_ENDPOINTS}" = "X" ]
# then
# 	echo ""
# fi

# allow verification of etcd certs
FLANOPT="--etcd-cafile /etc/etcd/ca.pem"
# authenticate to etcd servers
FLANOPT="$FLANOPT --etcd-certfile /etc/hyades/flannel-etcd.pem --etcd-keyfile /etc/hyades/flannel-etcd-key.pem"
# endpoints
FLANOPT="$FLANOPT --etcd-endpoints ${ETCD_ENDPOINTS}"

FLANOPT="$FLANOPT --iface $FLANIP"
FLANOPT="$FLANOPT --ip-masq"
FLANOPT="$FLANOPT --public-ip $FLANIP"

exec /usr/lib/hyades/flanneld $FLANOPT
