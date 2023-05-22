SUMMARY = "utility to test reserved memory block"
SECTION = "PETALINUX/apps"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://uio-manager-test.cpp \
    file://uio-manager.cpp \
    file://uio-manager.h \
    file://Makefile \
    "

S = "${WORKDIR}"
CFLAGS:prepend = "-I ${S}"

do_install() {
        install -d ${D}${bindir}
        install -m 0755 ess-uio-mem-test ${D}${bindir}
}