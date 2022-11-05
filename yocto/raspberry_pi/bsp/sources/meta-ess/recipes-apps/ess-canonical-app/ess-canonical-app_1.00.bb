SUMMARY = "Canonical recipe to build a generic user space application"
# for possible packaging aid
SECTION = "ESS/applications"
# see sources/poky/meta/files/common-licenses
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

# can place license file locally or use one in poky/meta/files/common-licenses
#LIC_FILES_CHKSUM = "file://COPYING;md5=801f80980d171dd6425610833a22dbe6"

inherit logging

SRC_URI = " \
    file://Makefile \
    file://main.cpp \
    file://header.h \
    file://header-1-00.h \
    "

# by default build ess-canonical-feature-default package
PACKAGECONFIG ??= "default-feature"
# 4th item in PACKAGECONFIG configuration is runtime dependency
#  see https://docs.yoctoproject.org/ref-manual/variables.html#term-PACKAGECONFIG
PACKAGECONFIG[default-feature] = ",,,ess-canonical-feature-default"
PACKAGECONFIG[optional-feature] = ",,,ess-canonical-feature-optional"

S = "${WORKDIR}"

do_compile() {
    oe_runmake
}

do_install() {
    bbplain "ess-canonical-app.bb do_install()"

    install -d ${D}${bindir}
    install -m 0755 ess-canonical-app ${D}${bindir}
}