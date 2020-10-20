#!/bin/bash

# Generate CA
openssl genrsa -out ca.key 2048
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 -out cacert.crt

# Generate server certificate
openssl genrsa -out foreman.example.com.key 2048
openssl req -new -key foreman.example.com.key -out foreman.example.com.csr
openssl x509 -req -in foreman.example.com.csr -CA cacert.crt -CAkey ca.key -CAcreateserial -out foreman.example.com.crt -days 3650 -sha256 -extfile extensions.txt -extensions extensions
