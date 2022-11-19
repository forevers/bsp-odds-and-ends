# Petalinux BUilds

## Petalinx Version

- 2022.1

## Distro Features

## Tools Installation

- Note: tool installation on Ubuntu 22.04 (not formally sported by Xilinx)

- Vitis/Vivado installation

    - references:
        https://digilent.com/reference/programmable-logic/zybo-z7/demos/petalinux
        https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-vitis

    - 2022.1 is latest support toolchain version fpr zybo z7 platforms:
        https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2022-1.html

    - install the tools to default location /tools/Xilinx. only 7 series devices required for zybo.
        ```console
        chmod +x Xilinx_Unified_2022.1_0420_0327_Lin64.bin && sudo ./Xilinx_Unified_2022.1_0420_0327_Lin64.bin
        ```

    - installation includes:
        vivado - hdl
        vitis - vitis hls, sw sdk

    - see ug973 for cable driver instructions
        ```console
        host:/tools/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/install_script/install_drivers$ sudo ./install_drivers
        INFO: Installing cable drivers.
        ...
        CRITICAL WARNING: Cable(s) on the system must be unplugged then plugged back in order for the driver scripts to update the cables.
        steve@embedify:/tools/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/
        ```

    - digilent board files
        - https://github.com/Digilent/vivado-boards/archive/master.zip?_ga=2.26386043.719103120.1668636885-892977042.1667254672
        - vivado-boards-master.zip
            - copy its new/board_files folder to /tools/Xilinx/Vivado/2022.1/data/boards/board_files

    - verify install
        - vivado launch
            ```console
            $ source /tools/Xilinx/Vivado/2022.1/settings64.sh
            $ vivado
            ```

        - vitis launch
            ```console
            $ source /tools/Xilinx/Vivado/2022.1/settings64.sh
            $ vitis
            ```

- PetaLinux installation

    - 2022.1 installer
    https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools/2022-1.html

    - Ubuntu 22.01 host required install gcc-multilib package in order to install PL
        ```console
        host:~/tools$ ./petalinux-v2022.1-04191534-installer.run --dir ~/tools/petalinux_2022_1
        ```

- Petalinux project construction from prebuilt bsp

    - source PL env settings
        ```console
        host:~/projects/zybo$ source ~/tools/petalinux_2022_1/settings.sh
        ```

    - download the '*.bsp' file from the demo release page

        - ***PetaLinux BSPs are provided in the form of installable BSP files, and include all necessary design and configuration files, pre-built and tested hardware, and software images ready for downloading on your board or for booting in the QEMU system emulation environment.***

        - bsp file can be used in initial PetaLinux project generation vs a template based project generation

        - general repo
            https://digilent.com/reference/programmable-logic/documents/git

        - zybo z7-10 repo (includes released bsp)
            https://github.com/Digilent/Zybo-Z7/releases/tag/10%2FPetalinux%2F2022.1-1?_ga=2.77896784.511116902.1668454546-892977042.1667254672

        - bsp zip file elements:
            - /os/hardware/system.bit
            - /os/project-spec/hw-description/system.xsa
                - system.xsa zip file elements:
                    drivers/axi_i2s_adi_v1_0/data/axi_i2s_adi.mdd
                    drivers/axi_i2s_adi_v1_0/data/axi_i2s_adi.tcl
                    drivers/axi_i2s_adi_v1_0/src/axi_i2s_adi.c
                    drivers/axi_i2s_adi_v1_0/src/axi_i2s_adi.h
                    drivers/axi_i2s_adi_v1_0/src/axi_i2s_adi_selftest.c
                    drivers/axi_i2s_adi_v1_0/src/Makefile
                    drivers/dynclk/data/dynclk.mdd
                    drivers/dynclk/data/dynclk.tcl
                    drivers/dynclk/src/ddynclk.c
                    drivers/dynclk/src/ddynclk.h
                    drivers/dynclk/src/ddynclk_g.c
                    drivers/dynclk/src/ddynclk_selftest.c
                    drivers/dynclk/src/ddynclk_sinit.c
                    drivers/dynclk/src/Makefile
                    drivers/PWM_v1_0/data/PWM.mdd
                    drivers/PWM_v1_0/data/PWM.tcl
                    drivers/PWM_v1_0/src/Makefile
                    drivers/PWM_v1_0/src/PWM.c
                    drivers/PWM_v1_0/src/PWM.h
                    drivers/PWM_v1_0/src/PWM_selftest.c
                    ps7_init.c
                    ps7_init.h
                    ps7_init.html
                    ps7_init.tcl
                    ps7_init_gpl.c
                    ps7_init_gpl.h
                    sysdef.xml
                    system.bda
                    system.hwh
                    system_wrapper.bit
                    xsa.json
                    xsa.xml

    - create project based off released BSP

        ```console
        host:~/projects/zybo$ petalinux-create -t project -s ~/projects/zybo/bsp/Zybo-Z7-10-Petalinux-2022-1.bsp
        ```

- Builds based off a new hdl design (xsa and bit files)

    - for modifications to initial fpga design ...
        - ***The petalinux-config --get-hw-description command allows you to initialize or update a PetaLinux project with hardware-specific information from the specified Vivado® Design Suite hardware project. The components affected by this process can include FSBL configuration, U-Boot options, Linux kernel options, and the Linux device tree configuration. This workflow should be used carefully to prevent accidental and/or unintended changes to the hardware configuration for the PetaLinux project. The path used with this workflow is the directory that contains the XSA file rather than the full path to the XSA file itself. This entire option can be omitted if run from the directory that contains the XSA file.***

    - place new xsa file in ../bsp/Zybo-Z7-10-Petalinux-2022-1/os/project-spec/hw-description

    - config the project based on (potentially new) xsa

        ```console
        ~/projects/zybo/os$ petalinux-config --get-hw-description ../bsp/Zybo-Z7-10-Petalinux-2022-1/os/project-spec/hw-description --silentconfig
        ```

- dts modifications

    - patch existing dts node
        - TODO

    - manually create diff from commit to apply to existing meta-ess/recipes-kernel/linux/ ... TODO

    - verify dts modification

        - by reversing compiling build dtb ... TDOD

        - target /proc/device-tree -> /sys/firmware/devicetree/home

        - by target image inspection ... TODO
            ```console
            root@ess-hostname:~# cat /proc/device-tree/ ...
            ess patch
            ```

- build project

    - petalinux-build

        ```console
        host:~/projects/zybo/os$ petalinux-build
        ```

    - create BOOT.bin
        ```console
        host:~/projects/zybo/os$ petalinux-package --boot --force --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --u-boot
        ```

TODO:
barrel power source
detail jumper settings
bootgen
investigate emmc usage
investigate persistent rootfs
investigate overlay over rootfs

## mipi camera notes
- seems like digilent pcam is mipi camera required ... what about rpi camera ?
    - https://community.element14.com/products/roadtest/rv/roadtest_reviews/653/digilent_zybo_z7_pca_2
- z10 limitations ?
    - https://forum.digilent.com/topic/17944-petalinux-on-zybo-z7-10/
- ... but wait this thread indicates turning off csi-2 ip debug reduces gate usage ... have to recompile the vivado demo to make it work
    =- https://forum.digilent.com/topic/16834-zybo-z7-20-pcam-demo-unimplementable-on-vivado-20174/


- other links
    - https://forum.digilent.com/topic/16385-pcam-5c-demo-on-zybo-z7-10/?sortby=date
    = https://ohwr.org/project/soc-course/wikis/Reverse-Engineering-the-XSA-File


## Features

## References

### digilent vivado/vitis 2022.1 installation
https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-vitis
https://github.com/Digilent/Zybo-Z7/compare/master...10/Petalinux/master
### digilent demos
https://digilent.com/reference/programmable-logic/zybo-z7/demos/petalinux

### xilinx download site
https://www.xilinx.com/support/download.html?_ga=2.170161764.511116902.1668454546-892977042.1667254672
“Vivado ML Edition - <Version #>”
### PL tools
https://docs.xilinx.com/v/u/2020.1-English/ug1144-petalinux-tools-reference-guide



