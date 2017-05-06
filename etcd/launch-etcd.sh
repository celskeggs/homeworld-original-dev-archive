#!/bin/bash
set -e -u

source /etc/etcd/hyades.conf

if [ "X$ETCDNODE" = "X" ]
then
	echo "Invalid node name"
	exit 1
fi
if [ "X$HOST_IP" = "X" ]
then
        echo "Invalid public address"
        exit 1
fi
if [ "X$INITIAL_CLUSTER" = "X" ]
then
	echo "Invalid initial cluster"
	exit 1
fi
if [ "X$CLUSTER_TOKEN" = "X" ]
then
	echo "Invalid cluster token"
	exit 1
fi
# ETCDNODE="master01"
# HOST_IP=18.181.0.97
# INITIAL_CLUSTER="master01=https://${HOST_IP}:2380"
# CLUSTER_TOKEN="hyades-cluster-2"

TLS_MOUNTPOINT="/etc/etcd/"
TLS_STORAGE="/etc/etcd/"

# necessary files in /etc/etcd-tls/
#   etcd.pem
#   etcd-key.pem
#   ca-client.pem
#   ca.pem

# provide data directory for etcd to store persistent data
HOSTOPT="--volume data-dir,kind=host,source=/var/lib/etcd"
# provide directory for etcd TLS certificates
HOSTOPT="$HOSTOPT --volume etcd-certs,kind=host,readOnly=true,source=${TLS_STORAGE} --mount volume=etcd-certs,target=${TLS_MOUNTPOINT}"
# bind ports to public interface
HOSTOPT="$HOSTOPT --port=client:2379 --port=peer:2380"

# etcd node name
ETCDOPT="--name=$ETCDNODE"
# public advertisement URLs
ETCDOPT="$ETCDOPT --advertise-client-urls=https://${HOST_IP}:2379 --initial-advertise-peer-urls=https://${HOST_IP}:2380"
# listening URLs
ETCDOPT="$ETCDOPT --listen-client-urls=https://0.0.0.0:2379 --listen-peer-urls=https://0.0.0.0:2380"
# initial cluster setup
ETCDOPT="$ETCDOPT --initial-cluster=${INITIAL_CLUSTER} --initial-cluster-token=${CLUSTER_TOKEN} --initial-cluster-state=new"
# client-to-server TLS certs
ETCDOPT="$ETCDOPT --cert-file=${TLS_MOUNTPOINT}/etcd.pem --key-file=${TLS_MOUNTPOINT}/etcd-key.pem --client-cert-auth --trusted-ca-file=${TLS_MOUNTPOINT}/ca-client.pem"
# server-to-server TLS certs
ETCDOPT="$ETCDOPT --peer-cert-file=${TLS_MOUNTPOINT}/etcd.pem --peer-key-file=${TLS_MOUNTPOINT}/etcd-key.pem --peer-client-cert-auth --peer-trusted-ca-file=${TLS_MOUNTPOINT}/ca.pem"

/usr/bin/rkt run $HOSTOPT /usr/lib/etcd/etcd-v3.1.7-linux-amd64.aci -- $ETCDOPT
