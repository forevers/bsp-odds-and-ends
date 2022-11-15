# Petalinux BUilds

## Petalinx Version

- 2022.1

## Installation
- chmod +x Xilinx_Unified_2022.1_0420_0327_Lin64.bin && sudo ./Xilinx_Unified_2022.1_0420_0327_Lin64.bin

- download the '*.bsp' file from the demo release page
https://github.com/Digilent/Zybo-Z7/releases/tag/10%2FPetalinux%2F2022.1-1?_ga=2.77896784.511116902.1668454546-892977042.1667254672

- see ug973 for cable driver instructions
    ```console
    host:/tools/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/install_script/install_drivers$ sudo ./install_drivers
    INFO: Installing cable drivers.
    ...
    CRITICAL WARNING: Cable(s) on the system must be unplugged then plugged back in order for the driver scripts to update the cables.
    steve@embedify:/tools/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/
    ```
- copy board files per instructions

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

- install gcc-multilib package required to install PL
    ```console
    host:~/tools$ ./petalinux-v2022.1-04191534-installer.run --dir ~/tools/petalinux_2022_1
    ```

- source PL env settings
    ```console
    host:~/projects/zybo$ source ~/tools/petalinux_2022_1/settings.sh
    ```

- create project based off released BSP
    ```console
    host:~/projects/zybo$ petalinux-create -t project -s ~/projects/zybo/bsp/Zybo-Z7-10-Petalinux-2022-1.bsp
    host:~/projects/zybo$ cd os/
    host:~/projects/zybo$ time petalinux-build
    real    59m32.761s
    user    1m1.301s
    sys     0m13.097s
    ```

- create BOOT.bin
    ```console
    host:~/projects/zybo$ petalinux-package --boot --force --fsbl images/linux/zynq_fsbl.elf --fpga images/linux/system.bit --u-boot
    ```

TODO:
barrel power source
detail jumper settings
bootgen
investigate emmc usage
investigate persistent rootfs
investigate overlay over rootfs
sscache and downloads
git archive initial project
...

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



