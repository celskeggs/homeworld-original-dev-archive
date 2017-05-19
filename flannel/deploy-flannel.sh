#!/bin/bash
set -e

if [ "X$1" = "X" -o "X$2" = "X" -o "X$3" = "X" ]
then
	echo "Usage: deploy-flannel.sh <HOST> <CONFIG> <CERTDIR>" 1>&2
	exit 1
fi

set -u

echo "deploying flannel to $1 with configuration $2 and certdir $3"

HOST=$1
CONFIG=$(realpath -e $2)
CERTDIR=$(realpath -e $3)

cd $(dirname $0)
UPSTREAM=$(pwd)/../upstream/

ssh root@${HOST} systemctl stop flannel || true
scp ${UPSTREAM}/flanneld root@${HOST}:/usr/lib/hyades/flanneld
scp launch-flannel.sh root@${HOST}:/usr/lib/hyades/launch-flannel.sh
scp flannel.service root@${HOST}:/etc/systemd/system/
scp ${CERTDIR}/flannel-${HOST}.pem root@${HOST}:/etc/hyades/flannel-etcd.pem
scp ${CERTDIR}/flannel-${HOST}-key.pem root@${HOST}:/etc/hyades/flannel-etcd-key.pem
scp flannel.conf root@${HOST}:/etc/hyades/flannel.conf
ssh root@${HOST} "chmod 600 /etc/hyades/flannel-etcd-key.pem && mkdir -p /etc/rkt/net.d/"
scp 10-containernet.conf root@${HOST}:/etc/rkt/net.d/10-containernet.conf
ssh root@${HOST} "systemctl stop flannel && systemctl daemon-reload && systemctl start flannel && systemctl enable flannel"

echo "flannel should be ready to run"
