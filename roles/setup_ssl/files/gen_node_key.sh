#!/bin/bash

while getopts :m:n: opt
do
        case "$opt" in
       # m) MASTER_IPS=(${OPTARG//,/ }) ;;
        n) NODE_IPS=(${OPTARG//,/ }) ;;
        esac
done


cat > apiserver.conf << EOF
[ req ]
default_bits = 2048
prompt = no
default_md = sha256
req_extensions = req_ext
distinguished_name = dn

[ dn ]
CN = kube-apiserver

[ req_ext ]
subjectAltName = @alt_names

[ alt_names ]
DNS.1 = kubernetes
DNS.2 = kubernetes.default
DNS.3 = kubernetes.default.svc
DNS.4 = kubernetes.default.svc.cluster
DNS.5 = kubernetes.default.svc.cluster.local
$CONF_IPS

[ v3_ext ]
authorityKeyIdentifier=keyid,issuer:always
basicConstraints=CA:FALSE
keyUsage=keyEncipherment,dataEncipherment
extendedKeyUsage=serverAuth,clientAuth
subjectAltName=@alt_names
EOF
for i in ${NODE_IPS[@]}
do
	FILE_NAME=${i}.conf
	cp apiserver.conf ${FILE_NAME}
	sed -i "/CN = kube-apiserver/s/kube-apiserver/$i/" ${FILE_NAME}
	openssl genrsa -out ${i}-key.pem 2048
	openssl req -new -key ${i}-key.pem -out ${i}.csr -config ${FILE_NAME}
	openssl x509 -req -in ${i}.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out ${i}.pem -days 10000 -extensions v3_ext -extfile ${FILE_NAME}
done
