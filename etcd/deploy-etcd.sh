#!/bin/bash
set -e

if [ "X$1" = "X" -o "X$2" = "X" -o "X$3" = "X" ]
then
	echo "Usage: deploy-etcd.sh <HOST> <CONFIG> <CERTDIR>" 1>&2
	exit 1
fi

set -u

echo "deploying etcd to $1 with configuration $2 and certdir $3"

HOST=$1
CONFIG=$(realpath -e $2)
CERTDIR=$(realpath -e $3)

cd $(dirname $0)
UPSTREAM=$(pwd)/../upstream/
TRUST=$(pwd)/../trust/

ssh root@${HOST} systemctl stop etcd
ssh root@${HOST} "mkdir -p /usr/lib/etcd/ && mkdir -p /var/lib/etcd/ && mkdir -p /etc/etcd/"
scp launch-etcd.sh ${UPSTREAM}/etcd-v3.1.7-linux-amd64.aci ${UPSTREAM}/etcd-v3.1.7-linux-amd64.aci.asc root@${HOST}:/usr/lib/etcd/
scp etcd.service root@${HOST}:/etc/systemd/system/etcd.service
scp $CONFIG root@${HOST}:/etc/etcd/hyades.conf
scp $TRUST/etcd-tls-ca.pem root@${HOST}:/etc/etcd/ca.pem
scp $TRUST/etcd-tls-ca-client.pem root@${HOST}:/etc/etcd/ca-client.pem
scp $CERTDIR/${HOST}.pem root@${HOST}:/etc/etcd/etcd.pem
scp $CERTDIR/${HOST}-key.pem root@${HOST}:/etc/etcd/etcd-key.pem
ssh root@${HOST} "chmod 600 /etc/etcd/etcd-key.pem && systemctl stop etcd && systemctl daemon-reload && systemctl start etcd && systemctl enable etcd"

echo "etcd server should be running"
