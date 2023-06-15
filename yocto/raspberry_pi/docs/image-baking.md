# Build Environment and Baking

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

## Image bitbake

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
        /tmp/deploy/images/raspberrypi4-64-ess$ dtc -I dtb -O dts bcm2711-rpi-4-b.dtb -o /dev/shm/reverse_compiled.dts
        ```

    -  device tree can be inspected on target under /proc/device-tree

- rootfs location: build-rpi-ess/tmp/work/raspberrypi4_64_ess-poky-linux/ess-image/1.0-r0/rootfs

- bitbake env symbols
    - raspberry_pi/bsp/sources/poky/meta/conf/bitbake.conf

## References
- [yocto docker container](https://github.com/crops/docker-win-mac-docs/wiki)
- [poky crops docker image](https://github.com/crops/poky-container)
- [poky crops docker image](https://embeddeduse.com/2019/05/06/yocto-builds-with-crops-containers/)
- [meta-raspberrypi docs](http://meta-raspberrypi.readthedocs.io/en/latest/)
- [yoe (yocto and oe) distro](https://github.com/YoeDistro/yoe-distro)
- [ready set yocto](https://github.com/jynik/ready-set-yocto)
- [kas configuration tool (python3 based)](https://kas.readthedocs.io/en/3.1/intro.html)
- [yocto cheats](https://low-level.wiki/yocto/cheatsheet.html)
- [yocto cheats](https://elinux.org/images/3/3c/Yps2021.11-beginner.pdf)
- [yocto cheats](https://embeddeduse.com/2022/06/24/setting-up-yocto-projects-with-kas/)
- [yocto cheats](https://lancesimms.com/RaspberryPi/HackingRaspberryPi4WithYocto_Introduction.html)