# File sources

From CoreOS website via https:

    coreos-application-signing-key.asc

From etcd GitHub releases page (signature verified against above key):

    etcd-v3.1.7-linux-amd64.aci
    etcd-v3.1.7-linux-amd64.aci.asc

From rkt GitHub releases page (signature verified against above key):

    rkt_1.25.0-1_amd64.deb
    rkt_1.25.0-1_amd64.deb.asc

From locally-compiled etcd repo (v3.2.0-rc.0-49-gaf7d0510: af7d0510190f2de70e2ef7d9a2fd5bf7bc89b917)

    etcdctl

From flanneld GitHub release page (flanneld-amd64 v0.7.1):

    flanneld

From kubernetes v1.6.2 linked from GitHub changelog page (kubernetes-server-linux-amd64.tar.gz, 016bc4db69a8f90495e82fbe6e5ec9a12e56ecab58a8eb2e5471bf9cab827ad2):

    kubelet.gz (extracted from .tar.gz and re-gzipped for space reasons)
    kube-apiserver.gz (same)

These aren't as secure of sources as they would optimally be, but it's a start.
