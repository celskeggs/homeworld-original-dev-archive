#!/bin/bash
set -e

if [ "X$1" = "X" -o "X$2" = "X" ]
then
	echo "Usage: deploy-initial-config.sh <HOST> <NETWORK>" 1>&2
	exit 1
fi

set -u

HOST=$1

echo "populating etcd config on cluster via $1 for network $2"

scp init-flannel.sh root@${HOST}:/tmp/init-flannel.sh
scp ../upstream/etcdctl root@${HOST}:/tmp/etcdctl
ssh root@${HOST} "/tmp/init-flannel.sh $2"

