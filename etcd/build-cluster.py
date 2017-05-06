#!/usr/bin/env python3
assert print, "python 3 required"
import sys
import os

if len(sys.argv) != 5:
	print("Usage: build-cluster.py CLUSTER.CONF BUILDDIR CERTDIR CADIR", file=sys.stderr)
	sys.exit(1)

config, builddir, certdir, cadir = sys.argv[1:]

rootdir = os.path.realpath(os.path.dirname(__file__))
builddir = os.path.realpath(builddir)
certdir = os.path.realpath(certdir)

cluster_name = None
nodes = []
hostnames = {}
ips = {}

with open(config, "r") as f:
	for line in f:
		components = line.strip().split()
		if not components:
			continue
		if components[0] == "cluster":
			if len(components) != 2:
				print("Malformed cluster specification.")
				sys.exit(1)
			assert cluster_name is None
			cluster_name = components[1]
			assert cluster_name.replace("-","").isalnum()
		elif components[0] == "node":
			if len(components) != 4:
				print("Malformed node specification.")
				sys.exit(1)
			node, hostname, ip = components[1:]
			assert node not in nodes and node.isalnum()
			assert hostname.count(".") == 2 and hostname.replace("-","").replace(".","").isalnum()
			assert ip.count(".") == 3 and ip.replace(".","").isnumeric()
			nodes.append(node)
			hostnames[node] = hostname
			ips[node] = ip
		elif components[0].startswith('#'):
			pass # comment
		else:
			print("Unexpected kind of line: %s" % components[0])
			sys.exit(1)

if cluster_name is None:
	print("Cluster name not specified.")
	sys.exit(1)
if not nodes:
	print("No nodes specified.")
	sys.exit(1)

cluster = ",".join("%s=https://%s:2380" % (node, ips[node]) for node in nodes)

os.mkdir(builddir)

# build secret generator
with open(os.path.join(builddir, "generate-secrets.sh"), "w") as f:
	f.write("#!/bin/bash\nset -e -u\n")
	for node in nodes:
		hostname, ip = hostnames[node], ips[node]
		f.write('%s/generate-cert.sh %s %s "%s" "%s"\n' % (rootdir, hostname, ip, certdir, cadir))
	f.write("echo Done generating certificates.\n")

# build etcd configs
for node in nodes:
	with open(os.path.join(builddir, "etcd-%s.conf" % node), "w") as f:
		f.write("ETCDNODE=%s\n" % node)
		f.write("HOST_IP=%s\n" % ips[node])
		f.write('INITIAL_CLUSTER="%s"\n' % cluster)
		f.write("CLUSTER_TOKEN=%s\n" % cluster_name)

# build deployment
with open(os.path.join(builddir, "deploy.sh"), "w") as f:
	f.write("#!/bin/bash\nset -e -u\n")
	for node in nodes:
		hostname = hostnames[node]
		f.write('%s/deploy-etcd.sh %s "%s/etcd-%s.conf" "%s"\n' % (rootdir, hostname, builddir, node, certdir))
	f.write("echo Deployed.\n")

os.chmod(os.path.join(builddir, "generate-secrets.sh"), 0o755)
os.chmod(os.path.join(builddir, "deploy.sh"), 0o755)

print("Done generating cluster files.")
