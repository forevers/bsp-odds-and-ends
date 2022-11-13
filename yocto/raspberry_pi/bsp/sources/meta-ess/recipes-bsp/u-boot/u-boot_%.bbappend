FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

# temp test for devtool patch testing
INSANE_SKIP:${PN} += " Missing Upstream-Status in patch"

SRC_URI:append:rpi = " \
    file://01_enable_i2c_cmd.cfg \
    file://patch0001_modify_version_command.patch \
"
