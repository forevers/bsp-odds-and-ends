# Petalinux Builds

## Petalinx Version

- 2022.1

## Distro Features

    - initrd rootfs
    - debug uart
    - systemd
    - dts overlay with dma driver example

## Tools Installation

- Note: tool installation on Ubuntu 22.04 (not formally sported by Xilinx)

- Vitis/Vivado installation

    - references:
        - https://digilent.com/reference/programmable-logic/zybo-z7/demos/petalinux
        - https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-vitis

    - 2022.1 is latest support toolchain version fpr zybo z7 platforms:
        - https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2022-1.html

    - install the tools to default location /tools/Xilinx. only 7 series devices required for zybo.
        ```console
        chmod +x Xilinx_Unified_2022.1_0420_0327_Lin64.bin && sudo ./Xilinx_Unified_2022.1_0420_0327_Lin64.bin
        ```

    - installation includes:
        - vivado - hdl
        - vitis - vitis hls, sw sdk

    - see ug973 for cable driver instructions
        ```console
        host:/tools/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/install_script/install_drivers$ sudo ./install_drivers
        INFO: Installing cable drivers.
        ...
        CRITICAL WARNING: Cable(s) on the system must be unplugged then plugged back in order for the driver scripts to update the cables.
        steve@embedify:/tools/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/
        ```

    - digilent board files
        - https://github.com/Digilent/vivado-boards/archive/master.zip?_ga=2.26386043.719103120.1668636885-892977042.1667254672
        - vivado-boards-master.zip
            - copy its new/board_files folder to /tools/Xilinx/Vivado/2022.1/data/boards/board_files

    - verify install
        - vivado launch
            ```console
            $ source /tools/Xilinx/Vivado/2022.1/settings64.sh
            $ vivado
            ```

        - vitis launch
            ```console
            $ source /tools/Xilinx/Vitis/2022.1/settings64.sh
            $ vitis
            ```

- PetaLinux installation

    - 2022.1 installer
    https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools/2022-1.html

    - Ubuntu 22.01 host required install gcc-multilib package in order to install PL

        ```console
        host:~/tools$ ./petalinux-v2022.1-04191534-installer.run --dir ~/tools/petalinux_2022_1
        ```

## Petalinux project construction from prebuilt bsp

- source PL env settings

    ```console
    host:~/projects/zybo-z7-10$ source ~/tools/petalinux_2022_1/settings.sh
    ```

- download the '*.bsp' file from the demo release page

    - ***PetaLinux BSPs are provided in the form of installable BSP files, and include all necessary design and configuration files, pre-built and tested hardware, and software images ready for downloading on your board or for booting in the QEMU system emulation environment.***

    - bsp file can be used in initial PetaLinux project generation vs a template based project generation

    - general repo
        https://digilent.com/reference/programmable-logic/documents/git

    - zybo z7-10 repo (includes released bsp)
        https://github.com/Digilent/Zybo-Z7/releases/tag/10%2FPetalinux%2F2022.1-1?_ga=2.77896784.511116902.1668454546-892977042.1667254672

    - bsp zip file elements:
        - /os/hardware/system.bit
        - /os/project-spec/hw-description/system.xsa
            - system.xsa zip file elements:
                ```console
                drivers/axi_i2s_adi_v1_0/data/axi_i2s_adi.mdd
                drivers/axi_i2s_adi_v1_0/data/axi_i2s_adi.tcl
                drivers/axi_i2s_adi_v1_0/src/axi_i2s_adi.c
                drivers/axi_i2s_adi_v1_0/src/axi_i2s_adi.h
                drivers/axi_i2s_adi_v1_0/src/axi_i2s_adi_selftest.c
                drivers/axi_i2s_adi_v1_0/src/Makefile
                drivers/dynclk/data/dynclk.mdd
                drivers/dynclk/data/dynclk.tcl
                drivers/dynclk/src/ddynclk.c
                drivers/dynclk/src/ddynclk.h
                drivers/dynclk/src/ddynclk_g.c
                drivers/dynclk/src/ddynclk_selftest.c
                drivers/dynclk/src/ddynclk_sinit.c
                drivers/dynclk/src/Makefile
                drivers/PWM_v1_0/data/PWM.mdd
                drivers/PWM_v1_0/data/PWM.tcl
                drivers/PWM_v1_0/src/Makefile
                drivers/PWM_v1_0/src/PWM.c
                drivers/PWM_v1_0/src/PWM.h
                drivers/PWM_v1_0/src/PWM_selftest.c
                ps7_init.c
                ps7_init.h
                ps7_init.html
                ps7_init.tcl
                ps7_init_gpl.c
                ps7_init_gpl.h
                sysdef.xml
                system.bda
                system.hwh
                system_wrapper.bit
                xsa.json
                xsa.xml
                ```

- create project based off released BSP

    ```console
    host:~/projects/zybo-z7-10$ petalinux-create -t project -s ../bsp/Zybo-Z7-10-Petalinux-2022-1.bsp
    ```

## Builds based off an update hdl design (xsa and bit files)

- for modifications to initial fpga design ...
    - ***The petalinux-config --get-hw-description command allows you to initialize or update a PetaLinux project with hardware-specific information from the specified Vivado® Design Suite hardware project. The components affected by this process can include FSBL configuration, U-Boot options, Linux kernel options, and the Linux device tree configuration. This workflow should be used carefully to prevent accidental and/or unintended changes to the hardware configuration for the PetaLinux project. The path used with this workflow is the directory that contains the XSA file rather than the full path to the XSA file itself. This entire option can be omitted if run from the directory that contains the XSA file.***

- place new xsa file in ../bsp/Zybo-Z7-10-Petalinux-2022-1/os/project-spec/hw-description

- config the project based on (potentially new) xsa

    ```console
    host:/bsp-odds-and-ends/petalinux/zybo-z7-10/os$ petalinux-config --get-hw-description ../bsp/Zybo-Z7-10-Petalinux-2022-1/os/project-spec/hw-description --silentconfig
    ```

## dts modifications

- version

    ```console
    host:/bsp-odds-and-ends/petalinux/zybo-z7-10/os$ dtc --version
    Version: DTC 1.6.1
    ```

- dts overlay

    - target overlay location

        ```console
        root@Petalinux-2022:~# ls /sys/kernel/config/device-tree/overlays/
        ```

    - create dts overlay file

    - modify config CONFIG_SUBSYSTEM_EXTRA_DT_FILES to reference overlay dts source for petalinux-build to compile and place the overlay dtbo in /boot/devicetree

    - during development

        - compile overlay file (-@ to retain symbol info)

            ```console
            host:/bsp-odds-and-ends/petalinux/zybo-z7-10/os$ dtc -b 0 -@ -O dtb ../dts-overlays/ess-dma-moc-overlay.dts -o /dev/shm/ess-dma-moc-overlay.dtbo
            ```

        - copy overlay dtbo to target

            ```console
            host:$ scp /dev/shm/ess-dma-moc-overlay.dtbo root@<ip>:/dev/shm

    - create overlay subdir on target

        ```console
        root@Petalinux-2022:/sys/kernel/config/device-tree/overlays mkdir ess-dma-moc & cd ess-dma-moc
        ```

    - activate the overlay

        ```console
        root@Petalinux-2022:/sys/kernel/config/device-tree/overlays/ess-dma-moc# cat /boot/devicetree/ess-dma-moc-overlay.dtbo >dtbo
        root@Petalinux-2022:/sys/kernel/config/device-tree/overlays/ess-dma-moc# cat status
        applied
        ```

    - inspect target dts tree

        ```console
        root@Petalinux-2022:~# ls /proc/device-tree/ess-dma-moc/
        buffer_size          compatible           ess_property_array   ess_property_string  name                 status
        ```

    - kernel module example

        - petalinux-create -t modules --name ess-dma-moc --enable
        - https://support.xilinx.com/s/article/1165442?language=en_US
            - petalinux/zybo-z7-10/os/build/conf/local.conf
            - comment out INHERIT += "rm_work"
        - host:os$ petalinux-build -c ess-dma-moc -x do_listtasks
        - host:os$ petalinux-build -c ess-dma-moc -x compile

        - see bsp-odds-and-ends/petalinux/zybo-z7-10/os/build/tmp/work/zynq_generic-xilinx-linux-gnueabi/ess-dma-moc/1.0-r0/image/lib/modules/5.15.19-xilinx-v2022.1/extra for ess-dma-moc.ko for kernel module

        - load module

            - modprobe requres module located in /lib/modules/5.15.19-xilinx-v2022.1/extra

                ```console
                host:ox$ scp ./build/tmp/work/zynq_generic-xilinx-linux-gnueabi/ess-dma-moc/1.0-r0/ess-dma-moc.ko root@$TARGET_IP:/lib/modules/5.15.19-xilinx-v2022.1/extra
                ```
                ```console
                root@Petalinux-2022:~# modprobe ess-dma-moc
                ```

            else

            - use insmod from arbitrary location

                ```console
                host:os$ scp ./build/tmp/work/zynq_generic-xilinx-linux-gnueabi/ess-dma-moc/1.0-r0/ess-dma-moc.ko root@$TARGET_IP:/dev/shm
                ```
                ```console
                root@Petalinux-2022:~# insmod /dev/shm/ess-dma-moc.ko
                ```

        - log output

            ```console
            root@Petalinux-2022:~# journalctl -k | tail

            Nov 25 22:53:58 Petalinux-2022 kernel: ess_dma_moc: loading out-of-tree module taints kernel.
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_init::(420): entry
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_init::(421): 2 cpus
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_probe::(287): entry
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_probe::(289): PAGE_SIZE: 4096
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_probe::(290): process kernel vma start address PAGE_SIZE: c0000000
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_probe::(294): dma_device: 4da0c252
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_probe::(304): buffer_size: 12345
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_probe::(318): data_tx_buffer: f9dc4968
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_probe::(325): data_rx_buffer: 2aa8e37b
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_probe::(343): exit
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::create_proc::(258): entry
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::create_proc::(259): exit
            Nov 25 22:53:58 Petalinux-2022 kernel: ess-dma-moc.c::dma_init::(430): exit
            ```

        - verify devnode existence

            ```console
            root@Petalinux-2022:~# ls /dev/ess-dma-moc
            /dev/ess-dma-moc
            ```

        - test driver

            ```console
            root@Petalinux-2022:~# echo '12345' > /dev/ess-dma-moc
            root@Petalinux-2022:~# journalctl -k | tail
            Nov 25 23:14:57 Petalinux-2022 kernel: ess-dma-moc.c::dma_write::(140): entry
            Nov 25 23:14:57 Petalinux-2022 kernel: ess-dma-moc.c::dma_write::(141): dma 0x6 bytes
            Nov 25 23:14:57 Petalinux-2022 kernel: ess-dma-moc.c::dma_write::(154): fist transfer byte 31 of 6 bytes
            Nov 25 23:14:57 Petalinux-2022 kernel: ess-dma-moc.c::dma_done_callback::(121): entry
            Nov 25 23:14:57 Petalinux-2022 kernel: ess-dma-moc.c::dma_done_callback::(125): exit
            Nov 25 23:14:57 Petalinux-2022 kernel: ess-dma-moc.c::dma_write::(199): dma rx buf string 12345
            Nov 25 23:14:57 Petalinux-2022 kernel: ess-dma-moc.c::dma_write::(200): 0: 49
            Nov 25 23:14:57 Petalinux-2022 kernel: ess-dma-moc.c::dma_write::(201): 1: 50
            Nov 25 23:14:57 Petalinux-2022 kernel: ess-dma-moc.c::dma_write::(202): 2: 51
            Nov 25 23:14:57 Petalinux-2022 kernel: ess-dma-moc.c::dma_write::(209): exit
            ```

- patch existing dts node
    - TODO

    - manually create diff from commit to apply to existing meta-ess/recipes-kernel/linux/ ... TODO

    - verify dts modification

        - by reversing compiling build dtb
            ```console
            host:/bsp-odds-and-ends/petalinux/zybo-z7-10/os$ dtc -I dtb -O dts images/linux/system.dtb -o /dev/shm/reverse_compiled.dts
            ```

        - target /proc/device-tree -> /sys/firmware/devicetree/home

        - by target image inspection ... TODO
            ```console
            root@ess-hostname:~# cat /proc/device-tree/ ...
            ess patch
            ```

- FPGA Manager (see ug1144)

    - CONFIG_SUBSYSTEM_FPGA_MANAGER enable the fpga manager

    - 'FPGA manager overrides all the options of the device tree overlay. Device Tree Overlay will come into play only when FPGA manager is not selected.'

    - 'The FPGA manager provides an interface to Linux for configuring the programmable logic (PL). It packs the dtbos and bitstreams into the /lib/firmware/xilinx directory in the root file system.'

    - 'Generates the pl.dtsi nodes as a dt overlay (dtbo).'

    - 'fpgautil linux utility to load PL at runtime'

- overlayfs-etc attempt
    - place IMAGE_FEATURES:append = " overlayfs-etc" in petalinuxbsp.conf
        ```console
        ERROR: Nothing PROVIDES 'petalinux-image-minimal'
        petalinux-image-minimal was skipped: 'overlayfs-etc' in IMAGE_FEATURES is not a valid image feature. Valid features: allow-empty-password allow-root-login bash-completion-pkgs dbg-pkgs debug-tweaks dev-pkgs doc doc-pkgs eclipse-debug empty-root-password fpga-manager hwcodecs lic-pkgs nfs-client nfs-server package-management petalinux-96boards-sensors petalinux-audio petalinux-base petalinux-benchmarks petalinux-display-debug petalinux-gstreamer petalinux-jupyter petalinux-lmsensors petalinux-matchbox petalinux-mraa petalinux-multimedia petalinux-networking-debug petalinux-networking-stack petalinux-ocicontainers petalinux-openamp petalinux-opencv petalinux-pynq petalinux-pynq-96boardsoverlay petalinux-pynq-bnn petalinux-pynq-helloworld petalinux-python-modules petalinux-qt petalinux-qt-extended petalinux-self-hosted petalinux-som petalinux-tpm petalinux-ultra96-webapp petalinux-utils petalinux-v4lutils petalinux-weston petalinux-x11 petalinux-xen post-install-logging ptest-pkgs qtcreator-debug read-only-rootfs read-only-rootfs-delayed-postinsts splash src-pkgs ssh-server-dropbear ssh-server-openssh stateless-rootfs staticdev-pkgs tools-debug tools-profile tools-sdk tools-testapps weston x11 x11-base x11-sato
        ```

## Petalinux Build

- petalinux-build

    ```console
    host:~/projects/zybo-z7-10/os$ petalinux-build
    ```

- create BOOT.bin
    ```console
    host:~/projects/zybo-z7-10/os$ petalinux-package --boot --force --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --u-boot
    ```
## Useful Petalinux commands

```console
petalinux-build -c device-tree
petalinux-build -c kernel
petalinux-build -c rootfs
```

## Image Flashing

### SD Card

- fdisk FAT32 format SD card boot directory and copy boot.scr, BOOT.bin and image.ub (if not packaged in Boot.bin)

- fdisk other ext4 partitions as needed

    - create ext4 for overlayfs usage

        - fdisk a new partition (/dev/sdc for example)

            ```console
            host$ sudo fdisk /dev/sdc
            ...
            Device      Boot   Start      End  Sectors  Size Id Type
            /dev/sdc1p1         2048  2099199  2097152    1G  c W95 FAT32 (LBA)
            /dev/sdc1p2      2099200  4196351  2097152    1G 83 Linux
            /dev/sdc1p3      4196352  6293503  2097152    1G 83 Linux
            /dev/sdc1p4      6293504 62355455 56061952 26.7G 83 Linux
            ```

        - configure ext4 in partition
            ```console
            $ sudo mkfs.vfat /dev/sdc1
            $ sudo mkfs.ext4 -L p2 /dev/sdc2
            $ sudo mkfs.ext4 -L p3 /dev/sdc3
            $ sudo mkfs.ext4 -L p4 /dev/sdc4
            ```

        - reinsert SD card to enumerate filesystems
            ```console
            steve@embedify:/mnt/data/projects/clones/bsp-odds-and-ends/petalinux/zybo-z7-10/os$ mount | grep sdc
            /dev/sdc2 on /media/<USER>/p2 type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2)
            /dev/sdc3 on /media/<USER>/p3 type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2)
            /dev/sdc4 on /media/<USER>/p4 type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2)
            ```

        - on target
            ```console
            root@Petalinux-2022:~# mount | grep /run/media/mmcblk0p
            /dev/mmcblk0p2 on /run/media/mmcblk0p2 type ext4 (rw,relatime)
            /dev/mmcblk0p1 on /run/media/mmcblk0p1 type vfat (rw,relatime,gid=6,fmask=0007,dmask=0007,allow_utime=0020,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro)
            /dev/mmcblk0p3 on /run/media/mmcblk0p3 type ext4 (rw,relatime)
            /dev/mmcblk0p4 on /run/media/mmcblk0p4 type ext4 (rw,relatime)
            ```

### QSPI Flash

- vitis import existing ide project or create new one from proper hardware design files

- Xilinx > "Program Flash"
    - specificy desired FPGA bit file and BOOT.bin
    - start the xst flashing session ...
        ```console
        program_flash -f \
        /mnt/data/projects/clones/bsp-odds-and-ends/petalinux/zybo-z7-10/os/images/linux/BOOT.BIN \
        -offset 0 -flash_type qspi-x4-single -fsbl \
        /mnt/data/projects/clones/bsp-odds-and-ends/petalinux/zybo-z7-10/os/images/linux/zynq_fsbl.elf \
        -cable type xilinx_tcf url TCP:127.0.0.1:3121

        ****** Xilinx Program Flash
        ****** Program Flash v2022.1 (64-bit)
        **** SW Build 3524075 on 2022-04-13-17:42:45
            ** Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
        ...
        U-Boot 2022.01-06940-g8ed6b9e (Feb 24 2022 - 09:48:08 -0700)

        Model: Zynq CSE QSPI SINGLE Board
        DRAM:  256 KiB
        WARNING: Caches not enabled
        Loading Environment from <NULL>... OK
        In:    dcc
        Out:   dcc
        Err:   dcc
        Zynq> sf probe 0 0 0

        SF: Detected w25q128jv with page size 256 Bytes, erase size 64 KiB, total 16 MiB
        Zynq> Sector size = 65536.
        f probe 0 0 0

        Performing Erase Operation...
        sf erase 0 200000

        SF: 2097152 bytes @ 0x0 Erased: OK
        Zynq> Erase Operation successful.
        INFO: [Xicom 50-44] Elapsed time = 7 sec.
        Performing Program Operation...
        0%...sf write FFFC0000 0 20000

        device 0 offset 0x0, size 0x20000
        SF: 131072 bytes @ 0x0 Written: OK
        Zynq> sf write FFFC0000 20000 20000
        ...
        device 0 offset 0x1c0000, size 0x20000
        SF: 131072 bytes @ 0x1c0000 Written: OK
        Zynq> 100%
        sf write FFFC0000 1E0000 1BB7C

        device 0 offset 0x1e0000, size 0x1bb7c
        SF: 113532 bytes @ 0x1e0000 Written: OK
        Zynq> Program Operation successful.
        INFO: [Xicom 50-44] Elapsed time = 11 sec.

        Flash Operation Successful
        ```

- fdisk external sd card (mounted at /run/media/mmcblk0p1) with other ext4 partitions as needed


TODO:
- configure tftp/nfs boot of kernel/bit/rootfs
- barrel power source
- detail jumper settings
- bootgen
- investigate ext partitioning qspi flash
- investigate persistent rootfs
- investigate overlay over rootfs
- evaluate digilent jtag debugger jsn-JTAG-HS2-210249ACD403
    - https://digilent.com/shop/jtag-hs2-programming-cable/?utm_source=google&utm_medium=cpc&utm_campaign=18640327811&utm_content=140606091822&utm_term=&gclid=Cj0KCQiAg_KbBhDLARIsANx7wAyXqvVNBMCV-MFBfu0BbaULrKQD6lgmNrASC7yZGYcuiaO563MWhGUaAiVYEALw_wcB

## Power and UART console

- u-USB to PC provides both power and FTDI console on /etc/TTYUSB<x>

    ```console
    Bus 003 Device 007: ID 0403:6010 Future Technology Devices International, Ltd FT2232C/D/H Dual UART/FIFO IC
    ```

## mipi camera notes
- seems like digilent pcam is mipi camera required ... what about rpi camera ?
    - https://community.element14.com/products/roadtest/rv/roadtest_reviews/653/digilent_zybo_z7_pca_2
- z10 limitations ?
    - https://forum.digilent.com/topic/17944-petalinux-on-zybo-z7-10/
- ... but wait this thread indicates turning off csi-2 ip debug reduces gate usage ... have to recompile the vivado demo to make it work
    =- https://forum.digilent.com/topic/16834-zybo-z7-20-pcam-demo-unimplementable-on-vivado-20174/

- other links
    - https://forum.digilent.com/topic/16385-pcam-5c-demo-on-zybo-z7-10/?sortby=date
    = https://ohwr.org/project/soc-course/wikis/Reverse-Engineering-the-XSA-File

## Image Testing

- verify systemd installation

    - [systemd](/docs_shared/systemd.md) usage
    - [journald](/docs_shared/journald.md) usage


## References

### digilent vivado/vitis 2022.1 installation
https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-vitis
https://github.com/Digilent/Zybo-Z7/compare/master...10/Petalinux/master
### digilent demos
https://digilent.com/reference/programmable-logic/zybo-z7/demos/petalinux

### xilinx download site
https://www.xilinx.com/support/download.html?_ga=2.170161764.511116902.1668454546-892977042.1667254672
“Vivado ML Edition - <Version #>”
### PL tools
https://docs.xilinx.com/v/u/2020.1-English/ug1144-petalinux-tools-reference-guide
### xilinx wiki
https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842482/Device+Tree+Tips

### device tree
https://elinux.org/images/f/f9/Petazzoni-device-tree-dummies_0.pdf
https://elinux.org/Device_Tree_Mysteries
https://www.kernel.org/doc/Documentation/devicetree/bindings/arm/xilinx.txt
