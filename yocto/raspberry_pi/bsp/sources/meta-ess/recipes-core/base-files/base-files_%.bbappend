FILESEXTRAPATHS:prepend := "${THISDIR}/etc-defaults:${THISDIR}/base-files:"

SRC_URI += "file://share/dot.bashrc"

S = "${WORKDIR}"

do_install:append() {
    install -d ${D}{sysconfdir}/skel
    install -m 0755 ${S}/share/dot.bashrc ${D}${sysconfdir}/skel/.bashrc
}
