#!/bin/bash
set -e

if [ "X$1" = "X" ]
then
	echo "Usage: deploy-proxy.sh <HOST>" 1>&2
	exit 1
fi

set -u

echo "deploying kube-proxy to $1 with existing kubelet config"

HOST=$1

cd $(dirname $0)
UPSTREAM=$(pwd)/../upstream/

ssh root@${HOST} systemctl stop kube-proxy || true
scp ${UPSTREAM}/kube-proxy root@${HOST}:/usr/lib/hyades/kube-proxy
scp launch-proxy.sh root@${HOST}:/usr/lib/hyades/launch-proxy.sh
scp kube-proxy.service root@${HOST}:/etc/systemd/system/
# uses kubelet certs and configuration
ssh root@${HOST} "systemctl stop kube-proxy && systemctl daemon-reload && systemctl start kube-proxy && systemctl enable kube-proxy"

echo "kube-proxy should be ready to run"
