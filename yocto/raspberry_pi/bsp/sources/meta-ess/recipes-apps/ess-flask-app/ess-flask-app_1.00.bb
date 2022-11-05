SUMMARY = "Flask demo application"
SECTION = "ESS/daemons"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

inherit systemd

SRC_URI = "file://ess-flask-app.py \
           file://ess-flask-app.service \
          "

S = "${WORKDIR}"

do_install () {
    # install python3 script
    install -d ${D}${bindir}
    install -m 0755 ess-flask-app.py ${D}${bindir}/ess-flask-app.py

    # install service configuration file
    install -d ${D}${systemd_unitdir}/system
    install -m 644 ${WORKDIR}/ess-flask-app.service ${D}${systemd_unitdir}/system
}

RDEPENDS:${PN} = "python3 python3-flask"

FILES_${PN} += " \
    ${systemd_unitdir}/system/ess-flask-app.service \
    ${systemd_unitdir} \
"

# enable the service on boot
SYSTEMD_SERVICE:${PN} = "ess-flask-app.service"
