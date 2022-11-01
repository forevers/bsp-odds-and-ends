FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://defconfig \
    file://01_kernel_memory_dbg.cfg \
    "

# Prevent the use of in-tree defconfig
# was set to meta-raspberrypi/recipes-kernel/linux/linux-raspberrypi.inc
unset KBUILD_DEFCONFIG

# indicate use of appended config file
# already defined in meta-raspberrypi/recipes-kernel/linux/linux-raspberrypi.inc
# included here for clarity
KCONFIG_MODE = "alldefconfig"

