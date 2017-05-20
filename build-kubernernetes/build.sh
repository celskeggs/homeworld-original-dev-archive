#!/bin/bash
set -e -u
cd $(dirname $0)
ROOT=$(pwd)
rm -rf go/
mkdir -p go/src/k8s.io/kubernetes
cd go/src/k8s.io/kubernetes
echo "extracting..."
tar -xf ${ROOT}/kubernetes-src-v1.6.4.tar.xz
echo "extracted!"
export GOPATH=${ROOT}/go
make
for binary in hyperkube kubectl kubelet
do
	cp _output/local/bin/linux/amd64/$binary ${ROOT}/../binaries/
done
cd ${ROOT}
./package.sh
echo "built kubernetes binaries!"
