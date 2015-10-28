#!/bin/bash

# get guest ip address
# http://stackoverflow.com/a/19140005/1316860

if [ -z "$1" ]; then
    echo "Usage: ./connect-vm.sh <domain>"
    exit 1
fi

INSTANCE_NAME=$1

SSH_DIR=~/.ssh
SSH_KEY=olbius_vm_default_ssh_key

USER_DEFAULT=ubuntu

################ get vm ip and connect ###############
macs=`virsh domiflist ${INSTANCE_NAME} | grep -o -E "([0-9a-f]{2}:){5}([0-9a-f]{2})"`

# get first element
mac="${macs%% *}"
vm_ip=`arp -n -e | grep ${mac} | grep -o -P "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}";`

# connect vm
ssh ${USER_DEFAULT}@${vm_ip} -i ${SSH_DIR}/${SSH_KEY}

