FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"
SRC_URI:append = " file://bsp.cfg"
SRC_URI += "file://devtool-fragment.cfg \
            file://user_2022-11-27-20-25-00-overlayfs.cfg \
            "
SRC_URI += "file://user_2022-09-22-08-00-00.cfg \
           "
