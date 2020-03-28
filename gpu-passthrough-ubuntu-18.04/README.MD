# GPU Passthrough with QEMU/KVM/Libvirt

*GPU passthrough is a technology that allows you to directly present an internal PCI GPU to a virtual machine. The device acts as if it were directly driven by the VM, and the VM detects the PCI device as if it were physically connected.* [1](https://wiki.gentoo.org/wiki/GPU_passthrough_with_libvirt_qemu_kvm)


## First Configuration

* Go into BIOS (EFI) settings and turn on VT-d and IOMMU support.
* Turn on IOMMU in GRUB. Edit file /etc/default/grub and add parameters to the kernel

## System Initial Status 

At a first glance the **IOMMU capability** and **vfio driver** must not be enabled (if its the first time you use it). The following commands should not show an output.

```sh
dmesg | grep 'IOMMU enabled'
dmesg | grep -i vfio
```

The following commands show which kernel module and drivers are loaded to manage the **Nvidia GPU Decives**. At this time the NVIDIA VGA is managed by the nvidia driver and modules such us noveau, nvidia where loaded. The same thing happes with the Nvidia audio device. When we finish to configure the GPU passthrough the vfio driver will take control of Nvidia VGA and Audio devices.

```sh
lspci -nnk

...
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GM107GL [Quadro K2200] [10de:13ba] (rev a2)
	Subsystem: NVIDIA Corporation GM107GL [Quadro K2200] [10de:1097]
	Kernel driver in use: nvidia
	Kernel modules: nvidiafb, nouveau, nvidia_drm, nvidia
01:00.1 Audio device [0403]: NVIDIA Corporation Device [10de:0fbc] (rev a1)
	Subsystem: NVIDIA Corporation Device [10de:1097]
...
```

**NOTE:** Copy the PCI addresses of the Nvidia VGA and Audio devices: **10de:13ba**, **10de:0fbc**

## Settings

Create a backup for grub.

```sh 
sudo cp /etc/default/grub /etc/default/grub.back
```

Edit the grub. And complete the GRUB_CMDLINE_LINUX varible.

```sh
sudo nano /etc/default/grub

GRUB_CMDLINE_LINUX="... intel_iommu=on pcie_acs_override=downstream,multifunction ..."
```

Update the grub

```sh
sudo update-grub
```

Create the file /etc/modprobe.d/vfio.conf to load the vfio driver as a kernel module.

```sh
nano /etc/modprobe.d/vfio.conf

options vfio-pci ids=10de:13ba,10de:0fbc
```

Generate the grub configuration

```sh
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Add the nouveau driver to the blacklist to prevent the kernel from loading the noveau module and drivers.

```sh
sudo bash -c "echo blacklist nouveau > /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
sudo bash -c "echo options nouveau modeset=0 >> /etc/modprobe.d/blacklist-nvidia-nouveau.conf"
```

Reboot

```sh
sudo reboot now
```

## System Final State

Check that IOMMU is enabled

```sh 
dmesg | grep 'IOMMU'

[    0.000000] DMAR: IOMMU enabled
```

Check that VFIO driver is loaded

```sh 
dmesg | grep -i vfio

[    7.716079] VFIO - User Level meta-driver version: 0.3
[    7.759591] vfio-pci 0000:01:00.0: vgaarb: changed VGA decodes: olddecodes=io+mem,decodes=io+mem:owns=none
[    7.776019] vfio_pci: add [10de:13ba[ffff:ffff]] class 0x000000/00000000
[    7.796032] vfio_pci: add [10de:0fbc[ffff:ffff]] class 0x000000/00000000
[  169.547289] vfio-pci 0000:01:00.0: enabling device (0000 -> 0003)
[  169.547475] vfio_ecap_init: 0000:01:00.0 hiding ecap 0x1e@0x258
...
```

Check that VFIO driver was loaded to manage Nvidia VGA and Audio devices

```sh
lspci -nnk
...
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GM107GL [Quadro K2200] [10de:13ba] (rev a2)
	Subsystem: NVIDIA Corporation GM107GL [Quadro K2200] [10de:1097]
	Kernel driver in use: vfio-pci
	Kernel modules: nvidiafb, nouveau
01:00.1 Audio device [0403]: NVIDIA Corporation Device [10de:0fbc] (rev a1)
	Subsystem: NVIDIA Corporation Device [10de:1097]
	Kernel driver in use: vfio-pci
	Kernel modules: snd_hda_intel
...
```

## Install QEMU, KVM and Libvirt

```sh
# sudo apt-get install qemu-kvm libvirt-bin bridge-utils virt-manager
sudo apt-get install qemu-kvm libvirt-bin bridge-utils virtinst ovmf qemu-utils
```

## Deploy Virtual Machine

I recommend to use the Virtual Machine Manage (QEMU/KVM) User Interface to create the virtua machine. 

Remmember to attach the PCI device corresponding to the Nvidia VGA.


If you are familiar with **virt-install** you can use the follwoing command to deploy a virtual machine.

```sh
virt-install \
	--name ubuntu1804 \
	--ram 8192 \
	--disk path=~/.kvm/images/ubuntu1804.img,size=30 \
	--vcpus 4 \
	--cpu host \
	--os-type linux \
	--os-variant ubuntu17.10 \
	--network bridge=virbr0 \
	--graphics vnc \
	--console pty,target_type=serial \
	--location 'http://jp.archive.ubuntu.com/ubuntu/dists/bionic/main/installer-amd64/' \
	--extra-args 'console=ttyS0,115200n8 serial' \
	--host-device 01:00.0 \
	--features kvm_hidden=on \
	--machine q35 \
	--extra-args 'console=ttyS0,115200n8 serial' 
```

# References

- [GPU passthrough with libvirt qemu kvm](https://wiki.gentoo.org/wiki/GPU_passthrough_with_libvirt_qemu_kvm)
- [KVM : GPU Passthrough](https://www.server-world.info/en/note?os=Ubuntu_18.04&p=kvm&f=11)
- [GPU Virtualization with KVM / QEMU](https://medium.com/@calerogers/gpu-virtualization-with-kvm-qemu-63ca98a6a172)
- [How to disable Nouveau nvidia driver on Ubuntu 18.04 Bionic Beaver Linux](https://linuxconfig.org/how-to-disable-nouveau-nvidia-driver-on-ubuntu-18-04-bionic-beaver-linux)