SUMMARY = "Recipe to build a module exposing a bsp-version file under /proc"
SECTION = "PETALINUX/modules"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

inherit module

KERNEL_MODULE_AUTOLOAD += "build-version"

INHIBIT_PACKAGE_STRIP = "1"

# bsp-version.h is created from version.txt and git status information in create-bsp-version-header.sh

SRC_URI = " \
    file://Makefile \
    file://build-version.c \
    "

S = "${WORKDIR}"

VERSION_HEADER_FILE = "${S}/version.h"

do_configure:prepend () {

    if [ ! -f "${THISDIR}/files/version.h" ] ; then
        VERSION_WARNING="\"version.h does not exist. run construct-version-header.sh prior to baking.\""
        bbwarn $VERSION_WARNING
        echo "#pragma once\n#define VERSION \\" > ${VERSION_HEADER_FILE}
        echo ${VERSION_WARNING} >> ${VERSION_HEADER_FILE}
    else
        # copy runtime header file into build directory
        cp ${THISDIR}/files/version.h ${VERSION_HEADER_FILE}
    fi
}

RPROVIDES_${PN} += "build-version"
