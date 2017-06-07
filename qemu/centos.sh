# !/usr/bin/env bash

PWD=$(pwd)
TOOLBOX=/media/disk/toolbox/
QEMU="${TOOLBOX}/bin/qemu-system-x86_64 --enable-kvm"

NAME="-name CentOS"
#BOOT="-boot order=c,menu=on"

CPU="-cpu SandyBridge -smp 4"
MEM="-m 4096"
PLATFORM="-machine q35"
VGA="-vga cirrus -vnc 0.0.0.0:2"
MISC="-nodefaults -no-user-config"

MONITOR_ID="mon0"
MONITOR="-chardev socket,id=${MONITOR_ID},host=localhost,port=4444,server,nowait -mon chardev=${MONITOR_ID},mode=readline"

PIVNET_ID="net0"
PIVNET="-netdev type=user,id=${PIVNET_ID},hostfwd=tcp::5022-:22 -device e1000,mac=52:54:00:12:34:56,netdev=${PIVNET_ID}"
PUBNET_ID="net1"
PUBNET="-netdev type=tap,id=${PUBNET_ID},script=${PWD}/qemu-ifup-nat,downscript=${PWD}/qemu-ifdown-nat -device virtio-net,mac=52:54:00:12:34:57,netdev=${PUBNET_ID}"

SYSIMG=${PWD}/centos7u2.qcow2
DATAIMG=${PWD}/centos7u2.qcow2

# Virtio block device configuration
VIRT_CTL="-device virtio-scsi-pci,id=scsi"
VIRT_DRV_ID="virtio_drv"
VIRT_IMG=${SYSIMG}
VIRT_DRIVE="-drive file=${VIRT_IMG},if=none,id=${VIRT_DRV_ID}"
VIRT_DEVICE="-device scsi-disk,drive=${VIRT_DRV_ID},bus=scsi.0,bootindex=1"
VIRT_HD="${VIRT_CTL} ${VIRT_DRIVE} ${VIRT_DEVICE}"

# AHCI block device configuration
AHCI_CTL="-device ahci,id=ahci"
AHCI_DRV_ID="ahci_drv"
AHCI_IMG=${DATAIMG}
AHCI_DRIVE="-drive file=${AHCI_IMG},if=none,id=${AHCI_DRV_ID}"
AHCI_DEVICE="-device ide-drive,drive=${AHCI_DRV_ID},bus=ahci.0,bootindex=2"
AHCI_HD="${AHCI_CTL} ${AHCI_DRIVE} ${AHCI_DEVICE}"

# NVME SSD(s) passthrough with vfio-pci configuration
VFIO_HD="-device vfio-pci,host=0000:04:00.0 -device vfio-pci,host=0000:08:00.0"

${QEMU} ${NAME} ${BOOT} ${CPU} ${MEM} ${PLATFORM} ${VGA} ${MISC} ${MONITOR} ${PIVNET} ${PUBNET} ${VFIO_HD} ${VIRT_HD} ${AHCI_HD}
