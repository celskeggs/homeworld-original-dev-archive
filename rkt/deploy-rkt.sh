#!/bin/bash
set -e

if [ "X$1" = "X" ]
then
	echo "Usage: deploy-rkt.sh <HOST>" 1>&2
	exit 1
fi

set -u

echo "deploying rkt to $1"

HOST=$1

cd $(dirname $0)
UPSTREAM=$(pwd)/../upstream/

scp ${UPSTREAM}/rkt_1.25.0-1_amd64.deb ${UPSTREAM}/coreos-application-signing-key.asc root@${HOST}:/root/
ssh root@${HOST} "dpkg -i /root/rkt_1.25.0-1_amd64.deb && rkt trust --skip-fingerprint-review --prefix=coreos.com /root/coreos-application-signing-key.asc"

echo "rkt should be ready to use"
