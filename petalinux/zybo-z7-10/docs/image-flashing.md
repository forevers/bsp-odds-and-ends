# Image Flashing

## SD Card

- see /os/images/linux for assets

- fdisk FAT32 format SD card boot directory and copy boot.scr, BOOT.bin and image.ub (if not packaged in Boot.bin)

- fdisk other ext4 partitions as needed

    - create ext4 for overlayfs usage

        - fdisk a new partition (/dev/sdc for example)

            ```
            host$ sudo fdisk /dev/sdc
            ...
            Device      Boot   Start      End  Sectors  Size Id Type
            /dev/sdc1p1         2048  2099199  2097152    1G  c W95 FAT32 (LBA)
            /dev/sdc1p2      2099200  4196351  2097152    1G 83 Linux
            /dev/sdc1p3      4196352  6293503  2097152    1G 83 Linux
            /dev/sdc1p4      6293504 62355455 56061952 26.7G 83 Linux
            ```

        - configure ext4 in partition

            ```
            $ sudo mkfs.vfat /dev/sdc1
            $ sudo fatlabel /dev/sdc1 bootfs
            $ sudo mkfs.ext4 -L p2 /dev/sdc2
            $ sudo mkfs.ext4 -L p3 /dev/sdc3
            $ sudo mkfs.ext4 -L p4 /dev/sdc4
            ```

        - reinsert SD card to enumerate filesystems

            ```
            steve@embedify:/mnt/data/projects/clones/bsp-odds-and-ends/petalinux/zybo-z7-10/os$ mount | grep sdc
            /dev/sdc2 on /media/<USER>/p2 type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2)
            /dev/sdc3 on /media/<USER>/p3 type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2)
            /dev/sdc4 on /media/<USER>/p4 type ext4 (rw,nosuid,nodev,relatime,errors=remount-ro,uhelper=udisks2)
            ```

        - on target

            ```
            root@Petalinux-2022:~# mount | grep /run/media/mmcblk0p
            /dev/mmcblk0p2 on /run/media/mmcblk0p2 type ext4 (rw,relatime)
            /dev/mmcblk0p1 on /run/media/mmcblk0p1 type vfat (rw,relatime,gid=6,fmask=0007,dmask=0007,allow_utime=0020,codepage=437,iocharset=iso8859-1,shortname=mixed,errors=remount-ro)
            /dev/mmcblk0p3 on /run/media/mmcblk0p3 type ext4 (rw,relatime)
            /dev/mmcblk0p4 on /run/media/mmcblk0p4 type ext4 (rw,relatime)
            ```

- udev rules for emmc partition mounts

    - if partitions not already included in /etc/fstab are detected an attempt to mount them using /etc/udev/scripts/mount.sh:

        ```
        root@Petalinux-2022:~# cat /etc/udev/rules.d/automount.rules
        ...
        SUBSYSTEM=="block", ACTION=="add"    RUN+="/etc/udev/scripts/mount.sh"
        SUBSYSTEM=="block", ACTION=="remove" RUN+="/etc/udev/scripts/mount.sh"
        SUBSYSTEM=="block", ACTION=="change", ENV{DISK_MEDIA_CHANGE}=="1" RUN+="/etc/udev/scripts/mount.sh"
        ```

## QSPI Flash

- vitis import existing ide project or create new one from proper hardware design files

- Xilinx > "Program Flash"

    - specificy desired FPGA bit file and BOOT.bin
    - start the xst flashing session ...

        ```
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
