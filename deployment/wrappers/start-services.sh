#!/bin/bash
set -e -u

echo "starting services..."

systemctl daemon-reload

systemctl start etcd
systemctl enable etcd
systemctl start flannel
systemctl enable flannel

echo "services started and enabled!"
