FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://defconfig \
    file://01_kernel_memory_dbg.cfg \
    file://0001_modify_dts_model_parameter.patch \
    file://0002_add_uio_generic_driver.patch \
    "

# Prevent the use of in-tree defconfig
# was set to meta-raspberrypi/recipes-kernel/linux/linux-raspberrypi.inc
unset KBUILD_DEFCONFIG

# indicate use of appended config file
# already defined in meta-raspberrypi/recipes-kernel/linux/linux-raspberrypi.inc
# included here for clarity
KCONFIG_MODE = "alldefconfig"

# replace command line in /boot/cmdline.txt
# was
# root@ess-hostname:~# cat /boot/cmdline.txt
# dwc_otg.lpm_enable=0 console=serial0,115200 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait

# CMDLINE = "dwc_otg.lpm_enable=0 console=serial0,115200 uio_pdrv_genirq.of_id=generic-uio root=/dev/mmcblk0p2 rootfstype=ext4 rootwait"
