# Yocto Builds

## yocto version

- Kirkstone
    - yocto version 4.0.4 (Sept 2022)
    - Long Term Support (minimum Apr. 2024)
    - https://www.yoctoproject.org/software-overview/downloads/

## ess-distro features

- based off core-image-base.bb
- overlay-etc: overlayfs applied to rfs /etc
- i2cdev/spidev
- debug uart
- systemd
- vim
- tzdata
- ess-canonical-app - generic user space application
- python3

## yocto layers

- clone this repo
    ```console
    $ git clone git@github.com:forevers/bsp-odds-and-ends.git
    $ cd bsp-odds-and-ends/yocto/raspberry_pi
    ```

- clone kirkstone layers (TODO consider git subrepo)
    ```console
    $ ./clone-yocto-kirkstone.sh ./bsp
    ```

- interactively run CROss PlatformS (CROPS) docker container

    - command line invocation

        - https://github.com/crops/poky-container
            ```console
            $ docker run --rm -it -v ${PWD}:/workdir crops/poky --workdir=/workdir

            pokyuser:/workdir$
            ```
            or

        - script invocation
            ```console
            $ ./run-poky-image.sh
            ```

    - pretty old Ubuntu version used by crops/poky container
        ```console
        pokyuser:/workdir$ cat /etc/lsb-release
        DISTRIB_ID=Ubuntu
        DISTRIB_RELEASE=18.04
        DISTRIB_CODENAME=bionic
        DISTRIB_DESCRIPTION="Ubuntu 18.04.6 LTS"
        ```

    - to limit processor resources yocto uses limit threading resources as follows, else yocto acquires them all

        - BB_NUMBER_THREADS can be set in local.conf or directly exported in docker shell. Can be up to twice number of cpu cores (should not be set > 20).
            ```console
            pokyuser:/workdir$ export BB_NUMBER_THREADS=12
            ```
        - PARALLEL_MAKE -j option for make. Set same as BB_NUMBER_THREADS (should not be set > 20).
            ```console
            pokyuser:/workdir$ export PARALLEL_MAKE=-j12
            ```

## **ess-distro** distro recipe **ess-image** on machine **raspberrypi4-64-ess**

- create custom machine layer

    ```console
    pokyuser:/workdir/bsp/sources$ bitbake-layers create-layer meta-ess
    ```

- create new machine sources/meta-ess/conf/machine/**raspberrypi4-64-ess.conf** that configures the platform

    ```console
    # override the default /etc/hostname (machine name by default)
    hostname:pn-base-files = "ess-hostname"

    # enable debug uart
    ENABLE_UART = "1"

    # enable spi-dev nodes
    ENABLE_SPI_BUS = "1"

    # enable i2c-dev nodes
    ENABLE_I2C = "1"
    # auto-load I2C kernel modules
    KERNEL_MODULE_AUTOLOAD:rpi += "i2c-dev"

    # ess-image.bb specifies ovelayfs-etc IMAGE_FEATURES
    #   creates /etc overlayfs in specified mount
    #   requires ext4 sd card parition for rw /etc data
    OVERLAYFS_ETC_MOUNT_POINT ?= "/data"
    OVERLAYFS_ETC_FSTYPE ?= "ext4"
    OVERLAYFS_ETC_DEVICE ?= "/dev/mmcblk0p3"
    ```

- create new distro sources/meta-ess/conf/distro/**ess-distro.conf**

    - distro configure the service manager as systemd vs default sysv

        ```console
        DISTRO_FEATURES:append = " systemd"
        VIRTUAL-RUNTIME_init_manager = "systemd"
        ```

        ``` support wifi credential application
        DISTRO_FEATURES:append = " wpa_supplicant"
        ```

    - reducing distro feature list in **ess-distro.conf**

        ```console
        DISTRO_FEATURES:remove = "pcmcia"
        ```

    - default timezone

        ```console
        DEFAULT_TIMEZONE = "America/Los_Angeles"
        ```

- create new **ess-images.bb** recipe under meta-ess/recipes-core/image

    - add i2c-tools to image: modify ess-image.bb (https://i2c.wiki.kernel.org/index.php/I2C_Tools)
        ```console
        IMAGE_INSTALL:append = " i2c-tools"
        ```

    - add vim editor
        - modify ess-image.bb ... note: IMAGE_INSTALL += usage, the symbol must exist already for += vs "append", :prepend also exists

            ```console
            IMAGE_INSTALL:append = "vim"
            ```

    - **overlayfs-etc** allows /etc modifications over a ro rootfs
        ```console
        # see raspberrypi4-64-ess.conf for machine conf parts of overlayfs
        IMAGE_FEATURES:append = " overlayfs-etc"
        ```

    - timezone config
        ```console
        # timezone configuration
        IMAGE_INSTALL:append = " tzdata"
        ```

    - generic user space app
        ```console
        IMAGE_INSTALL:append = " ess-canonical-app"
        ```

    - rootfs task extension example
        ```console
        do_rootfs_append() {
            ...
        }
        ```

- custom recipe (extensions)

    - recipes-apps
        - ess-canonical-app :
            - demonstrates bb file configuration
        - flash-ess-application :
            - configures a flask server

    - recipes-core/systemd-conf :
        - systemd network configuration
        - install network files for various interfaces

    - recipes-connectivity/wpa-supplicant :
        - SYSTEMD_AUTO_ENABLE'ing the service in did not created the required systemd symlink
        - manually create symlink in recipe

- source yocto build environment script targeting "./build-rpi-ess" destination directory and create ./local.conf if non-existent

    ```console
    pokyuser:/workdir$ $ cd ./bsp
    pokyuser:/workdir/bsp$ . ./sources/poky/oe-init-build-env build-rpi-ess
    ...
    pokyuser:/workdir/bsp/build-rpi-ess$
    ```

- edit build-rpi/conf/**local.conf** to contain (TODO find proper export configuration)

    ```console
    - SSTATE_DIR ?= "/workdir/cache/sstate"
    - DL_DIR ?= "/workdir/cache/downloads"
    ```

- update bblayers.conf BBLAYERS

    ```console
    /workdir/bsp/sources/meta-raspberrypi \
    /workdir/bsp/sources/meta-openembedded/meta-oe \
    /workdir/bsp/sources/meta-ess \
    ```

- update layer.conf with new machine name

    ```console
    MACHINE = "raspberrypi4-64-ess"
    ```

- bake an **ess-image image**, takes about 50 minutes on 12 core system

    ```console
    pokyuser:/workdir/bsp/build-rpi-ess$ time bitbake ess-image
    ```

- resulting images (wic file format is used for flashing sdcard)

    ```console
    pokyuser:/workdir/bsp/build-rpi-ess$ ls tmp/deploy/images/raspberrypi4-64-ess
    ss-image-raspberrypi4-64-ess.wic.bz2
    ```

- device tree

    - a composite dts can be created by reverse compiling the dtb built image

        ```console
        /tmp/deploy/images/raspberrypi4-64-ess$ dtc -I dtb -O dts bcm2711-rpi-4-b.dtb -o /tmp/reverse_compiled.dts
        ```
    -  device tree can be inspected on target under /proc/device-tree

- rootfs location: build-rpi-ess/tmp/work/raspberrypi4_64_ess-poky-linux/ess-image/1.0-r0/rootfs

## SD card image flashing

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

    - create ext4 for overlayfs usage

        - fdisk a new partition
            ```console
            host$ fdisk /dev/sdc
            ```
        - configure ext4 in partition
            ```console
            $ sudo mkfs.ext4 -L data /dev/sdc3
            ```

## image testing

- verify flask server
    - place rpi on network with eth0 or wlan
        - verify service is running and logging
        ```console
        root@ess-hostname:~# systemctl status flask-ess-application
        * flask-ess-application.service - Flash ESS application
            Loaded: loaded (8;;file://ess-hostname/lib/systemd/system/flask-ess-application.service/lib/systemd/system/flask-ess-applicat)
            Active: active (running) since Thu 2022-04-28 11:07:00 PDT; 2min 45s ago
        Main PID: 259 (python3)
            Tasks: 4 (limit: 1828)
            CGroup: /system.slice/flask-ess-application.service
                    `- 259 python3 /usr/bin/flask-ess-application.py

        root@ess-hostname:~# journalctl -u  flask-ess-application | grep Flask
        Apr 28 11:07:02 ess-hostname flask-ess-application.py[259]:  * Serving Flask app 'flask-ess-application' (lazy loading)
        ...
        ...
        ```
        - in a browser enter the following address 192.168.1.25:5000 and verify script returning expected info
        ```console
        Linux ess-hostname 5.15.34-v8 #1 SMP PREEMPT Tue Apr 19 19:21:26 UTC 2022 aarch64 GNU/Linux
        ```

- wifi test
    - networkinterface wlan0 configuration
        ```console
        root@ess-hostname:~# cat /etc/network/interfaces
        ...
        # Wireless interfaces
        iface wlan0 inet dhcp
        wireless_mode managed
        wireless_essid any
        wpa-driver wext
        wpa-conf /etc/wpa_supplicant.conf
        ```
    - wpa_supplicant.conf file configuration
        ```console
        root@ess-hostname:~# cat /etc/wpa_supplicant/wpa_supplicant@wlan0.conf
        ctrl_interface=/var/run/wpa_supplicant
        ctrl_interface_group=0
        update_config=1

        network={
                ssid="<network name here>"
                psk="<password here>"
                proto=RSN
                key_mgmt=WPA-PSK
                pairwise=CCMP
                auth_alg=OPEN
        }
        root@ess-hostname:~# ifup -v wlan0
        ```

    - ping from host

    - auto start wifi
        ```console
        root@ess-hostname:~# systemctl enable wpa_supplicant@wlan0.conf
        ```
        creates a symlink
        ```console
        root@ess-hostname:~# ls -l /etc/systemd/system/multi-user.target.wants/
        ...
        lrwxrwxrwx    1 root     root            43 Apr 28 15:41 wpa_supplicant@wlan0.conf.service -> /lib/systemd/system/wpa_supplicant@.service
        ```

- ssh server test
    - boot target
    - identify ip address
    - on target ifup <address> until networkd is autostarting it
    - ssh root@<ip address>

- test i2c tools

    ```console
    $ i2c
    $ ls /dev/i2c*
    $ i2cdetect
    ```

    - i2c configuration resides in cat /boot/config.txt

        ```console
        root@ess-hostname:~# cat /boot/config.txt | grep
        ...
        dtparam=i2c1=on
        dtparam=i2c_arm=on
        ```

- verify machine name by /dev/hostname and console prompt

    ```console
    root@ess-hostname:~# cat /etc/hostname
    ess-hostname
    ```

- verify systemd installation

    - list currently running services
        ```console
            root@ess-hostname:~# systemctl --type=service
            ```

    - list active units
        ```console
        root@ess-hostname:~# systemctl list-units
        ```

    - list all units
        ```console
        root@ess-hostname:~# systemctl list-units --all
        ```

    - list service dependencies
        ```console
        root@ess-hostname:~# systemctl list-dependencies systemd-networkd.service
        root@ess-hostname:~# systemctl list-dependencies -all systemd-networkd.service
        ```

    - query service status
        ```console
        root@ess-hostname:~# systemctl list-units | grep service
        root@ess-hostname:~# systemctl status systemd-networkd.service
        ```

    - query service config file
        ```console
        root@ess-hostname:~# systemctl cat systemd-networkd.service
        ```

    - edit service config rile
        ```console
            root@ess-hostname:~# systemctl edit -full systemd-networkd.service
            root@ess-hostname:~# systemctl edit --full systemd-networkd.service
        ```

    - query service properties
        ```console
        root@ess-hostname:~# systemctl show systemd-networkd.service
        ```

    - inspect systemd targets (similar to sysv run levels)

        - get boot target
            ```console
            root@ess-hostname:~# systemctl get-default
            ```

        - set a new boot target
            ```console
            root@ess-hostname:~# systemctl set-default <a new target>
            ```

        - list all possible targets. note sysv runlevel targets aliased to systemd targets.
            ```console
            root@ess-hostname:~# systemctl list-unit-files --type=target
            ```

        - list target dependencies
            ```console
            root@ess-hostname:~# systemctl list-dependencies multi-user.target
            ```

        - list target dependencies
            ```console
            root@ess-hostname:~# systemctl poweroff
            root@ess-hostname:~# systemctl reboot
            root@ess-hostname:~# systemctl rescue
            ```

    - restart service (i.e. systemd-networkd.service after conf edits)
        ```console
        root@ess-hostname:~# systemctl restart systemd-networkd.service
        ```

    - verify networkctl device listing
        ```console
        root@ess-hostname:~# networkctl list
        IDX LINK  TYPE     OPERATIONAL SETUP
        1 lo    loopback carrier     unmanaged
        2 eth0  ether    no-carrier  configuring
        3 wlan0 wlan     no-carrier  configuring
        ```

- verify systemd journald installation

    - journald log file location
        ```console
        root@ess-hostname:~# cat /run/log/journal/de0c16ccdb00407ab5ffdf0ac63d5e5b/system.journal
        ```

    - check journald file persistence configuration
        ```console
        root@ess-hostname:~# cat /etc/systemd/journald.conf | grep Storage
        ```

    - entire log
        ```console
        root@ess-hostname:~# journalctl
        ```

    - current boot only log
        ```console
        root@ess-hostname:~# journalctl -b
        ```

    - current boot only kernel log
        ```console
        root@ess-hostname:~# journalctl -k -b
        ```

    - logs specific to a service
        ```console
        root@ess-hostname:~# journalctl -u systemd-networkd.service
        ```

- verify /etc overlayfs-etc
    ```console
    root@ess-hostname:~# ls -l /data/overlay-etc/work/
    d---------    2 root     root          4096 Jan  1  1970 work
    root@ess-hostname:~# ls -l /data/overlay-etc/upper/
    -rw-r--r--    1 root     root           695 Apr 28 17:42 group
    -rw-r--r--    1 root     root           681 Mar  9  2018 group-
    -r--------    1 root     root           582 Apr 28 17:42 gshadow
    -r--------    1 root     root           570 Mar  9  2018 gshadow-
    -rw-r--r--    1 root     root          3687 Apr 28 17:42 ld.so.cache
    -rw-r--r--    1 root     root            33 Apr 28 17:42 machine-id

    root@ess-hostname:~# echo ess-hostname-overlay > /etc/hostname
    root@ess-hostname:~# cat /etc/hostname
    ess-hostname-overlay

    root@ess-hostname:~# shutdown -r now
    ...

    root@ess-hostname-overlay:~# ls -l /data/overlay-etc/upper/
    -rw-r--r--    1 root     root           695 Apr 28 17:42 group
    -rw-r--r--    1 root     root           681 Mar  9  2018 group-
    -r--------    1 root     root           582 Apr 28 17:42 gshadow
    -r--------    1 root     root           570 Mar  9  2018 gshadow-
    -rw-r--r--    1 root     root            21 Apr 28 19:37 hostname
    -rw-r--r--    1 root     root          3687 Apr 28 17:42 ld.so.cache
    -rw-r--r--    1 root     root            33 Apr 28 17:42 machine-id

    root@ess-hostname-overlay:~# rm -rf /data/overlay-etc/

    root@ess-hostname:~# shutdown -r now
    ...

    root@ess-hostname:~#
    ```

- verify tzdata support

    ```console
    root@ess-hostname:~# timedatectl list-timezones

    root@ess-hostname:~# timedatectl show
    Timezone=America/Los_Angeles
    LocalRTC=no
    CanNTP=yes
    NTP=yes
    NTPSynchronized=no
    TimeUSec=Thu 2022-04-28 10:43:16 PDT

    root@ess-hostname:~# timedatectl set-timezone Pacific/Tahiti
    root@ess-hostname:~# timedatectl show
    Timezone=Pacific/Tahiti
    LocalRTC=no
    CanNTP=yes
    NTP=yes
    NTPSynchronized=no
    TimeUSec=Thu 2022-04-28 07:48:31 -10

    root@ess-hostname:~# timedatectl set-timezone UTC
    root@ess-hostname:~# timedatectl show
    Timezone=UTC
    LocalRTC=no
    CanNTP=yes
    NTP=yes
    NTPSynchronized=no
    TimeUSec=Thu 2022-04-28 17:49:28 UTC
    ```

- test qemu (core-image-minimal) builds
    ```console
    pokyuser:/workdir/bsp/build$ runqemu qemux86-64 core-image-minimal slirp nographic
    ```
    - to exit qemu console enter Ctrl-A (press and release) followed by x


## other bitbake operations

- list all recipes available
    ```console
    pokyuser:/workdir/bsp/build$ bitbake -s
    ```
- list all recipe tasks
    ```console
    pokyuser:/workdir/bsp/build$ bitbake -c listtasks ess-image
    ```
- inspect image recipe MACHINE_FEATURES (hw device related)
    ```console
    pokyuser:/workdir/bsp/build$ bitbake ess-image -e | grep MACHINE_FEATURES
    ```
- inspect image recipe DISTRO_FEATURES (sw related)
    ```console
    pokyuser:/workdir/bsp/build$ bitbake ess-image -e | grep DISTRO_FEATURES
    ```
- search for location of vim recipe
    ```console
    pokyuser@187b916fc0eb:/workdir/bsp/build-rpi-ess$ bitbake-layers show-recipes vim
    ...
    === Matching recipes: ===
    vim:
    meta                 9.0.0541
    ```
- build the vim package
    ```console
    pokyuser:/workdir/bsp/build$ bitbake vim
    ```
- clean the vim package
    ```console
    pokyuser:/workdir/bsp/build$ bitbake -c clean vim
    ```
- poky license file types
    ```console
    pokyuser:/workdir/bsp/build-rpi-ess$ ls ../sources/poky/meta/files/common-licenses
    ```
- determine compiler version used by bitbake ... see sources/poky/meta/recipes-devtools/gcc
    ```console
    pokyuser@187b916fc0eb:/workdir/bsp/build-rpi-ess$ bitbake -e | grep "^GCCVERSION="
GCCVERSION="11.%"
    ```

## boot sequence

- power on
- gpu on (cpu remains off)
- gpu runs 1st stage BL from rom
- 1st stage BL reads 2nd stage BL from SD card /boot/bootcode.bin into L2 cache and execs it
- 2nd stage BP enables DRAM and loads 3rd stage BL (loader.bin .. find its location) and execs it
- 3rd stage bootloader reads GPU firmward (start.elf)
- start.elf
    - loads kernel8.img at
        - 0x8000 if disable_commandline_tags is set
        - else 0x0, whith atags at 0x100 (no dtb usage)
    - reads config.txt
    - reads cmdline.txt
    - load dtb for the rpi4 core (bcm2711-rpi-4-b.dtb) at 0x100
- init user space process started

## references

### yocto references
#### yocto project
https://www.yoctoproject.org/
https://docs.yoctoproject.org/current/
#### yocto layers
https://www.yoctoproject.org/software-overview/layers/
https://git.yoctoproject.org/meta-raspberrypi
http://layers.openembedded.org/layerindex/branch/master/layers/
#### yocto development tasks manual
https://docs.yoctoproject.org/dev-manual/start.html
#### yocto distro features
https://docs.yoctoproject.org/ref-manual/features.html#distro-features
#### yocto image features
https://docs.yoctoproject.org/ref-manual/features.html#image-features
#### yocto docker container
https://github.com/crops/docker-win-mac-docs/wiki
#### poky crops docker image
https://github.com/crops/poky-container
https://embeddeduse.com/2019/05/06/yocto-builds-with-crops-containers/
#### sdk container
https://github.com/crops/extsdk-container/blob/master/README.md
#### meta-raspberrypi docs
http://meta-raspberrypi.readthedocs.io/en/latest/
#### yoe distro
https://github.com/YoeDistro/yoe-distro
#### open source projects
https://github.com/jynik/ready-set-yocto
#### kas configuration tool (python3 based)
https://kas.readthedocs.io/en/3.1/intro.html
#### yocto common tasks
bsp/sources/poky/documentation/dev-manual/common-tasks.rst
#### overlayfs-etc IMAGE_FEATURE
https://docs.kernel.org/filesystems/overlayfs.html
#### bitbake env symbols
raspberry_pi/bsp/sources/poky/meta/conf/bitbake.conf

#### other yocto references
https://low-level.wiki/yocto/cheatsheet.html
https://elinux.org/images/3/3c/Yps2021.11-beginner.pdf
https://embeddeduse.com/2022/06/24/setting-up-yocto-projects-with-kas/
https://lancesimms.com/RaspberryPi/HackingRaspberryPi4WithYocto_Introduction.html

### raspberry pi references
#### header
https://www.raspberrypi.com/documentation/computers/os.html#gpio-and-the-40-pin-header
#### config.txt
https://www.raspberrypi.com/documentation/computers/config_txt.html
#### uarts
https://www.raspberrypi.com/documentation/computers/configuration.html#configuring-uarts
#### stacked processor numbers
https://www.raspberrypi.com/documentation/computers/processors.html

### linux references
#### systemd-networkd network manager
https://wiki.archlinux.org/title/systemd-networkd#:~:text=In%20order%20to%20connect%20to,wpa_supplicant%20or%20iwd%20is%20required.&text=If%20the%20wireless%20adapter%20has,as%20in%20a%20wired%20adapter
https://wiki.archlinux.org/title/wpa_supplicant

### flask references
https://flask.palletsprojects.com/en/2.2.x/quickstart/#a-minimal-application
https://hackersandslackers.com/flask-routes/