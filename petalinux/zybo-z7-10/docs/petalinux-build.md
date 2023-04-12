# Petalinux Build

## Building/Packaging Target Images
- petalinux-build

    ```console
    host:~/projects/zybo-z7-10/os$ petalinux-build
    ```

- create BOOT.bin
    ```console
    host:~/projects/zybo-z7-10/os$ petalinux-package --boot --force --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --u-boot
    ```

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

```
petalinux-build -c device-tree
petalinux-build -c kernel
petalinux-build -c rootfs
```