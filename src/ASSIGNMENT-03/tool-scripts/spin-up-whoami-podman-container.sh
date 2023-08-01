#! /usr/bin/env bash
set -e

HOST=$(hostname)
CERT_PREFIX="certs/whoami-$HOST"
CERT_KEY="${CERT_PREFIX}.key"
CERT_CRT="${CERT_PREFIX}.crt"

mkdir -p certs

if [[ ! -r "$CERT_CRT" || ! -r "$CERT_KEY" ]]; then

    openssl genrsa -des3 -out "$CERT_KEY" \
        -passout "pass:keypassphrase" \
        4096

    openssl req -x509 \
        -key "$CERT_KEY" -passin  "pass:keypassphrase" \
        -sha256 -days 365 -subj "/C=$HOSTWhoAmI/ST=NC/L=Morrisville/O=acme/OU=devops/CN=whoami.devops" \
        -out "$CERT_CRT" \
        -passout "pass:pempassphrase"

    chmod 664 "$CERT_CRT"
fi

#podman pull 'ghcr.io/traefik/whoami:v1.10.1'
podman pull 'ghcr.io/traefik/whoami:latest'
docker run --detach  --restart unless-stopped \
    --name whoami-08443 \
    -p 8443:443 \
    -v "$PWD/certs:/certs" \
    traefik/whoami -cert "/$CERT_CRT" -key "/$CERT_KEY"

