FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/systemd-conf:"

SRC_URI += " \
    file://eth.network \
    file://en.network \
    file://wlan.network \
    file://alias.sh \
    file://qt_app.sh \
    file://qt_app.service \
"

RDEPENDS:${PN}:append = " wpa-supplicant systemd "

FILES:${PN} += " \
    ${sysconfdir}/systemd/network/eth.network \
    ${sysconfdir}/systemd/network/en.network \
    ${sysconfdir}/systemd/network/wlan.network \
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

    # install network files
    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 eth.network ${D}${sysconfdir}/systemd/network
    install -m 0644 en.network ${D}${sysconfdir}/systemd/network
    install -m 0644 wlan.network ${D}${sysconfdir}/systemd/network

    # install qt service and autostart
    install -d ${D}${sbindir}
    install -m 0750 qt_app.sh ${D}${sbindir}
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 qt_app.service ${D}${systemd_system_unitdir}
}

SYSTEMD_SERVICE:${PN} = "qt_app.service"