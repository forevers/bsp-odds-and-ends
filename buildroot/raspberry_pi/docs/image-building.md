# Build Environment and Image Building

## Docker Image

- see docker/Dockerfile for docker image construction
- docker build -t ess/buildroot-builder .

## Docker Container

This buildroot target uses br2-external to cache build results outside of the docker container.
- docker run -ti --rm -v <host br2-external path>:~/br2_external ess/buildroot-builder

## Image Build

1. invoke docker container with above docker CL
1. construct custom defconfig
    - BR2_EXTERNAL only needs to be issued once initially to locate br2-external
    - root@5c0367044a04:~/buildroot/buildroot-2023.05# make BR2_EXTERNAL=/br2_external raspberrypi4_64_defconfig
1. root@5c0367044a04:~/buildroot/buildroot-2023.05# make menuconfig
    - System configuration -> System hostname : ess
    - System configuration -> System banner : Welcome to ess Distro
    - Build options  -> /br2_external/configs/ess_defconfig
    - External options  -> /br2_external
1. root@5c0367044a04:~/buildroot/buildroot-2023.05# make savedefconfig
1. verify custom defconfig
    - root@848c3fe0f3d6:~/buildroot/buildroot-2023.05# make list-defconfigs | grep ess_defconfig
    ```
    qemu_arm_vexpress_defconfig         - Build for qemu_arm_vexpress
    ess_defconfig                       - Build for ess
    ```
1. root@848c3fe0f3d6:~/buildroot/buildroot-2023.05# cat output/.br2-external.mk
1. create the cusom config
    - root@848c3fe0f3d6:~/buildroot/buildroot-2023.05# time make BR2_EXTERNAL=/br2_external ess_defconfig
    ```
    ...
    # configuration written to /root/buildroot/buildroot-2023.05/.config
    ```
1. build the image
    - root@848c3fe0f3d6:~/buildroot/buildroot-2023.05# time O=/br2_external/output make all
    ```
    ...
    real    40m54.878s
    user    297m8.802s
    sys     27m34.621s
    ```
1. images located at br2_external/output/images
    - sdcard.imag
    - rootfs.ext4
    - bcm2711-rpi-4-b.dtb

## Device Tree

- a composite dts can be created by reverse compiling the dtb built image

    ```console
    br2_external/output/images$ dtc -I dtb -O dts bcm2711-rpi-4-b.dtb -o /dev/shm/reverse_compiled.dts
    ```

-  device tree can be inspected on target under /proc/device-tree
