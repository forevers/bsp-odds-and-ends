SUMMARY = "Flask demo application"
SECTION = "ESS/daemons"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=801f80980d171dd6425610833a22dbe6"

inherit systemd

SRC_URI = "file://flask-ess-application.py \
           file://flask-ess-application.service \
           file://COPYING \
          "

S = "${WORKDIR}"

do_install () {
    # install python3 script
    install -d ${D}${bindir}
    install -m 0755 flask-ess-application.py ${D}${bindir}/flask-ess-application.py

    # install service configuration file
    install -d ${D}${systemd_unitdir}/system
    install -m 644 ${WORKDIR}/flask-ess-application.service ${D}${systemd_unitdir}/system
}

RDEPENDS:${PN} = "python3 python3-flask"

FILES_${PN} += " \
    ${systemd_unitdir}/system/flask-ess-application.service \
    ${systemd_unitdir} \
"

# enable the service on boot
SYSTEMD_SERVICE:${PN} = "flask-ess-application.service"
