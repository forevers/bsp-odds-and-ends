FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/systemd-conf:"

SRC_URI += " \
    file://alias.sh \
    file://qt_app.sh \
    file://qt_app.service \
"

RDEPENDS:${PN}:append = " systemd "

FILES:${PN} += " \
    ${sysconfdir}/profile.d/alias.sh \
    ${sbindir} \
    ${systemd_system_unitdir} \
"

S = "${WORKDIR}"

inherit systemd

do_install:append() {

    # install root alias configuration script
    install -d ${D}${sysconfdir}/profile.d
    install -Dm 0644 alias.sh ${D}${sysconfdir}/profile.d/alias.sh

    # install qt service and autostart
    install -d ${D}${sbindir}
    install -m 0750 qt_app.sh ${D}${sbindir}
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 qt_app.service ${D}${systemd_system_unitdir}
}

SYSTEMD_SERVICE:${PN} = "qt_app.service"
