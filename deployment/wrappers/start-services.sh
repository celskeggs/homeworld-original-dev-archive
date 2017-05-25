#!/bin/bash
set -e -u

echo "starting services..."

systemctl daemon-reload

systemctl start etcd
systemctl enable etcd
systemctl start flannel
systemctl enable flannel
systemctl start rkt-api
systemctl enable rkt-api
systemctl start kubelet
systemctl enable kubelet
systemctl start kube-proxy
systemctl enable kube-proxy
systemctl start apiserver
systemctl enable apiserver

echo "services started and enabled!"
