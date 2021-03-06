#!/bin/bash

# Create new openvpn client key
set -e

BASEDIR=$(readlink -f $(dirname ${0}))
source ${BASEDIR}/config.sh

if [ -z "$1" ]; then
    echo "Usage: create-new-openvpn-client-key.sh <CLIENT_NAME>"
    exit 1
fi

CLIENT_NAME=$1
CLIENT_OVPN=client_${CLIENT_NAME}.ovpn

if [[ $EUID -ne 0 ]]; then
    echo "Please run using sudo or as the root user!"
    exit 1
fi

cd /etc/openvpn/easy-rsa/
source vars

./build-key --batch ${CLIENT_NAME}

mkdir -pv /download-openvpn-key/${CLIENT_NAME}

# Copy openvpn client config
cp /etc/openvpn/easy-rsa/keys/${CLIENT_NAME}.crt /download-openvpn-key/${CLIENT_NAME}/${CLIENT_NAME}.crt
cp /etc/openvpn/easy-rsa/keys/${CLIENT_NAME}.key /download-openvpn-key/${CLIENT_NAME}/${CLIENT_NAME}.key
cp /etc/openvpn/easy-rsa/keys/client.ovpn /download-openvpn-key/${CLIENT_NAME}/${CLIENT_OVPN}
cp /etc/openvpn/ca.crt /download-openvpn-key/${CLIENT_NAME}/ca.crt

cp $BASEDIR/connect_openvpn.sh /download-openvpn-key/${CLIENT_NAME}/connect_openvpn.sh

# Modify some config
cd /download-openvpn-key/${CLIENT_NAME}
sed -i "s/remote my-server-1 1194/remote ${OPENVPN_SERVER_IP} ${OPENVPN_SERVER_PORT}/" ${CLIENT_OVPN}
sed -i "s/cert client.crt/cert ${CLIENT_NAME}.crt/" ${CLIENT_OVPN}
sed -i "s/key client.key/key ${CLIENT_NAME}.key/" ${CLIENT_OVPN}

cd /download-openvpn-key
tar czf ${CLIENT_NAME}.tgz ${CLIENT_NAME}

echo "Copy key: scp -P ${SSH_SERVER_PORT} ${SSH_SERVER_USER}@${SSH_SERVER_IP}:/download-openvpn-key/${CLIENT_NAME}.tgz ."

