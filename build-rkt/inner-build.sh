#!/bin/bash

set -e

./autogen.sh
 
./configure \
	--disable-tpm --prefix=/usr \
	--with-stage1-flavors=coreos,kvm \
	--with-stage1-default-name=hyades.mit.edu/rkt/stage1-coreos \
	--with-stage1-default-version=1.26.0 \
	--with-coreos-local-pxe-image-path=coreos_production_pxe_image.cpio.gz \
	--with-coreos-local-pxe-image-systemd-version=v231 \
	--with-stage1-default-images-directory=/usr/lib/rkt/stage1-images \
	--with-stage1-default-location=/usr/lib/rkt/stage1-images/stage1-coreos.aci

# make manpages
# make bash-completion
make -j4

