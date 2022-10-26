SUMMARY = "Canonical recipe to build a generic user space application"
# for possible packaging aid
SECTION = "ESS/applications"
# see sources/poky/meta/files/common-licenses
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://Makefile \
           file://main.cpp \
           file://header.h \
           file://header-1-00.h \
           file://COPYING \
          "

S = "${WORKDIR}"

do_compile() {
    oe_runmake
}

do_install() {
    install -d ${D}${bindir}
    install -m 0755 ess-canonical-app ${D}${bindir}
}