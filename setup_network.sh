#!/bin/bash

tap_setup() {
    sudo ovs-vsctl del-port br0 ${1}
    sudo ip link delete ${1} 
    sudo ip tuntap add mode tap user $USER ${1}
    sudo ovs-vsctl add-port br0 ${1}
    sudo ip link set ${1} up
}

set -x
sudo ovs-vsctl br-exists br0
if [ "$?" -ne "0" ]; then
    sudo ovs-vsctl add-br br0
fi
sudo ip address add 192.168.10.1/24 dev br0 
sudo ip link set br0 up
tap_setup tap0
tap_setup tap1
