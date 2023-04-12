# Rough zybo-z7-10 UIO notes

references
https://forum.digilent.com/topic/4750-how-to-detect-and-handle-uio-interrupt/


... from zybo board ref manual
The Zybo Z7 board includes four slide switches, four push-buttons, four individual LEDs, and two tri-color LEDs
connected to the Zynq PL, as shown in Figure 13.1 (the Zybo Z7-10 only has one tri-color LED). There are also two
pushbuttons and one LED connected directly to the PS via MIO pins, also shown in Figure 13.1.

The 7z007s single core and 7z010 dual core CLG225 devices reduce the available MIO pins to 32
    the only GPIO pins that are available for MIO are 15:0, 39:28, 48, 49, 52, and 53. The other MIO pins are unconnected and should not be used. All EMIO signals are available.

... from 7000 trm
The general purpose I/O (GPIO) peripheral provides software with observation and control of up to
54 device pins via the MIO module. It also provides access to 64 inputs from the Programmable Logic
(PL) and 128 outputs to the PL through the EMIO interface. The GPIO is organized into four banks of
registers that group related interface signals.


54 GPIO signals for device pins (routed through the MIO multiplexer)
    Outputs are 3-state capable
192 GPIO signals between the PS and PL via the EMIO interface
    64 Inputs, 128 outputs (64 true outputs and 64 output enables)

PS gpios
    Bank0: 32-bit bank controlling MIO pins[31:0]
    Bank1: 22-bit bank controlling MIO pins[53:32]


btn 4   - mio50
btn 5   - mio51
ld4 led - mio7

root@Petalinux-2022:~# cat /sys/class/uio/uio6/name
btn_4


root@Petalinux-2022:~# cat /proc/interrupts
           CPU0       CPU1
 66:          0          0  zynq-gpio  50 Edge      btn_4



... to review
petalinux/zybo-z7-10/os/components/yocto/layers/meta-xilinx/meta-xilinx-bsp/README.booting.md
    Kernel, Root Filesystem and Device Tree boot over jtag
petalinux/zybo-z7-10/os/components/yocto/layers/meta-xilinx/meta-xilinx-core/recipes-bsp/u-boot/u-boot-zynq-uenv.bb

... from Re: [External] Re: Petalinux UIO dts configuration
the other uio generic driver ??? uio_dmem_genirq.of_id=dmem-uio"

... from https://redpitaya.readthedocs.io/en/latest/developerGuide/unused/uio/uio.html?highlight=interrupt%20pin
gpio irq, and a couple of named registers for the map
  reg = <0x40040000 0x01000>,
        <0x40050000 0x10000>;  // 2**14 * sizeof(int32_t), TODO: int16_t
  reg-names = "regset", "buffer";

... driver source
  drivers/uio/uio_pdrv_genirq.c

... xilinx slidedeck on uio
  https://blog.idv-tech.com/wp-content/uploads/2014/09/drivers-session3-uio-4public.pdf

... interesting but i think is pl int
  https://www.hackster.io/Roy_Messinger/gpio-and-petalinux-embedded-linux-yocto-based-c71773

... linux uio doc
https://www.kernel.org/doc/html/v4.17/driver-api/uio-howto.html#using-uio-pdrv-genirq-for-platform-devices

... pl and ps gpio control
https://www.hackster.io/johannes-schlatow/controlling-zybo-z7-gpio-with-genode-part-1-2-3d088c

... good zybo pl/ps tutorial with linux
https://www.farnell.com/datasheets/1904568.pdf

... led4 mio toggle attempt (not working)
https://stackoverflow.com/questions/40131771/sysfs-interface-i-cant-export-gpio-pins-in-a-xilinxs-board-zybo-and-other
    root@Petalinux-2022:~# cat /sys/class/gpio/gpiochip905/label
    zynq_gpio

... uio example, axi gpio based project ... maybe implement in zybo
https://www.linkedin.com/pulse/gpio-petalinux-part-3-go-uio-roy-messinger/?trk=public_profile_article_view



   12  cat /sys/class/gpio/gpiochip905/ngpio
   13  echo 1002 > /sys/class/gpio/export
   14  echo out > /sys/class/gpio/gpio1002/direction
   15  echo 1 > /sys/class/gpio/gpio1002/value
   16  echo 1 > /sys/class/gpio/gpio1002/value
   17  echo 1 > /sys/class/gpio/gpio1002/value


***** gpio  latest

root@Petalinux-2022:~# cat /proc/interrupts
           CPU0       CPU1
...
 66:          0          0  zynq-gpio  82 Edge      btn_4
 67:          0          0  zynq-gpio  51 Edge      btn_5

root@Petalinux-2022:~# cat /sys/class/uio/uio6/name
btn_4
root@Petalinux-2022:~# cat /sys/class/uio/uio7/name
btn_5

root@Petalinux-2022:~# lsmod
Module                  Size  Used by
uio_pdrv_genirq        16384  0

root@Petalinux-2022:~# cat /proc/device-tree/chosen/bootargs
console=ttyPS0,115200 earlyprintk uio_pdrv_genirq.of_id=generic-uio

// will this force a /proc/interrupts interrupt registration ?
echo 0x1 > /dev/uio6
echo 0x1 > /dev/uio7
// had no affect

***** dma space latest

root@Petalinux-2022:~# cat /sys/class/uio/uio7/name
fpga_registers
root@Petalinux-2022:~# cat /sys/class/uio/uio6/name
reserved-driver
