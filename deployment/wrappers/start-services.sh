#!/bin/bash
set -e -u

echo "starting services..."

systemctl daemon-reload

systemctl start etcd
systemctl enable etcd

echo "services started and enabled!"
