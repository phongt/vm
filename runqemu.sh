#!/bin/bash

SRC=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

run_qemu() {
    id=${1}
    mac_addr=52:54:00:12:34:$(expr ${RANDOM} % 100)
    qemu-system-x86_64 -enable-kvm -smp 4 -m 1G \
        -kernel ${SRC}/vm${id}/vmlinuz-5.10.0-9-amd64 \
        -initrd ${SRC}/vm${id}/initrd.img-5.10.0-9-amd64 \
        -drive file=${SRC}/vm${id}/rootfs-vm${id},if=virtio,format=raw \
        -netdev user,id=n1 -device virtio-net-pci,netdev=n1 \
        -device virtio-net,netdev=vm${id},mac="$(printf "%02x:%02x:%02x:%02x:%02x:%02x" 0x${mac_addr//:/ 0x})" \
        -netdev tap,id=vm${id},ifname=tap${id},script=no,downscript=no \
        -append "root=/dev/vda1 console=ttyS0" -nographic
}

set -ex
run_qemu ${1}
