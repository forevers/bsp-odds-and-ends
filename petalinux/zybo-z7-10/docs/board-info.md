# xybo-z7-10 Board Info

## Power and UART console

- u-USB to PC provides both power and FTDI console on /etc/TTYUSB\<x>

    ```
    Bus 003 Device 007: ID 0403:6010 Future Technology Devices International, Ltd FT2232C/D/H Dual UART/FIFO IC
    ```

## MIPI Camera Notes

- seems like digilent pcam is mipi camera required ... what about rpi camera ?
    - https://community.element14.com/products/roadtest/rv/roadtest_reviews/653/digilent_zybo_z7_pca_2

- z10 limitations ?
    - https://forum.digilent.com/topic/17944-petalinux-on-zybo-z7-10/

- ... but wait this thread indicates turning off csi-2 ip debug reduces gate usage ... have to recompile the vivado demo to make it work
    =- https://forum.digilent.com/topic/16834-zybo-z7-20-pcam-demo-unimplementable-on-vivado-20174/

- other links
    - https://forum.digilent.com/topic/16385-pcam-5c-demo-on-zybo-z7-10/?sortby=date
    = https://ohwr.org/project/soc-course/wikis/Reverse-Engineering-the-XSA-File
