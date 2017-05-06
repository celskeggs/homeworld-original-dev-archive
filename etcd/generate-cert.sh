#!/bin/bash
set -e

if [ "X$1" = "X" -o "X$2" = "X" -o "X$3" = "X" -o "X$4" = "X" ]
then
	echo "Usage: generate-secrets.sh <HOST> <IP> <CERTDIR> <CADIR>" 1>&2
	exit 1
fi

set -u

echo "generating secrets for $1 ip $2 in certdir $2 with cadir $4"

HOST=$1
HOST_IP=$2
CERTDIR=$(realpath -e $3)
CADIR=$4

KEY_SIZE=2048
DAYS=365

OPENSSL_CONF=${CERTDIR}/${HOST}.cnf
PRIVATE_KEY=${CERTDIR}/${HOST}-key.pem
CERTIFICATE=${CERTDIR}/${HOST}.pem
REQUEST=${CERTDIR}/${HOST}.csr

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
ENDCONFIG

# TODO: generate keys on the target system and protect CA better

openssl genrsa -out ${PRIVATE_KEY} ${KEY_SIZE}
openssl req -new -key ${PRIVATE_KEY} -out ${REQUEST} -subj="/CN=hyades-etcd-$1" -config ${OPENSSL_CONF}
openssl x509 -req -in ${REQUEST} -CA ${CADIR}/ca.pem -CAkey ${CADIR}/ca-key.pem -CAcreateserial -out ${CERTIFICATE} -days ${DAYS} -extensions v3_req -extfile ${OPENSSL_CONF}