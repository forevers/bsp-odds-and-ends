# SD Card Image Flashing

- resulting images in /workdir/bsp/build$tmp/deploy/images/raspberrypi4-64/. several means available to flash images to SD card: yocto **bmaptool** utility (wic file), rpi-imager 'Raspberry Pi Imager' (wic file), dd (wic file), manual partitioning/formatting/copying.

- flash rpi-test-image-raspberrypi4-64.wic.bz2 (boot and root images) to SD card

    - wic utility: https://docs.yoctoproject.org/ref-manual/kickstart.html

    - oe bmaptool utility part of yocto and standalone

        - https://docs.yoctoproject.org/dev-manual/common-tasks.html?highlight=bmaptool#flashing-images-using-bmaptool

            ```console
            host$ oe-run-native bmap-tools-native bmaptool copy tmp/deploy/images/raspberrypi4-64/rpi-test-image-raspberrypi4-64.wic.bz2 /dev/sdc
            ```

        - https://github.com/intel/bmap-tools available for Ubuntu package installation

            - umount media if needed
                ```console
                - $ umount /media/\<name>/boot
                - $ umount /media/\<name>/root
                ```
            - **bmaptool** the wic file
                ```console
                host$ sudo bmaptool copy tmp/deploy/images/raspberrypi4-64/rpi-test-image-raspberrypi4-64.wic.bz2 /dev/sdc
                ```

        - use rpi imager with custom wic image (ess-image-raspberrypi-64-ess-<timestamp>.rootfs.wic.bz2)

    - create ext4 for overlayfs usage

        - fdisk a new partition
            ```console
            host$ fdisk /dev/sdc
            ```
        - configure ext4 in partition
            ```console
            $ sudo mkfs.ext4 -L data /dev/sdc3
            ```

- manual ext4 rootfs update

    ```console
    sudo tar --no-overwrite-dir -xzvf ess-image-raspberrypi4-64-ess.tar.bz2 -C <sd card mount path>/root
    ```
