#!/bin/bash
set -e

if [ "X$1" = "X" -o "X$2" = "X" -o "X$3" = "X" ]
then
	echo "Usage: deploy-kubelet.sh <HOST> <CONFIG> <CERTDIR>" 1>&2
	exit 1
fi

set -u

echo "deploying kubelet to $1 with configuration $2 and certdir $3"

HOST=$1
CONFIG=$(realpath -e $2)
CERTDIR=$(realpath -e $3)

cd $(dirname $0)
UPSTREAM=$(pwd)/../upstream/
TRUST=$(pwd)/../trust/

ssh root@${HOST} "mkdir -p /usr/lib/hyades && rm -f /usr/lib/hyades/kubelet && mkdir -p /etc/hyades/manifests/"
scp ${UPSTREAM}/kubelet.gz launch-kubelet.sh root@${HOST}:/usr/lib/hyades/
ssh root@${HOST} "gunzip /usr/lib/hyades/kubelet.gz && chmod +x /usr/lib/hyades/kubelet"
scp kubelet.service rkt-api.service root@${HOST}:/etc/systemd/system/
scp $CONFIG root@${HOST}:/etc/hyades/kubelet.conf
scp $TRUST/kube-tls-ca.pem root@${HOST}:/etc/hyades/kubeca.pem
scp $CERTDIR/kube-${HOST}.pem root@${HOST}:/etc/hyades/kubelet.pem
scp $CERTDIR/kube-${HOST}-key.pem root@${HOST}:/etc/hyades/kubelet-key.pem
ssh root@${HOST} "chmod 600 /etc/hyades/kubelet-key.pem && systemctl stop kubelet && systemctl daemon-reload && systemctl start kubelet && systemctl enable kubelet"

echo "kubelet should be running"
