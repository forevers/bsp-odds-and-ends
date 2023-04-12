# Device Tree Modifications

- auto-generated dtsi file

    ```console
    /os$ ls components/plnx_workspace/device-tree/device-tree/
    device-tree.mss           include     ps7_init_gpl.c  ps7_init.tcl      system_wrapper.bit
    drivers                   pcw.dtsi    ps7_init_gpl.h  skeleton.dtsi     zynq-7000.dtsi
    ess-dma-moc-overlay.dts   pl.dtsi     ps7_init.h      system-conf.dtsi
    hardware_description.xsa  ps7_init.c  ps7_init.html   system-top.dts
    ```

- dts file heirarchy
    - system_top.dts
        - zynq-7000.dtsi
        - pl.dtsi
        - pcw.dtsi
        - system-user.dtsi

- compiler version

    ```console
    host:/bsp-odds-and-ends/petalinux/zybo-z7-10/os$ dtc --version
    Version: DTC 1.6.1
    ```

## dts overlay

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

## patching existing dts node

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

## overlayfs-etc attempt

    - place IMAGE_FEATURES:append = " overlayfs-etc" in petalinuxbsp.conf
        ```console
        ERROR: Nothing PROVIDES 'petalinux-image-minimal'
        petalinux-image-minimal was skipped: 'overlayfs-etc' in IMAGE_FEATURES is not a valid image feature. Valid features: allow-empty-password allow-root-login bash-completion-pkgs dbg-pkgs debug-tweaks dev-pkgs doc doc-pkgs eclipse-debug empty-root-password fpga-manager hwcodecs lic-pkgs nfs-client nfs-server package-management petalinux-96boards-sensors petalinux-audio petalinux-base petalinux-benchmarks petalinux-display-debug petalinux-gstreamer petalinux-jupyter petalinux-lmsensors petalinux-matchbox petalinux-mraa petalinux-multimedia petalinux-networking-debug petalinux-networking-stack petalinux-ocicontainers petalinux-openamp petalinux-opencv petalinux-pynq petalinux-pynq-96boardsoverlay petalinux-pynq-bnn petalinux-pynq-helloworld petalinux-python-modules petalinux-qt petalinux-qt-extended petalinux-self-hosted petalinux-som petalinux-tpm petalinux-ultra96-webapp petalinux-utils petalinux-v4lutils petalinux-weston petalinux-x11 petalinux-xen post-install-logging ptest-pkgs qtcreator-debug read-only-rootfs read-only-rootfs-delayed-postinsts splash src-pkgs ssh-server-dropbear ssh-server-openssh stateless-rootfs staticdev-pkgs tools-debug tools-profile tools-sdk tools-testapps weston x11 x11-base x11-sato
        ```