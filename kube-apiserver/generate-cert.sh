#!/bin/bash
set -e

if [ "X$1" = "X" -o "X$2" = "X" -o "X$3" = "X" -o "X$4" = "X" -o "X$5" = "X" -o "X$6" = "X" ]
then
	echo "Usage: generate-cert.sh <HOST> <IP> <SERVICE-IP> <CERTDIR> <KUBE-CADIR> <ETCD-CADIR>" 1>&2
	exit 1
fi

set -u

echo "generating apiserver secrets for $1 ip $2 in certdir $3 with cadir $4"

HOST=$1
HOST_IP=$2
SERVICE_IP=$3
CERTDIR=$(realpath -e $4)
KCADIR=$5
ECADIR=$6

KEY_SIZE=2048
DAYS=365

OPENSSL_CONF=${CERTDIR}/kubeapi-${HOST}.cnf
PRIVATE_KEY=${CERTDIR}/kubeapi-${HOST}-key.pem
CERTIFICATE=${CERTDIR}/kubeapi-${HOST}.pem
ETCD_CERTIFICATE=${CERTDIR}/kubeapi-${HOST}-etcd.pem
REQUEST=${CERTDIR}/kubeapi-${HOST}.csr
ETCD_REQUEST=${CERTDIR}/kubeapi-${HOST}-etcd.csr

cat >${OPENSSL_CONF} <<ENDCONFIG
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name
[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = ${HOST}
IP.1 = ${HOST_IP}
IP.2 = ${SERVICE_IP}
ENDCONFIG

# TODO: generate keys on the target system and protect CA better

openssl genrsa -out ${PRIVATE_KEY} ${KEY_SIZE}
openssl req -new -key ${PRIVATE_KEY} -out ${REQUEST} -subj="/CN=kube-apiserver" -config ${OPENSSL_CONF}
openssl req -new -key ${PRIVATE_KEY} -out ${ETCD_REQUEST} -subj="/CN=kube-apiserver-for-etcd" -config ${OPENSSL_CONF}
openssl x509 -req -in ${REQUEST} -CA ${KCADIR}/ca.pem -CAkey ${KCADIR}/ca-key.pem -CAcreateserial -out ${CERTIFICATE} -days ${DAYS} -extensions v3_req -extfile ${OPENSSL_CONF}
openssl x509 -req -in ${ETCD_REQUEST} -CA ${ECADIR}/ca-client.pem -CAkey ${ECADIR}/ca-client-key.pem -CAcreateserial -out ${ETCD_CERTIFICATE} -days ${DAYS} -extensions v3_req -extfile ${OPENSSL_CONF}
