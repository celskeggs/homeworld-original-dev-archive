#!/usr/bin/env bash
set -ex

if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 1>&2
   # and don't try to get around that
   # it doesn't work :(
   # fakeroot, fakechroot, partial sudoing... it all fails
   # make it easy on yourself and just run it as root :(
   exit 1
fi

IMG_NAME="hyades.mit.edu/rkt/builder"
VERSION="1.2.0"
ARCH=amd64
OS=linux

FLAGS=${FLAGS:-""}
ACI_FILE=rkt-builder-"${VERSION}"-"${OS}"-"${ARCH}".aci
BUILDDIR=/opt/build-rkt
SRC_DIR=/opt/rkt
ACI_GOPATH=/go

DEBIAN_SID_DEPS="ca-certificates \
	gcc \
	libc6-dev \
	make \
	automake \
	wget \
	git \
	golang-go \
	cpio \
	squashfs-tools \
	realpath \
	autoconf \
	file \
	xz-utils \
	patch \
	bc \
	locales \
	libacl1-dev \
	libssl-dev \
	libsystemd-dev \
	gnupg \
	ruby \
	ruby-dev \
	rpm \
	python \
	python3 \
	zlib1g-dev \
	pkg-config \
	libglib2.0-dev \
	libpixman-1-dev \
	libcap-dev"

function acbuildend() {
    export EXIT=$?;
    acbuild --debug end && rm -rf rootfs && exit $EXIT;
}

echo "Generating debian sid tree"

mkdir rootfs
debootstrap --force-check-gpg --keyring=./debian-archive-keyring.gpg --variant=minbase --components=main --include="${DEBIAN_SID_DEPS}" sid rootfs http://debian.csail.mit.edu/debian/
rm -rf rootfs/var/cache/apt/archives/*

echo "Version: v${VERSION}"
echo "Building ${ACI_FILE}"

acbuild begin ./rootfs
trap acbuildend EXIT

acbuild $FLAGS set-name $IMG_NAME
acbuild $FLAGS label add version $VERSION
acbuild $FLAGS set-user 0
acbuild $FLAGS set-group 0
echo '{ "set": ["@rkt/default-whitelist", "mlock"] }' | acbuild isolator add "os/linux/seccomp-retain-set" -
acbuild $FLAGS environment add OS_VERSION sid
acbuild $FLAGS environment add GOPATH $ACI_GOPATH
acbuild $FLAGS environment add BUILDDIR $BUILDDIR
acbuild $FLAGS environment add SRC_DIR $SRC_DIR
acbuild $FLAGS mount add build-dir $BUILDDIR
acbuild $FLAGS mount add src-dir $SRC_DIR
acbuild $FLAGS set-working-dir $SRC_DIR
acbuild $FLAGS run /bin/mkdir -- -p /scripts
acbuild $FLAGS copy inner-build.sh /scripts/build.sh
acbuild $FLAGS run /bin/mkdir -- -p $ACI_GOPATH/src/github.com/appc/
acbuild $FLAGS copy-to-dir appc-spec-v0.8.10.tar.gz /
acbuild $FLAGS run --working-dir=$ACI_GOPATH/src/github.com/appc -- tar -xzf /appc-spec-v0.8.10.tar.gz spec-0.8.10
acbuild $FLAGS run -- rm /appc-spec-v0.8.10.tar.gz
acbuild $FLAGS run --working-dir=$ACI_GOPATH/src/github.com/appc -- mv spec-0.8.10 spec
# acbuild $FLAGS run /bin/sh -- -c "GOPATH=${ACI_GOPATH} go get github.com/appc/spec/actool"
acbuild $FLAGS copy gems/ /gems/
acbuild $FLAGS run --working-dir=/gems/ /usr/bin/gem -- install --local ./fpm-1.8.1.gem
acbuild $FLAGS run -- rm -rf /gems/
# acbuild $FLAGS run /usr/bin/gem -- install fpm
acbuild $FLAGS set-exec /bin/bash /scripts/build.sh
acbuild write --overwrite $ACI_FILE
