# Petalinux Builds

## device

- zybo-z7
    - XC7Z010-1CLG400C
    - pinout
        - https://www.xilinx.com/content/dam/xilinx/support/packagefiles/z7packages/xc7z010clg400pkg.txt

## Petalinx Version

- 2022.1

## Distro Features

- initrd rootfs: petalinux account, promted for non-persistant password 
- debug uart
- systemd
- dts overlay with dma driver example

## Documentation

- [Xilinx Tools Installation](/docs/xilinx-tools-installation.md)
- [Petalinux Project Construction/Modification](/docs/petalinux-project-construction.md)
- [Petalinux -> Yocto Project Migration](/docs/yocto-migration.md)
- [Petalinux Build](/docs/petalinux-build.md)
- [Image Flashing](/docs/image-flashing.md)
- [Device Tree Modifications](/docs/device-tree-modifications.md)
- [Generic UIO](/docs/generic-uio.md)
- [FPGA Manager](/docs/fpga-mamager.md)
- [systemd usage](/docs/shared/systemd.md)
- [journald usage](/docs/shared/journald.md)
- [zybo-z7-10 Board Info](/docs/board-info.md)

## TODO

- configure tftp/nfs boot of kernel/bit/rootfs
- barrel power source
- detail jumper settings
- bootgen
- investigate ext partitioning qspi flash
- investigate persistent rootfs
- investigate overlay over rootfs
- evaluate digilent jtag debugger jsn-JTAG-HS2-210249ACD403
    - https://digilent.com/shop/jtag-hs2-programming-cable/?utm_source=google&utm_medium=cpc&utm_campaign=18640327811&utm_content=140606091822&utm_term=&gclid=Cj0KCQiAg_KbBhDLARIsANx7wAyXqvVNBMCV-MFBfu0BbaULrKQD6lgmNrASC7yZGYcuiaO563MWhGUaAiVYEALw_wcB

## References

### digilent vivado/vitis 2022.1 installation

- https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-vitis
- https://github.com/Digilent/Zybo-Z7/compare/master...10/Petalinux/master

### digilent demos

- https://digilent.com/reference/programmable-logic/zybo-z7/demos/petalinux

### xilinx download site

- https://www.xilinx.com/support/download.html?_ga=2.170161764.511116902.1668454546-892977042.1667254672
“Vivado ML Edition - <Version #>”

### PL tools

- https://docs.xilinx.com/v/u/2020.1-English/ug1144-petalinux-tools-reference-guide

### xilinx wiki

- https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/18842482/Device+Tree+Tips

### device tree

- https://elinux.org/images/f/f9/Petazzoni-device-tree-dummies_0.pdf
- https://elinux.org/Device_Tree_Mysteries
- https://www.kernel.org/doc/Documentation/devicetree/bindings/arm/xilinx.txt
