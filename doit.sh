#!/bin/bash

# Automates much of the process of generating 
# the Certificate Authority, Client and Server Keypairs

set -x

NAME=prototype

cfssl gencert -initca ca-csr.json | cfssljson -bare ca

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem \
  -config=ca-config.json \
  -profile=server \
   server-csr.json | cfssljson -bare ${NAME}-server

cfssl gencert \
  -ca=ca.pem \
  -ca-key=ca-key.pem  \
  -config=ca-config.json \
  -profile=client \
   client-csr.json | cfssljson -bare ${NAME}-client

openssl pkcs12 -export -out ${NAME}-client.p12 \
  -inkey ${NAME}-client-key.pem -in ${NAME}-client.pem \
  -certfile ca.pem

openssl pkcs12 -export -out ${NAME}-server.p12 \
  -inkey ${NAME}-server-key.pem -in ${NAME}-server.pem \
  -certfile ca.pem

keytool -importkeystore -srckeystore ${NAME}-client.p12 \
  -storetype pkcs12 -destkeystore ${NAME}-client.jks \
  -deststoretype jks

keytool -importkeystore -srckeystore ${NAME}-server.p12 \
  -storetype pkcs12 -destkeystore ${NAME}-server.jks \
  -deststoretype jks

keytool -import -file ca.pem -alias "${NAME}CA" \
  -keystore truststore.jks
