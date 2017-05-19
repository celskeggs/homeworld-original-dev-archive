#!/bin/bash
set -e

if [ "X$1" = "X" -o "X$2" = "X" -o "X$3" = "X" ]
then
	echo "Usage: deploy-apiserver.sh <HOST> <CONFIG> <CERTDIR>" 1>&2
	exit 1
fi

set -u

echo "deploying apiserver to $1 with configuration $2 and certdir $3"

HOST=$1
CONFIG=$(realpath -e $2)
CERTDIR=$(realpath -e $3)

cd $(dirname $0)
UPSTREAM=$(pwd)/../upstream/
TRUST=$(pwd)/../trust/

ssh root@${HOST} systemctl stop apiserver
scp ${UPSTREAM}/kube-apiserver.gz root@${HOST}:/usr/lib/hyades/kube-apiserver.gz
ssh root@${HOST} "rm -f /usr/lib/hyades/kube-apiserver && gunzip /usr/lib/hyades/kube-apiserver.gz && chmod +x /usr/lib/hyades/kube-apiserver"
scp launch-apiserver.sh root@${HOST}:/usr/lib/hyades/launch-apiserver.sh
scp apiserver.service root@${HOST}:/etc/systemd/system/
scp ${CERTDIR}/kubeapi-${HOST}.pem root@${HOST}:/etc/hyades/kubeapi.pem
scp ${CERTDIR}/kubeapi-${HOST}-etcd.pem root@${HOST}:/etc/hyades/kubeapi-etcd.pem
scp ${CERTDIR}/kubeapi-${HOST}-key.pem root@${HOST}:/etc/hyades/kubeapi-key.pem
scp kubeapi.conf root@${HOST}:/etc/hyades/kubeapi.conf
ssh root@${HOST} "chmod 600 /etc/hyades/kubeapi-key.pem && systemctl stop apiserver && systemctl daemon-reload && systemctl start apiserver && systemctl enable apiserver"

echo "kube-apiserver should be ready to run"
