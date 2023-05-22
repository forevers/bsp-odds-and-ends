# Building Xilinx Yocto

## bitbaking

1. source the setupsdk to copy plnxtool.conf file into yocto/build/conf directory from yocto/sources/petalinux and add yocto/sources/petalinux/project-spec/meta-user layer into yocto/build/conf/bblayers.conf file
    ```sh
    bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ PLNX_SETUP=1 source setupsdk
    ```

1. bake
    ```sh
    bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ bitbake petalinux-image-minimal
    ```

1. Build results in
    - bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto/build/tmp/deploy/images/zynq-generic
        - boot.bin
    - petalinux_yocto/zybo-z7-10/yocto/sources/petalinux/images/linux
        - image.ub

## image components

### boot.bin
The boot.bin is created using the xilinx-bootbin recipe with its default bootgen configuration.

### FIT image
image.ub is the FIT image containing the kernel, dtb and ramdisk.

```
sources/petalinux/images/linux$ dumpimage -l image.ub
FIT description: Kernel fitImage for PetaLinux/5.15.19+gitAUTOINC+machine/zynq-generic
 Image 0 (kernel-1)
 Image 1 (fdt-system-top.dtb)
 Image 2 (fdt-system-top-ess-dma-moc-overlay.dtb)
 Image 3 (fdt-ess-dma-moc-overlay.dtbo)
 Image 4 (ramdisk-1)
  Description:  petalinux-image-minimal
  Created:      Wed Jul 20 13:30:06 2022
  Type:         RAMDisk Image
  Compression:  uncompressed
  Data Size:    82812658 Bytes = 80871.74 KiB = 78.98 MiB
  Architecture: ARM
  OS:           Linux
  Load Address: unavailable
  Entry Point:  unavailable
  Hash algo:    sha256
  Hash value:   530f39280242942a645df5f0f39343e03f4c3cd29242fdebe98439429ebea35e
 Default Configuration: 'conf-system-top.dtb'
 Configuration 0 (conf-system-top.dtb)
 Configuration 1 (conf-system-top-ess-dma-moc-overlay.dtb)
 Configuration 2 (conf-ess-dma-moc-overlay.dtbo)
 ```

### sd card construction

- login: root/root

### petalinux-image-minimal-zynq-generic

## Interesting bitbake Recipes
```
yocto/build$ bitbake -s
```

### boot

```
bootgen                                               :1.0-r0
bootgen-native                                        :1.0-r0
fsbl-firmware                       :2022.1+gitAUTOINC+56d94a506f-r0
linux-xlnx                          :5.15.19+gitAUTOINC+machine-r0
u-boot-tools                                     1:2021.07-r0
u-boot-tools-native                              1:2021.07-r0
u-boot-xlnx                         :v2021.01-xilinx-v2022.1+gitAUTOINC+8e8809e33a-r0
u-boot-zynq-scr                                       :1.0-r0
u-boot-zynq-uenv                                      :1.0-r0
uboot-device-tree                   :xilinx-v2022.1+gitAUTOINC+1b364a44fa-r0
xilinx-bootbin                                        :1.0-r0
```

### rootfs

```
core-image-base                                       :1.0-r0
core-image-full-cmdline                               :1.0-r0
core-image-kernel-dev                                 :1.0-r0
core-image-minimal                                    :1.0-r0
core-image-minimal-dev                                :1.0-r0
core-image-minimal-initramfs                          :1.0-r0
core-image-minimal-mtdutils                           :1.0-r0
core-image-minimal-xfce                               :1.0-r0
core-image-ptest-all                                  :1.0-r0
core-image-ptest-fast                                 :1.0-r0
core-image-sato                                       :1.0-r0
core-image-sato-dev                                   :1.0-r0
core-image-sato-sdk                                   :1.0-r0
core-image-testmaster                                 :1.0-r0
core-image-weston                                     :1.0-r0
core-image-weston-sdk                                 :1.0-r0
core-image-x11                                        :1.0-r0
petalinux-image-everything                            :1.0-r0
petalinux-image-full                                  :1.0-r0
petalinux-image-minimal                               :1.0-r0
petalinux-initramfs-image                             :1.0-r0
```

### filesystems packaging

```
wic-tools                                             :1.0-r0
```

### filesystems

```
fuse                                                :2.9.9-r0
fuse-exfat                                          :1.3.0-r0
fuse-native                                         :2.9.9-r0
fuse-overlayfs                                      :0.6.4-r0
fuse3                                              :3.10.5-r0
packagegroup-meta-filesystems                         :1.0-r0
parted                                                :3.4-r0
```

### utils

```
packagegroup-petalinux                                :1.0-r0
packagegroup-petalinux-utils                          :1.0-r0
protobuf                                           :3.18.0-r0
protobuf-c                                          :1.3.3-r0
protobuf-c-native                                   :1.3.3-r0
protobuf-native                                    :3.18.0-r0
util-linux                                         :2.37.2-r0
valgrind                                           :3.17.0-r0
```

### debug utils

```
devmem2                                               :1.0-r7
dmalloc                                             :5.5.2-r0
i2c-tools                                             :4.3-r0
packagegroup-core-tools-debug                         :1.0-r3
perf                                                  :1.0-r9
phytool                             :2+gitAUTOINC+8882328c08-r0
tcf-agent                           :1.7.0+gitAUTOINC+b9401083f9-r0
wireshark                                         1:3.4.11-r0
```

### networking

```
dhcpcd                                              :9.4.0-r0
init-ifupdown                                         :1.0-r7
iperf3                                                :3.9-r0
nfs-export-root                                       :1.0-r1
nfs-utils                                           :2.5.4-r0
openssh                                             :8.7p1-r0
openssl                                            :1.1.1l-r0
packagegroup-core-nfs                                 :1.0-r2
packagegroup-core-ssh-dropbear                        :1.0-r1
packagegroup-core-ssh-openssh                         :1.0-r1
packagegroup-petalinux-networking-debug                   :1.0-r0
packagegroup-petalinux-networking-stack                   :1.0-r0
samba                                              :4.14.8-r0
swig                                                :4.0.2-r0
```

### xilinx xsa

```
external-hdf                                          :1.0-r0
```

### security

```
packagegroup-core-security                            :1.0-r0
pam-plugin-ccreds                                      :11-r0
pam-plugin-ldapdb                                     :1.3-r0
pam-ssh-agent-auth                                 :0.10.3-r0
```

### graphics framework

```
packagegroup-core-x11                                :1.0-r40
packagegroup-core-x11-base                            :1.0-r1
packagegroup-core-x11-sato                           :1.0-r33
packagegroup-core-x11-xserver                        :1.0-r40
packagegroup-petalinux-x11                            :1.0-r0
wayland                                            :1.19.0-r0
weston                                              :9.0.0-r0
xwayland                                           :21.1.2-r0
```

### media

```
packagegroup-meta-multimedia                          :1.0-r0
packagegroup-meta-networking                          :1.0-r0
packagegroup-petalinux-audio                          :1.0-r0
packagegroup-petalinux-gstreamer                      :1.0-r0
packagegroup-petalinux-matchbox                       :1.0-r0
packagegroup-petalinux-multimedia                     :1.0-r0
packagegroup-petalinux-opencv                         :1.0-r0
packagegroup-petalinux-qt                             :1.0-r0
packagegroup-petalinux-qt-extended                    :1.0-r0
packagegroup-petalinux-v4lutils                       :1.0-r0
packagegroup-qt5-qtcreator-debug                      :1.0-r0
packagegroup-qt5-toolchain-target                     :1.0-r0
qtbase                              :5.15.2+gitAUTOINC+40143c189b-r0
qtmultimedia                        :5.15.2+gitAUTOINC+fd30913d46-r0
qtwayland                           :5.15.2+gitAUTOINC+3cc17177b1-r0
v4l-utils                                          :1.20.0-r0
v4l-utils-native                                   :1.20.0-r0
v4l2-camera                                       :0.4.0-1-r0
```
