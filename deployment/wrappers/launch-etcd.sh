#!/bin/bash
set -e -u

source /etc/hyades/cluster.conf
source /etc/hyades/local.conf

TLS_MOUNTPOINT=/etc/hyades/certs/etcd/
TLS_STORAGE=/etc/hyades/certs/etcd/
PERSISTENT_DATA=/var/lib/etcd
ETCD_IMAGE=/usr/lib/hyades/images/etcd-3.1.7-linux-amd64.aci

mkdir -p ${PERSISTENT_DATA}

# our image is stored on disk -- better hope that's safe!
HOSTOPT="--insecure-options=image"
# provide data directory for etcd to store persistent data
HOSTOPT="$HOSTOPT --volume data-dir,kind=host,source=${PERSISTENT_DATA}"
# provide directory for etcd TLS certificates
HOSTOPT="$HOSTOPT --volume etcd-certs,kind=host,readOnly=true,source=${TLS_STORAGE} --mount volume=etcd-certs,target=${TLS_MOUNTPOINT}"
# bind ports to public interface
HOSTOPT="$HOSTOPT --port=client:2379 --port=peer:2380"

# etcd node name
ETCDOPT="--name=${HOST_NODE}"
# public advertisement URLs
ETCDOPT="$ETCDOPT --advertise-client-urls=https://${HOST_IP}:2379 --initial-advertise-peer-urls=https://${HOST_IP}:2380"
# listening URLs
ETCDOPT="$ETCDOPT --listen-client-urls=https://0.0.0.0:2379 --listen-peer-urls=https://0.0.0.0:2380"
# initial cluster setup
ETCDOPT="$ETCDOPT --initial-cluster=${ETCD_CLUSTER} --initial-cluster-token=${ETCD_TOKEN} --initial-cluster-state=new"
# client-to-server TLS certs
ETCDOPT="$ETCDOPT --cert-file=${TLS_MOUNTPOINT}/etcd-self.pem --key-file=${TLS_MOUNTPOINT}/etcd-self-key.pem --client-cert-auth --trusted-ca-file=${TLS_MOUNTPOINT}/etcd-ca-client.pem"
# server-to-server TLS certs
ETCDOPT="$ETCDOPT --peer-cert-file=${TLS_MOUNTPOINT}/etcd-self.pem --peer-key-file=${TLS_MOUNTPOINT}/etcd-self-key.pem --peer-client-cert-auth --peer-trusted-ca-file=${TLS_MOUNTPOINT}/etcd-ca.pem"

exec rkt run $HOSTOPT ${ETCD_IMAGE} -- $ETCDOPT
