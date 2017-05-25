#!/bin/bash
set -e -u

echo "starting master services..."

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
systemctl start kube-ctrlmgr
systemctl enable kube-ctrlmgr
systemctl start kube-scheduler
systemctl enable kube-scheduler

echo "services started and enabled!"
