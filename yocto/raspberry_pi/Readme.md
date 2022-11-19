# Yocto Builds

## Yocto Version

- Kirkstone
    - yocto version 4.0.4 (Sept 2022)
    - Long Term Support (minimum Apr. 2024)
    - https://www.yoctoproject.org/software-overview/downloads/

## ess-distro Features

- based off core-image-base.bb
- overlay-etc: overlayfs applied to rfs /etc
- i2cdev/spidev
- debug uart
- systemd
- vim
- tzdata
- ess-canonical-app - generic user space application
- python3
- flask application - web browser target communication
- extended root env via systemd script
- modified /etc/profile defaults for newly created user accounts
- kernel config modification (defconfig and cfg file based)
- u-boot config modification (cfg file based)
- u-boot patching
- qt5
- host qtcreater support

## Build Environment

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
            host:/bsp-odds-and-ends/yocto/raspberry_pi$ ./run-poky-image.sh
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
            pokyuser:/workdir$ export BB_NUMBER_THREADS=10
            ```
        - PARALLEL_MAKE -j option for make. Set same as BB_NUMBER_THREADS (should not be set > 20).
            ```console
            pokyuser:/workdir$ export PARALLEL_MAKE=-j10
            ```

## Custom Distro

- **ess-distro** distro recipe **ess-image** on machine **raspberrypi4-64-ess**

- create custom machine layer

    ```console
    pokyuser:/workdir/bsp/sources$ bitbake-layers create-layer meta-ess
    ```

- machine sources/meta-ess/conf/machine/***raspberrypi4-64-ess.conf*** that configures the platform

    - default hostname
    - console shell
    - debug serial console
    - spidev / i2cdev
    - overlayfs over /etc

- distro sources/meta-ess/conf/distro/***ess-distro.conf***

    - systemd, resolved
    - wpa_supplicant
    - remove unnecessary packages
    - default timezone

- image recipe under meta-ess/recipes-core/image/ ***ess-images.bb***

    - i2c-tools
    - vim
    - timezone configuration
    - extended linux utilities
    - overlayfs over /etc
    - dropbear ssh server
    - python3
    - flash server
    - qt5 demos

- custom recipe (extensions)

    - recipes-apps
        - ess-canonical-app :
            - makefile based compile
            - default and optional features
            - optional feature can be enabled in distro.conf or local.conf
        - flash-ess-application :
            - configures a flask server

    - recipes-core/systemd-conf :
        - systemd network configuration
        - install network files for various interfaces

    - recipes-connectivity/wpa-supplicant :
        - SYSTEMD_AUTO_ENABLE'ing the service in did not created the required systemd symlink
        - manually create symlink in recipe

    - recipes-core
        - base-files :
            - default skel .bashrc modified
        - images
            - ess-image.bb added
        - systemd
            - root shell env modified
            - added systemd network files

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

- update build-rpi-ess/conf/local.conf with new machine name

    ```console
    MACHINE = "raspberrypi4-64-ess"
    ```

- kernel config method examples

    - complete defconfig file replacement

        - the default config file for this the rpi4 64bit kernel is located in workspace/sources/linux-raspberrypi/arch/arm64

        - one can override the upstream kernel defconfig file. the general idea is to build the kernel once, and either directly rename the created .config file as defconfig and perform manual edits on it, or run menuconfig to create a .config.new file and rename that as defconfig.

        - this example will use devtool to create a workspace outside the yocto build directory tree structure for sandbox development. a sandbox is created containing to linux kernel recipe sources/meta-raspberrypi/recipes-kernel/linux/linux-raspberrypi-5.15.bb recipe.

        - devtool the kernel recipe
            ```console
            pokyuser:/workdir/bsp/build-rpi-ess$ devtool modify linux-raspberrypi
            ...
            INFO: Recipe linux-raspberrypi now set up to build from /workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi
            pokyuser:/workdir/bsp/build-rpi-ess$ cd ./workspace/sources/linux-raspberrypi
            ```

        - bitbake the kernel menuconfig (bitbake menuconfig supported for both kernel and busybox)
            ```console
            pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi$ bitbake linux-raspberrypi -c menuconfig
            ...
            ````

            - select Kernel hacking > Memory Debugging :  "Stack utilization instrumentation" to configure CONFIG_DEBUG_STACK_USAGE as set, save out of the menuconfig and verify configuration change
                ```console
                pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi$ cat .config.baseline | grep CONFIG_DEBUG_STACK_USAGE
                # CONFIG_DEBUG_STACK_USAGE is not set

                pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi$ cat .config.new | grep CONFIG_DEBUG_STACK_USAGE
                CONFIG_DEBUG_STACK_USAGE=y
                ```

        - the diffconfig utility can also be used to create a fragment file showing differences between the old and new kernel configs
            ```console
            pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi$ bitbake linux-raspberrypi -c diffconfig
            ...
            Config fragment has been dumped into:
            /workdir/bsp/build-rpi-ess/tmp/work/raspberrypi4_64_ess-poky-linux/linux-raspberrypi/1_5.15.34+git999-r0/fragment.cfg

            pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi$ cat /workdir/bsp/build-rpi-ess/tmp/work/raspberrypi4_64_ess-poky-linux/linux-raspberrypi/1_5.15.34+git999-r0/fragment.cfg
            CONFIG_DEBUG_STACK_USAGE=y
            ```

        - create bbappend file for linux kernel with the defconfig file mentioned above as the source target

            ```console
            pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi$ cp .config.new /workdir/bsp/sources/meta-ess/recipes-kernel/linux/linux-raspberrypi/defconfig

            pokyuser:/workdir/bsp/build-rpi-ess$ cat ../sources/meta-ess/recipes-kernel/linux/linux-raspberrypi_%.bbappend

            FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
            SRC_URI += "file://defconfig"
            unset KBUILD_DEFCONFIG
            KCONFIG_MODE = "alldefconfig"
            ```

    - fragment configuration change

        - devtool the kernel recipe
            ```console
            pokyuser:/workdir/bsp/build-rpi-ess$ devtool modify linux-raspberrypi
            ...
            INFO: Recipe linux-raspberrypi now set up to build from /workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi
            pokyuser:/workdir/bsp/build-rpi-ess$ cd ./workspace/sources/linux-raspberrypi
            ```

        - bitbake the kernel menuconfig (bitbake menuconfig supported for both kernel and busybox)
            ```console
            pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi$ bitbake linux-raspberrypi -c menuconfig
            ...
            ````

            - select Kernel hacking > Memory Debugging :  "Kernel memory leak detector" to configure
            CONFIG_DEBUG_KMEMLEAK as set, save out of the menuconfig and verify configuration change

        - use the diffconfig utility to create a fragment file showing differences between the old and new kernel configs
            ```console
            pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi$ bitbake linux-raspberrypi -c diffconfig
            ...
            Config fragment has been dumped into:
            /workdir/bsp/build-rpi-ess/tmp/work/raspberrypi4_64_ess-poky-linux/linux-raspberrypi/1_5.15.34+git999-r0/fragment.cfg

            pokyuser@a69dd9d8a512:/workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi$ cat /workdir/bsp/build-rpi-ess/tmp/work/raspberrypi4_64_ess-poky-linux/linux-raspberrypi/1_5.15.34+git999-r0/fragment.cfg
            CONFIG_DEBUG_KMEMLEAK=y
            CONFIG_DEBUG_KMEMLEAK_MEM_POOL_SIZE=16000
            # CONFIG_DEBUG_KMEMLEAK_TEST is not set
            # CONFIG_DEBUG_KMEMLEAK_DEFAULT_OFF is not set
            CONFIG_DEBUG_KMEMLEAK_AUTO_SCAN=y
            ```

        - copy the kernel config fragment in the bbappend recipe created above renaming to 01_kernel_memory_dbg.cfg

        - update linux-raspberrypi_%.bbappend to include 01_kernel_memory_dbg.cfg in SRC_URI. cfg modification are applied after the defconfig has been applied

- u-boot config modification

    - git recipe requires git ssh ... see docker image invocation as one example to provide credentials

    - devtool u-boot source with current patches
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess$ devtool modify u-boot
        ...

    - menuconfig
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/u-boot$ bitbake u-boot -c menuconfig
        ```

        - select i2c config options
            ```console
            config - U-Boot 2022.01 Configuration
            > Command line interface > Device access commands > i2c
            ```

    - use the diffconfig utility to create a fragment file showing differences between the old and new kernel configs
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi$ bitbake u-boot -c diffconfig
        ...
        Config fragment has been dumped into:
        /workdir/bsp/build-rpi-ess/tmp/work/raspberrypi4_64_ess-poky-linux/u-boot/1_2022.01-r0/fragment.cfg
        ```

    - use fragment in bbappend, see raspberry_pi/bsp/sources/meta-ess/recipes-bsp/u-boot/u-boot_%.bbappend usage of 01_enable_i2c_cmd.cfg fragment

- u-boot patch creation

    - devtool u-boot source with current patches
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess$ devtool modify u-boot
        ```

    - modify version command processing code cmd/version.c
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/u-boot$ git status
        On branch devtool
        Changes not staged for commit:
        (use "git add <file>..." to update what will be committed)
        (use "git checkout -- <file>..." to discard changes in working directory)

                modified:   cmd/version.c
        ```

    - git add and commit cmd/version.c
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/u-boot$ git add cmd/version.c
        pokyuser:/workdir/bsp/build-rpi-ess/workspace/sources/u-boot$ git commit -m "patch u-boot version command"
        ```

    - several devtool means to generate layer recipes ... this example manually create diff from commit to apply to exists u-boot bbappend
        ```console
        $ git show HEAD > patch0001_modify_version_command.patch
        ```

    - use this patch in u-boot bbappend

    - verify patch
        ```console
        U-Boot> version
        ...
        ess patch example
        ```

- dts modifications

    - patch existing dts node

        - devtool u-boot source with current patches
            ```console
            pokyuser:/workdir/bsp/build-rpi-ess$ devtool modify linux-raspberrypi
            ```

        - edit model in /linux-raspberrypi/arch/arm/boot/dts/bcm2711-rpi-4-b.dts, git add and commit

    - manually create diff from commit to apply to existing meta-ess/recipes-kernel/linux/linux-raspberrypi_%.bbappend
        ```console
        $ git show HEAD > 0001_modify_dts_model_parameter.patch
        ```

    - verify dts modification

        - by reversing compiling build dtb
            ```console
            /tmp/deploy/images/raspberrypi4-64-ess$ dtc -I dtb -O dts bcm2711-rpi-4-b.dtb -o /tmp/reverse_compiled.dts
            ```

        - by target image inspection
            ```console
            root@ess-hostname:~# cat /proc/device-tree/ess_patch
            ess patch
            ```

    - dts files
        ```console
        bcm2711-rpi-4-b.dts
            bcm2711.dtsi
                bcm283x.dtsi
                    <dt-bindings/pinctrl/bcm2835.h>
                    <dt-bindings/clock/bcm2835.h>
                    <dt-bindings/clock/bcm2835-aux.h>
                    <dt-bindings/gpio/gpio.h>
                    <dt-bindings/interrupt-controller/irq.h>
                    <dt-bindings/soc/bcm2835-pm.h>
                <dt-bindings/interrupt-controller/arm-gic.h>
                <dt-bindings/soc/bcm2835-pm.h>
            bcm2711-rpi.dtsi
                bcm2835-rpi.dtsi
                    <dt-bindings/power/raspberrypi-power.h>
                <dt-bindings/interrupt-controller/arm-gic.h>
                <dt-bindings/soc/bcm2835-pm.h>
            bcm270x.dtsi
                <dt-bindings/power/raspberrypi-power.h>
            bcm271x-rpi-bt.dtsi
            bcm2711-rpi-ds.dtsi
                bcm270x-rpi.dtsi
            bcm283x-rpi-csi1-2lane.dtsi
            bcm283x-rpi-i2c0mux_0_44.dtsi
        ```

- qt5 configurations

    - repos<br>
        https://github.com/meta-qt5/meta-qt5/tree/jansa/kirkstone<br>
        https://code.qt.io/cgit/yocto/meta-qt6.git/log/

    - qt demo applications<br>
        cinematicexperience, qt5everywheredemo

    - optional qt package group<br>
        explicitly installed packages install required qt dependency elements<br>
        based off meta-qt5/recipes-qt/packagegroups/packagegroup-qt5-toolchain-target.bb

    - qt5 build configuration
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess$ cat tmp/work/cortexa72-poky-linux/qtbase/5.15.3+gitAUTOINC+c95f96550f-r0/build/config.summary
        ```

    - plugin platform dll's
        ```console
        root@ess-hostname:~#  ls -1 /usr/lib/plugins/platforms
        libqeglfs.so
        libqlinuxfb.so
        libqminimal.so
        libqminimalegl.so
        libqoffscreen.so
        libqvnc.so
        ```

    - systemd auto start service<br>
        see meta-ess/recipes-core/systemd/systemd-conf_%.bbappend<br>
        installs /lib/systemd/system/qt_app.service<br>
        installs start/stop script /usr/sbin/qt_app.sh

    - load testing<br>
        platform egls runs /usr/share/qt5everywheredemo-1.0/QtDemo at about 25% CPU load<br>
        platform linuxfb runs /usr/share/qt5everywheredemo-1.0/QtDemo at about 70% CPU load

    - debugging
        - prior to qt app launch
            ```console
            export QT_DEBUG_PLUGINS=1
            ```

## Image Bake

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

## SD Card Image Flashing

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

## Yocto SDK Creation

- build sdk
    ```console
    pokyuser:/workdir/bsp/build-rpi-ess$ bitbake -c populate_sdk ess-image
    ```

- install sdk
    ```console
    host$ ./tmp/deploy/sdk/poky-glibc-x86_64-ess-image-cortexa72-raspberrypi4-64-ess-toolchain-1.0.0.sh
    ```

- run following to configure sdk environment at a specified location
    ```console
    . <path to installed sdk>/environment-setup-cortexa72-poky-linux
    ```

## qtcreator project

### fixed target IP for deployment

- edit /etc/systemd/network/wlan.network to something like:
    ```console
    [Match]
    Name=eth*
    KernelCommandLine=!nfsroot

    [Network]
    DNS=8.8.8.8
    Address=192.168.1.6
    Gateway=192.168.1.1
    ```

- ssh-keygen for public/private key pair to used for deployment
    ```console
    host$ ls -1  ~/.ssh/ | grep rpi
    id_rsa_rpi
    id_rsa_rpi.pub
    ```

## meta-toolchain-qt5 SDK Creation

- build sdk
    ```console
    pokyuser:/workdir/bsp/build-rpi-ess$ bitbake meta-toolchain-qt5
    ```

- install sdk
    ```console
    host$ ./tmp/deploy/sdk/poky-glibc-x86_64-meta-toolchain-qt5-cortexa72-raspberrypi4-64-ess-toolchain-1.0.0.sh
    ```

- run following to configure sdk environment at a specified location
    ```console
    . <path to installed meta-toolchain-qt5 sdk>/environment-setup-cortexa72-poky-linux
    ```

## qtcreator Configuration

- identify Qt version running on target
    ```console
    root@ess-hostname:~# qmake --version
    QMake version 3.1
    Using Qt version 5.15.3 in /usr/lib
    ```

- configure Qt target device in qtcreator

    ``` console
    File > New File or Project ...

    Project Name: ess-sdk
    Build System: qmake
    Minimal Required Qt Version: 5.15

    Kit Selection > Manage > Add
        ess-yocto
        Device TYpe: Generic Linux Device
        Device > Manage > Add >Devices > Add > Generic Linux Device > Start Wizard
            ess-rpi / <ip> / root
            > next
            select private key file (rsa)
            > Deploy Public Key
            > Finish

    ess-rpi device now configured
    ```

- configure compilers

## Image Testing

- qt5 testing
    ```console
    root@ess-hostname:~# qt5-opengles2-test -platform eglfs
    root@ess-hostname:~# /usr/share/qt5everywheredemo-1.0/QtDemo -platform eglfs
    root@ess-hostname:~# qmlscene /usr/share/qt5ledscreen-1.0/example_billboard.qml -platform eglfs
    root@ess-hostname:~# qmlscene /usr/share/qt5ledscreen-1.0/example_combo.qml -platform eglfs
    root@ess-hostname:~# qmlscene /usr/share/qt5ledscreen-1.0/example_hello.qml -platform eglfs
    root@ess-hostname:~# /usr/share/qt5nmapcarousedemo-1.0/Qt5_NMap_CarouselDemo -platform eglfs
    root@ess-hostname:~# /usr/share/qt5nmapper-1.0/Qt5_NMapper -platform eglfs
    root@ess-hostname:~# qmlscene /usr/share/quitindicators-1.0.1/qml/main.qml -platform eglfs
    root@ess-hostname:~# qmlscene /usr/share/qtsmarthome-1.0.1/qml/main.qml -platform eglfs
    ```

- verify flask server
    - place rpi on network with eth0 or wlan
        - verify service is running and logging
        ```console
        root@ess-hostname:~# systemctl status ess-flask-app
        * ess-flask-app.service - Flash ESS application
            Loaded: loaded (8;;file://ess-hostname/lib/systemd/system/ess-flask-app.service/lib/systemd/system/ess-flask-app)
            Active: active (running) since Thu 2022-04-28 11:07:00 PDT; 2min 45s ago
        Main PID: 259 (python3)
            Tasks: 4 (limit: 1828)
            CGroup: /system.slice/ess-flask-appservice
                    `- 259 python3 /usr/bin/ess-flask-app.py

        root@ess-hostname:~# journalctl -u  ess-flask-app | grep Flask
        Apr 28 11:07:02 ess-hostname ess-flask-app.py[259]:  * Serving Flask app 'ess-flask-app' (lazy loading)
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
    - wpa_supplicant.conf file ssid and psk configuration
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
    $ i2cdetect -l
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

    - [systemd](/docs_shared/systemd.md) usage
    - [journald](/docs_shared/journald.md) usage

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

- verify stack usage in kernel log
    ```console
    root@ess-hostname:~# journalctl -b | grep "used greatest stack depth"
    Apr 28 10:42:27 ess-hostname kernel: cryptomgr_test (44) used greatest stack depth: 15232 bytes left
    Apr 28 10:42:27 ess-hostname kernel: cryptomgr_test (45) used greatest stack depth: 14880 bytes left
    ...
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

- verify kernel memory leak detection fs exposure
    ```console
    root@ess-hostname:~# ls /sys/kernel/debug/kmemleak
    /sys/kernel/debug/kmemleak
    ```

- test qemu (core-image-minimal) builds
    ```console
    pokyuser:/workdir/bsp/build$ runqemu qemux86-64 core-image-minimal slirp nographic
    ```
    - to exit qemu console enter Ctrl-A (press and release) followed by x

## ... Other Bitbake Operations

- list all recipes available
    ```console
    pokyuser:/workdir/bsp/build$ bitbake -s
    ```
- list all recipe tasks for specific recipe
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
    pokyuser:/workdir/bsp/build-rpi-ess$ bitbake-layers show-recipes vim
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
    pokyuser:/workdir/bsp/build-rpi-ess$ bitbake -e | grep "^GCCVERSION="
GCCVERSION="11.%"
    ```
- quick return to build directory
    ```console
    pokyuser:/workdir/bsp/build-rpi-ess/tmp/work/raspberrypi4_64_ess-poky-linux/linux-raspberrypi/1_5.15.34+gitAUTOINC+e1b976ee4f_0086da6acd-r0$ cd $BUILDDIR/
    pokyuser:/workdir/bsp/build-rpi-ess$
    ```
- devtool
    - list workspaces
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess$ devtool status
        NOTE: Starting bitbake server...
        linux-raspberrypi: /workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi
        ```

- oe-pkgdata-util
    - list recipe files installed on target
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess$ oe-pkgdata-util list-pkg-files <recipe name>
        ```

## Boot Sequence

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

## References

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

### qt references

#### qt5/6 in linux
https://doc.qt.io/qt-5/embedded-linux.html
https://doc.qt.io/qt-6/embedded-linux.html

#### qt5/6 platform abstraction
https://doc.qt.io/qt-5/qpa.html
##### graphical backend managers
    https://doc.qt.io/qt-5/embedded-linux.html#embedded-eglfs
    https://doc.qt.io/qt-5/embedded-linux.html#linuxfb
        - fbdev is a bit long in the tooth
        - consider dumb buffers for simple renders instead
    https://doc.qt.io/qt-6.2/qpaintdevice.html (xcb x11)
    https://doc.qt.io/qt-5/linux.html (linux x11)
https://doc.qt.io/qt-6/qpa.html