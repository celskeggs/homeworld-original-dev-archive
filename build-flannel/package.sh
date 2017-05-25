#!/bin/bash
set -e -u

# basic structure
FPMOPT="-s dir -t deb"
# name and version
FPMOPT="$FPMOPT -n flannel -v 0.7.1 --iteration 2"
# packager
FPMOPT="$FPMOPT --maintainer 'sipb-hyades-root@mit.edu'"
# metadata
FPMOPT="$FPMOPT --license APLv2 -a x86_64 --url https://github.com/coreos/flannel/"
# get binary
FPMOPT="$FPMOPT go/src/github.com/coreos/flannel/dist/flanneld=/usr/bin/flanneld 10-containernet.conf=/etc/rkt/net.d/10-containernet.conf"

fpm --vendor 'MIT SIPB Hyades Project' $FPMOPT
cp flannel_0.7.1-2_amd64.deb ../binaries
