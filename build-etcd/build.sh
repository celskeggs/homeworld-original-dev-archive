#!/bin/bash
set -e -u
VERSION=3.1.7

cd $(dirname $0)
HERE=$(pwd)
HYBIN=$(pwd)/../binaries/

tar -xf v${VERSION}.tar.gz etcd-${VERSION}/
cd etcd-${VERSION}
./build
../build-aci ${VERSION}
cp bin/etcdctl ${HYBIN}/
cp bin/etcd-${VERSION}-linux-amd64.aci ${HYBIN}/
gpg --sign

echo "etcd built!"
