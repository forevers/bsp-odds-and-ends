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
- bsp version out of tree module and auto load
- NetworkManager - eth0 and wlan0

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

## Documentation

- [ess distribution](docs/ess-distro.md)
- [build environment and image baking](docs/image-baking.md)
- [sdk baking](docs/sdk-creation.md)
- [yocto references](/docs_shard/yocto.md)
- [sd card image flashing](docs/sd-card-flashing.md)
- [qt5 configuration](docs/qt-configuration.md)
- [networking](docs/networking.md)
- [Flask Web Application Framework](docs/flask.md)
- [systemd](/docs_shared/systemd.md)
- [journald](/docs_shared/journald.md)
- [time-configuration](docs/time-configuration.md)
- [overlayfs](docs/overlayfs.md)
- [kernel configuration](docs/kernel-configuration.md)
- [rpi hw](docs/rpi-hw.md)
