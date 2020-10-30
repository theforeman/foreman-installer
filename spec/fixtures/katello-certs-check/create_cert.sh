#!/bin/bash

echo "Generate CA"
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out cacert.crt -subj "/CN=Test Self-Signed CA"

echo "Generate server certificate"
openssl genrsa -out foreman.example.com.key 2048
openssl req -new -key foreman.example.com.key -out foreman.example.com.csr -subj "/CN=foreman.example.com"
openssl x509 -req -in foreman.example.com.csr -CA cacert.crt -CAkey ca.key -CAcreateserial -out foreman.example.com.crt -days 3650 -sha256 -extfile extensions.txt -extensions extensions
