# extend poky/meta/recipes-connectivity/wpa-supplicant
#   - autostart wlan0
#   - default wlan0 interface conf file added to rootfs

FILESEXTRAPATHS:prepend := "${THISDIR}/files:"
SRC_URI += " file://wpa_supplicant-wlan0.conf"

SYSTEMD_AUTO_ENABLE = "enable"

do_install:append() {
    install -d ${D}${sysconfdir}/wpa_supplicant/
    install -D -m 600 ${WORKDIR}/wpa_supplicant-wlan0.conf ${D}${sysconfdir}/wpa_supplicant/

    # the above SYSTEMD_AUTO_ENABLE = "enable" does not create the needed systemd symlink to start wifi on boot
    install -d ${D}${sysconfdir}/systemd/system/multi-user.target.wants/
    ln -s ${systemd_unitdir}/system/wpa_supplicant@.service ${D}${sysconfdir}/systemd/system/multi-user.target.wants/wpa_supplicant@wlan0.service
}
