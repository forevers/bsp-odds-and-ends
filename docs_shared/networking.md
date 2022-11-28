# networking configuration

## tftp boot

- see https://help.ubuntu.com/community/TFTP for tftp server configuration

    - sudo apt-get install -y tftpd-hpa
    - sudo mkdir -p /var/lib/tftpboot
    - sudo chown tftp:tftp /var/lib/tftpboot
    - see ug1144 'Configure TFTP Boot' and 'Boot a PetaLinux Image on Hardware with TFTP' section for auto copying build assets into tftp directory
        ```console
        host:/bsp-odds-and-ends/petalinux/zybo-z7-10/os$ petalinux-package --prebuilt
        ```

    - configure tftp-hpa configuration file

        ```console
        $ cat /etc/default/tftpd-hpa
        # /etc/default/tftpd-hpa

        TFTP_USERNAME="tftp"
        TFTP_DIRECTORY="/var/lib/tftpboot"
        TFTP_ADDRESS=":69"
        TFTP_OPTIONS="--secure"
        ```

    - systemctl restart tftpd-hpa.service

    - configure u-boot env for tftpboot

        - ineractive u-boot configuration
            ```console
            Zynq> setenv modeboot tftpboot
            Zynq> setenv serverip <tftp server ip>
            Zynq> setenv ipaddr <zynq ip>
            Zynq> setenv modeboot tftpboot
            Zynq> setenv kernel_image image.ub
            Zynq> setenv kernel_load_addr 0x1400000
            Zynq> setenv fpga_image system.bit
            Zynq> setenv fpga_load_addr 0x10000000
            Zynq> setenv fpga_size 0x1500000
            Zynq> setenv tftp_load "echo Booting Linux using TFTP... && fpga info 0 && tftpboot ${fpga_load_address} ${serverip}:${fpga_image} && fpga loadb 0 ${fpga_load_addr} ${fpga_size} && tftpboot ${kernel_load_addr} ${serverip}:image.ub && bootm ${kernel_load_addr}"
            Zynq> run tftp_load

        - boot script method

            - place configuration above into tftp_boot.script and compile into boot.scr.uimg (script compiler available in u-boot-tools package)

                ```console
                host:os$ mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n "tftp boot script" -d tftp_boot.script boot.scr.uimg
                ```

            -place boot.scr.uimg in boot partition

## nfs mount rootfs

- install nfs-kernel-server package and configure server per https://ubuntu.com/server/docs/service-nfs

    - exports file and directory configuration

        ```console
        nfs_server$ ll / | grep export
        drwxrwxrwx   5 root  root ... export/
        nfs_server$ ll /export | grep zybo_z7
        nfs_server$ ll /export | grep zybo_z7
        drwxrwxrwx  2 nobody nogroup ... zybo_z7/
        ```

        ```console
        host: cat /etc/exports
        ...
        /export                  *(rw,fsid=0,insecure,no_subtree_check,async)
        /export/zybo_z7           *(rw,sync,insecure,no_root_squash,no_subtree_check)
        ...
        ...

    - mount the NFS exported directories

        ```console
        nfs_server$ sudo exportfs -ra
        ```

    - restart the nfs server

        ```console
        nfs_server$ sudo systemctl restart nfs-kernel-server
        ```

    - verify the export configuration

        ```console
        nfs_server$ sudo exportfs
        ...
        /export/zybo_z7
                    <world>
        ...
        ```

    - install rootfs in nfs server exported /export/zybo_z7 directory

        ```console
        nfs_server$ sudo tar --no-overwrite-dir -xzvf <path to rootfs>/rootfs.tar.gz -C /export/zybo_z7
        nfs_server$ ll /export/zybo_z7/
        total 76
        drwxrwxrwx 18 nobody nogroup 4096 Mar  9  2018 ./
        drwxrwxrwx  6 root   root    4096 Nov 27 10:21 ../
        drwxr-xr-x  2 root   root    4096 Mar  9  2018 bin/
        drwxr-xr-x  3 root   root    4096 Mar  9  2018 boot/
        drwxr-xr-x  2 root   root    4096 Mar  9  2018 dev/
        drwxr-xr-x 39 root   root    4096 Mar  9  2018 etc/
        drwxr-xr-x  4 root   root    4096 Mar  9  2018 home/
        drwxr-xr-x  8 root   root    4096 Mar  9  2018 lib/
        -rw-r--r--  1 root   root       5 Mar  9  2018 log_lock.pid
        drwxr-xr-x  2 root   root    4096 Mar  9  2018 media/
        drwxr-xr-x  2 root   root    4096 Mar  9  2018 mnt/
        dr-xr-xr-x  2 root   root    4096 Mar  9  2018 proc/
        drwxr-xr-x  2 root   root    4096 Mar  9  2018 run/
        drwxr-xr-x  2 root   root    4096 Mar  9  2018 sbin/
        drwxr-xr-x  2 root   root    4096 Mar  9  2018 srv/
        dr-xr-xr-x  2 root   root    4096 Mar  9  2018 sys/
        drwxrwxrwt  2 root   root    4096 Mar  9  2018 tmp/
        drwxr-xr-x 11 root   root    4096 Mar  9  2018 usr/
        drwxr-xr-x  9 root   root    4096 Mar  9  2018 var/
        ```

- configure target u-boot for rootfs nfs mounting

    ```console
    Zynq>
    setenv nfs_root_dir /export/zybo_z7
    setenv serverip 192.168.1.28
    setenv ipaddr 192.168.1.100
    setenv netmask 255.255.255.0
    setenv gatewayip 192.168.1.1

    setenv bootargs earlycon console=ttyPS0,115200n8 ip=$ipaddr:$serverip:$gatewayip:$netmask::eth0:off: root=/dev/nfs rootfstype=nfs nfsroot=$serverip:$nfs_root_dir,port=2049,nfsvers=4,hard,proto=tcp,nolock,rsize=1048576,wsize=1048576 rw uio_pdrv_genirq.of_id=generic-uio
    ```


