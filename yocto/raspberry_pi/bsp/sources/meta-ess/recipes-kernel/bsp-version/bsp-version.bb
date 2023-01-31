SUMMARY = "Recipe to build a module exposing a bsp-version file under /proc"
SECTION = "PETALINUX/modules"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

inherit module

KERNEL_MODULE_AUTOLOAD += "bsp-version"

INHIBIT_PACKAGE_STRIP = "1"

# bsp-version.h is created from version.txt and git status information in create-bsp-version-header.sh

SRC_URI = "file://Makefile \
           file://bsp-version.c \
           file://bsp-version.h \
           file://version.h \
           file://bsp-version.conf \
          "

S = "${WORKDIR}"

# TODO should not require the conf addition ... something in kernel-module-split.bbclass not configured correctly ...
#   is kernel config CONFIG_MODULE_FORCE_LOAD=y required ?
do_install:append() {
    install -m 0644 ${WORKDIR}/bsp-version.conf ${D}${sysconfdir}/modules-load.d/bsp-version.conf
}

RPROVIDES_${PN} += "bsp-version"