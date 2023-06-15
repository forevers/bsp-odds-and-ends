# ess-distro

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

    - recipes-connectivity/networkmanager :
        - ethernet and wifi under NetworkManager control
\
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

- overlayfs-etc image feature

    - see 5.82 overlayfs-etc.bbclass : '*In order to have the /etc directory in overlayfs a special handling at early boot stage is required. The idea is to supply a custom init script that mounts /etc before launching the actual init program, because the latter already requires /etc to be mounted.*'

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

        - to remove the workspace/sources/recipe
            ```
            devtool reset linux-raspberrypi
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
        ```

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

    - dts overlay
        - TODO

    - patch existing dts node

        - devtool u-boot source with current patches
            ```console
            pokyuser:/workdir/bsp/build-rpi-ess$ devtool modify linux-raspberrypi
            ```

        - edit model in /workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi/arch/arm/boot/dts/bcm2711-rpi-4-b.dts, git add and commit

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

    - generic uio driver dts patch
        - baseline defconfig overriden in this project at yocto/raspberry_pi/bsp/sources/meta-ess/recipes-kernel/linux/linux-raspberrypi/defconfig
            ```console
            CONFIG_UIO=m
            CONFIG_UIO_PDRV_GENIRQ=m
            ```

        - dts patched using devtool
            - edit model in /workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi/arch/arm/boot/dts/bcm2711-rpi-4-b.dts, git add and commit

        - create patch and copy to
            ``` console
            /workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi/arch/arm/boot/dts$ git show HEAD > 0002_add_uio_generic_driver.patch
            ```

        - copy to and modify linux_raspberrypi recipe meta-ess/recipes-kernel/linux/linux-raspberrypi_%.bbappend

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

- machine name

    ```console
    root@ess-hostname:~# cat /etc/hostname
    ess-hostname
    ```
