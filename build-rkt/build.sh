#!/bin/bash
set -e -u

cd $(dirname $0)

# NOTE: sudo ./acbuild.sh must run first to build the builder container!

tar -xf v1.26.0.tar.gz rkt-1.26.0/
# cp coreos_production_pxe_image.cpio.gz rkt-1.26.0/
cp coreos_restructured.cpio.gz rkt-1.26.0/coreos_production_pxe_image.cpio.gz
sudo rm -rf build/
mkdir build/
sudo rkt run --volume src-dir,kind=host,source=$(pwd)/rkt-1.26.0/ --volume build-dir,kind=host,source=$(pwd)/build/ --interactive --insecure-options=image ./rkt-builder-1.2.0-linux-amd64.aci
sudo chown --no-dereference --preserve-root -P $(id -u):$(id -g) -R build/

BUILDDIR=build ./build-pkgs.sh 1.26.0

cp build/target/bin/rkt_1.26.0-1_amd64.deb ../binaries/
