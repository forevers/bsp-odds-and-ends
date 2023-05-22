# Petalinux Build

## Building/Packaging Target Images
- source PL env settings
    ```
    host:~/projects/zybo-z7-10$ source ~/tools/petalinux_2022_1/settings.sh
    ```

- manual petalinux-build (not required if xilinx-bootbin added to IMAGE_INSTALL)
    ```console
    host:~/projects/zybo-z7-10/os$ petalinux-build
    ```

- create BOOT.bin
    ```console
    host:~/projects/zybo-z7-10/os$ petalinux-package --boot --force --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --u-boot
    ```

- Build results in
    - bsp-odds-and-ends/petalinux/zybo-z7-10/os/build/tmp/deploy/images/zynq-generic
        - boot.bin
    - petalinux/zybo-z7-10/os/images/linux
        - image.ub

## image components

### boot.bin
boot.bin is created using the xilinx-bootbin recipe with its default bootgen configuration.

### FIT image
image.ub is the FIT image containing the kernel, dtb and ramdisk.

## Tips and Tricks

- local.conf

    - petalinux/zybo-z7-10/os/build/conf/local.conf
    - defaults to INHERIT += "rm_work"

- dtb reverse compile

    ```
    $ dtc -I dtb -O dts images/linux/system.dtb -o /dev/shm/reverse_compiled.dts
    ```

- kernel config location

    - os/build/tmp/work-shared/zynq-generic/kernel-build-artifacts/.config


- kernel source location

    - os/build/tmp/work-shared/zynq-generic/kernel-source/


## Useful Petalinux commands

Default petalinux command is build but there are several other bitbake controls exposed using the -x execute option: build, clean, cleanall, cleansstate, distclean, install, listtasks, populate_sysroot, package, mrproper

```
petalinux-build -c device-tree
petalinux-build -c kernel
petalinux-build -c rootfs
petalinux-build -c xilinx-bootbin -x clean
```
