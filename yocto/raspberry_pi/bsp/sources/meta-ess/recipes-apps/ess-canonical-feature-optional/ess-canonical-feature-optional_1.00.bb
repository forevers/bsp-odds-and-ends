SUMMARY = "Canonical recipe to build a ess-canonical-app dependency"
SECTION = "ESS/applications"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://Makefile \
           file://main.cpp \
          "

S = "${WORKDIR}"

do_compile() {
    oe_runmake
}

do_install() {
    bbnote "ess-canonical-feature-optional.bb do_install()"

    install -d ${D}${bindir}
    install -m 0755 ess-canonical-feature-optional ${D}${bindir}
}