FILESEXTRAPATHS:prepend := "${THISDIR}/files:${THISDIR}/systemd-conf:"

SRC_URI += " \
    file://eth.network \
    file://en.network \
    file://wlan.network \
    file://alias.sh \
"

RDEPENDS:${PN}:append = " wpa-supplicant systemd "

FILES:${PN} += " \
    ${sysconfdir}/systemd/network/eth.network \
    ${sysconfdir}/systemd/network/en.network \
    ${sysconfdir}/systemd/network/wlan.network \
    ${sysconfdir}/profile.d/alias.sh \
"

do_install:append() {

    # install root alias configuration script
    install -d ${D}${sysconfdir}/profile.d
    install -Dm 0644 ${WORKDIR}/alias.sh ${D}${sysconfdir}/profile.d/alias.sh

    # isntall network files
    install -d ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/eth.network ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/en.network ${D}${sysconfdir}/systemd/network
    install -m 0644 ${WORKDIR}/wlan.network ${D}${sysconfdir}/systemd/network
}