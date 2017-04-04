#!/bin/bash

PWD=$(pwd)
TOOLBOX=/media/sdb7/toolbox/
SIM="${TOOLBOX}/bin/qemu-system-x86_64 --enable-kvm"
SIM_NAME="-name CentOS"
SIM_BOOT="-boot order=c,menu=on"

# qemu simulator hardware list
SIM_CPU="-cpu SandyBridge -smp 2"
SIM_MEM="-m 4096"
SIM_PLATFORM="-machine q35"
SIM_VGA="-vga std"
SIM_VNC="-vnc 0.0.0.0:2"
SIM_MISC="-nodefaults -no-user-config"
SIM_CHAR="-chardev socket,id=mon0,host=localhost,port=4444,server,nowait -mon chardev=mon0,mode=readline"

#disk image files
SIM_SYSIMG=${PWD}/centos7-scsi.qcow2
SIM_DATAIMG=${PWD}/data.qcow2

#ahci device configuration
SIM_AHCI_BUSID="ahci"
SIM_AHCICTL="-device ahci,id=${SIM_AHCI_BUSID}"
SIM_AHCI_DRVID="ahci_sysdrv"
SIM_AHCIDRV="-drive file=${SIM_DATAIMG},if=none,index=1,id=${SIM_AHCI_DRVID}"
SIM_AHCI_IF="-device ide-drive,drive=${SIM_AHCI_DRVID},bus=${SIM_AHCI_BUSID}.0"
SIM_AHCI_HD="${SIM_AHCICTL} ${SIM_AHCIDRV} ${SIM_AHCI_IF}"

#sas device configuration
SIM_SAS_BUSID="scsi"
SIM_SASCTL="-device megasas-gen2,id=${SIM_SAS_BUSID}"
SIM_SAS_DRVID="sas_datadrv"
SIM_SASDRV="-drive file=${SIM_SYSIMG},if=scsi,index=1,id=${SIM_SAS_DRVID}"
SIM_SAS_IF="-device scsi-disk,drive=${SIM_SAS_DRVID},bus=${SIM_SAS_BUSID}.0"
SIM_SAS_HD="${SIM_SASCTL} ${SIM_SASDRV} ${SIM_SAS_IF}"

#virtio scsi device configuration
SIM_VIO_BUSID="scsi"
SIM_VIOCTL="-device virtio-scsi-pci,id=${SIM_VIO_BUSID}"
SIM_VIO_DRVID="vio_drv"
SIM_VIODRV="-drive file=${SIM_SYSIMG},if=none,id=${SIM_VIO_DRVID}"
SIM_VIO_IF="-device scsi-disk,drive=${SIM_VIO_DRVID},bus=${SIM_VIO_BUSID}.0"
SIM_VIO_HD="${SIM_VIOCTL} ${SIM_VIODRV} ${SIM_VIO_IF}"

#usb device configuration
SIM_EHCICTL="-device ich9-usb-ehci1 -device usb-tablet,id=input0"

SIM_PIVNET="-net nic,model=e1000 -net user,hostfwd=tcp::5022-:22"
SIM_PUBNET="-net nic,model=virtio -net tap,script=${PWD}/qemu-ifup-nat,downscript=${PWD}/qemu-ifdown-nat"

# ${SIM_SAS_HD} ${SIM_AHCI_HD} \

# qemu/kvm guest instance
${SIM} ${SIM_NAME} ${SIM_BOOT} ${SIM_CPU} ${SIM_MEM} ${SIM_PLATFORM} ${SIM_VGA} ${SIM_MISC} \
	${SIM_PIVNET} ${SIM_PUBNET} \
	${SIM_SAS_HD} ${SIM_AHCICTL} ${SIM_AHCIDRV} \
	${SIM_EHCICTL} ${SIM_CHAR}
