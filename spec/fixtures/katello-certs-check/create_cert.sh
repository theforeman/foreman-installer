#!/bin/bash

CERTS_DIR=certs

THIRDPARTY_CA_CERT_NAME=ca-thirdparty
if [[ ! -f "$CERTS_DIR/$THIRDPARTY_CA_CERT_NAME.key" || ! -f "$CERTS_DIR/$THIRDPARTY_CA_CERT_NAME.crt" ]]; then
  echo "Generate CA"
  openssl genrsa -out $CERTS_DIR/$THIRDPARTY_CA_CERT_NAME.key 2048
  openssl req -x509 -new -nodes -key $CERTS_DIR/$THIRDPARTY_CA_CERT_NAME.key -sha256 -days 3650 -out $CERTS_DIR/$THIRDPARTY_CA_CERT_NAME.crt -subj "/CN=Thirdparty CA"
else
  echo "Thirdparty CA certificate exists. Skipping."
fi

CA_CERT_NAME=ca
if [[ ! -f "$CERTS_DIR/$CA_CERT_NAME.key" || ! -f "$CERTS_DIR/$CA_CERT_NAME.crt" ]]; then
  echo "Generate CA"
  openssl genrsa -out $CERTS_DIR/$CA_CERT_NAME.key 2048
  openssl req -x509 -new -nodes -key $CERTS_DIR/$CA_CERT_NAME.key -sha256 -days 3650 -out $CERTS_DIR/$CA_CERT_NAME.crt -subj "/CN=Test Self-Signed CA"
else
  echo "CA certificate exists. Skipping."
fi

CA_BUNDLE=ca-bundle
if [[ ! -f "$CERTS_DIR/$CA_BUNDLE.crt" ]]; then
  echo "Generate CA bundle"
  cat $CERTS_DIR/$THIRDPARTY_CA_CERT_NAME.crt $CERTS_DIR/$CA_CERT_NAME.crt > $CERTS_DIR/$CA_BUNDLE.crt
else
  echo "CA certificate bundle exists. Skipping."
fi

CA_BUNDLE=ca-bundle-with-trust-rules
CA_CERT_WITH_TRUST_RULES=ca-with-trust-rules
if [[ ! -f "$CERTS_DIR/$CA_BUNDLE.crt" ]]; then
  echo "Generate CA bundle with trust rules"
  openssl x509 -in $CERTS_DIR/$CA_CERT_NAME.crt -addtrust serverAuth -out $CERTS_DIR/$CA_CERT_WITH_TRUST_RULES.crt
  cat $CERTS_DIR/$THIRDPARTY_CA_CERT_NAME.crt $CERTS_DIR/$CA_CERT_WITH_TRUST_RULES.crt > $CERTS_DIR/$CA_BUNDLE.crt
else
  echo "CA certificate bundle with trust rules exists. Skipping."
fi

CA_SHA1_CERT_NAME=ca-sha1
CA_SHA1_CERT_BUNDLE=ca-sha1-bundle
if [[ ! -f "$CERTS_DIR/$CA_SHA1_CERT_NAME.key" || ! -f "$CERTS_DIR/$CA_SHA1_CERT_NAME.crt" || ! -f "$CERTS_DIR/$CA_SHA1_CERT_BUNDLE.crt" ]]; then
  echo "Generate CA with sha1 signing algorithm"
  openssl genrsa -out $CERTS_DIR/$CA_SHA1_CERT_NAME.key 2048
  openssl req -new -key $CERTS_DIR/$CA_SHA1_CERT_NAME.key -sha1 -out $CERTS_DIR/$CA_SHA1_CERT_NAME.csr -subj "/CN=Test Self-Signed CA"
  openssl x509 -req -in $CERTS_DIR/$CA_SHA1_CERT_NAME.csr -CA $CERTS_DIR/$CA_CERT_NAME.crt -CAkey $CERTS_DIR/$CA_CERT_NAME.key -CAcreateserial -out $CERTS_DIR/$CA_SHA1_CERT_NAME.crt -days 3650 -sha1

  cat $CERTS_DIR/$CA_CERT_NAME.crt $CERTS_DIR/$CA_SHA1_CERT_NAME.crt > $CERTS_DIR/$CA_SHA1_CERT_BUNDLE.crt
else
  echo "CA certificate exists. Skipping."
fi

CERT_NAME=foreman-sha1.example.com
if [[ ! -f "$CERTS_DIR/$CERT_NAME.key" || ! -f "$CERTS_DIR/$CERT_NAME.crt" ]]; then
  echo "Generate server certificate"
  openssl genrsa -out $CERTS_DIR/$CERT_NAME.key 2048
  openssl req -new -key $CERTS_DIR/$CERT_NAME.key -out $CERTS_DIR/$CERT_NAME.csr -subj "/CN=foreman.example.com"
  openssl x509 -req -in $CERTS_DIR/$CERT_NAME.csr -CA $CERTS_DIR/$CA_SHA1_CERT_NAME.crt -CAkey $CERTS_DIR/$CA_SHA1_CERT_NAME.key -CAcreateserial -out $CERTS_DIR/$CERT_NAME.crt -days 3650 -sha256 -extfile extensions.txt -extensions extensions
else
  echo "Server certificate with sha1 CA exists. Skipping."
fi

CERT_NAME=foreman-bad-san.example.com
if [[ ! -f "$CERTS_DIR/$CERT_NAME.key" || ! -f "$CERTS_DIR/$CERT_NAME.crt" ]]; then
  echo "Generate server certificate"
  openssl genrsa -out $CERTS_DIR/$CERT_NAME.key 2048
  openssl req -new -key $CERTS_DIR/$CERT_NAME.key -out $CERTS_DIR/$CERT_NAME.csr -subj "/CN=${CERT_NAME}"
  openssl x509 -req -in $CERTS_DIR/$CERT_NAME.csr -CA $CERTS_DIR/$CA_CERT_NAME.crt -CAkey $CERTS_DIR/$CA_CERT_NAME.key -CAcreateserial -out $CERTS_DIR/$CERT_NAME.crt -days 3650 -sha256 -extfile extensions.txt -extensions extensions
else
  echo "Server certificate with bad SAN exists. Skipping."
fi

CERT_NAME=foreman.example.com
if [[ ! -f "$CERTS_DIR/$CERT_NAME.key" || ! -f "$CERTS_DIR/$CERT_NAME.crt" ]]; then
  echo "Generate server certificate"
  openssl genrsa -out $CERTS_DIR/$CERT_NAME.key 2048
  openssl req -new -key $CERTS_DIR/$CERT_NAME.key -out $CERTS_DIR/$CERT_NAME.csr -subj "/CN=foreman.example.com"
  openssl x509 -req -in $CERTS_DIR/$CERT_NAME.csr -CA $CERTS_DIR/$CA_CERT_NAME.crt -CAkey $CERTS_DIR/$CA_CERT_NAME.key -CAcreateserial -out $CERTS_DIR/$CERT_NAME.crt -days 3650 -sha256 -extfile extensions.txt -extensions extensions
else
  echo "Server certificate exists. Skipping."
fi

CERT_NAME=foreman-ec384.example.com
if [[ ! -f "$CERTS_DIR/$CERT_NAME.key" || ! -f "$CERTS_DIR/$CERT_NAME.crt" ]]; then
  echo "Generate server certificate"
  openssl ecparam -genkey -name secp384r1 -out $CERTS_DIR/$CERT_NAME.key
  openssl req -new -key $CERTS_DIR/$CERT_NAME.key -out $CERTS_DIR/$CERT_NAME.csr -subj "/CN=${CERT_NAME}"
  openssl x509 -req -in $CERTS_DIR/$CERT_NAME.csr -CA $CERTS_DIR/$CA_CERT_NAME.crt -CAkey $CERTS_DIR/$CA_CERT_NAME.key -CAcreateserial -out $CERTS_DIR/$CERT_NAME.crt -days 3650 -sha256 -extfile extensions.txt -extensions extensions
else
  echo "ECC Server certificate exists. Skipping."
fi

CERT_NAME=invalid
if [[ ! -f "$CERTS_DIR/$CERT_NAME.key" || ! -f "$CERTS_DIR/$CERT_NAME.crt" ]]; then
  echo "Generate invalid server certificate"
  openssl genrsa -out $CERTS_DIR/$CERT_NAME.key 2048
  openssl req -new -key $CERTS_DIR/$CERT_NAME.key -out $CERTS_DIR/$CERT_NAME.csr -subj "/CN=foreman.example.com"
  openssl x509 -req -in $CERTS_DIR/$CERT_NAME.csr -CA $CERTS_DIR/$CA_CERT_NAME.crt -CAkey $CERTS_DIR/$CA_CERT_NAME.key -CAcreateserial -out $CERTS_DIR/$CERT_NAME.crt -days 3650 -sha256 -extfile extensions.txt -extensions client_extensions
else
  echo "Invalid server certificate exists. Skipping."
fi

CERT_NAME=wildcard
if [[ ! -f "$CERTS_DIR/$CERT_NAME.key" || ! -f "$CERTS_DIR/$CERT_NAME.crt" ]]; then
  echo "Generate server certificate"
  openssl genrsa -out $CERTS_DIR/$CERT_NAME.key 2048
  openssl req -new -key $CERTS_DIR/$CERT_NAME.key -out $CERTS_DIR/$CERT_NAME.csr -subj "/CN=*.example.com"
  openssl x509 -req -in $CERTS_DIR/$CERT_NAME.csr -CA $CERTS_DIR/$CA_CERT_NAME.crt -CAkey $CERTS_DIR/$CA_CERT_NAME.key -CAcreateserial -out $CERTS_DIR/$CERT_NAME.crt -days 3650 -sha256 -extfile extensions.txt -extensions wildcard_extensions
else
  echo "Wildcard server certificate exists. Skipping."
fi

CERT_NAME=shortname
if [[ ! -f "$CERTS_DIR/$CERT_NAME.key" || ! -f "$CERTS_DIR/$CERT_NAME.crt" ]]; then
  echo "Generate shortname server certificate"
  openssl genrsa -out $CERTS_DIR/$CERT_NAME.key 2048
  openssl req -new -key $CERTS_DIR/$CERT_NAME.key -out $CERTS_DIR/$CERT_NAME.csr -subj "/CN=foreman"
  openssl x509 -req -in $CERTS_DIR/$CERT_NAME.csr -CA $CERTS_DIR/$CA_CERT_NAME.crt -CAkey $CERTS_DIR/$CA_CERT_NAME.key -CAcreateserial -out $CERTS_DIR/$CERT_NAME.crt -days 3650 -sha256 -extfile extensions.txt -extensions shortname_extensions
else
  echo "Shortname server certificate exists. Skipping."
fi
