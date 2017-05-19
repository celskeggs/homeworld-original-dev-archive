#!/bin/bash
set -e

if [ "X$1" = "X" -o "X$2" = "X" ]
then
	echo "Usage: deploy-ctrlmgr.sh <HOST> <CONFIG>" 1>&2
	exit 1
fi

set -u

echo "deploying kube-controller-manager to $1 with existing kubelet config and specific config $2"

HOST=$1
CONFIG=$2

cd $(dirname $0)
UPSTREAM=$(pwd)/../upstream/

ssh root@${HOST} systemctl stop kube-ctrlmgr || true
scp ${UPSTREAM}/kube-controller-manager.gz root@${HOST}:/usr/lib/hyades/kube-controller-manager.gz
ssh root@${HOST} "rm -f /usr/lib/hyades/kube-controller-manager && gunzip /usr/lib/hyades/kube-controller-manager.gz && chmod +x /usr/lib/hyades/kube-controller-manager"
scp launch-ctrlmgr.sh root@${HOST}:/usr/lib/hyades/launch-ctrlmgr.sh
scp kube-ctrlmgr.service root@${HOST}:/etc/systemd/system/
scp $CONFIG root@${HOST}:/etc/hyades/ctrlmgr.conf
# uses kubelet certs and configuration
ssh root@${HOST} "systemctl stop kube-ctrlmgr && systemctl daemon-reload && systemctl start kube-ctrlmgr && systemctl enable kube-ctrlmgr"

echo "kube-ctrlmgr should be ready to run"
