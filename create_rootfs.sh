#!/bin/bash

SRC=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

create_rfs() {
    hostname=${1}
    netcfg=${2}
    builder_args=(
        # Create user with no password.
        --run-command "useradd -m -g sudo -p '' -s /bin/bash $USER ; chage -d 0 $USER"

        # Configure network via netplan config in 01-netcfg.yaml
        --hostname ${hostname}

        # Install sshd and authorized key for the user.
        --install "netplan.io,sudo,openssh-server,vim,bash-completion,build-essential,net-tools,docker,docker-compose,python3-pip,python-is-python3"
        --copy-in "${SRC}/${netcfg}:/etc/netplan/"
        --ssh-inject "$USER:file:$HOME/.ssh/id_rsa.pub"
        --firstboot-command "dpkg-reconfigure openssh-server"
        -o rootfs-${hostname}
    )
    rm -rf ${hostname} && mkdir -p ${hostname} && cd ${hostname}
    virt-builder debian-11 "${builder_args[@]}"
    virt-builder --get-kernel ./rootfs-${hostname} -o .
    cd -
}

set -ex
create_rfs vm0 01_net-cfg.yaml
#create_rfs vm1 02_net-cfg.yaml
