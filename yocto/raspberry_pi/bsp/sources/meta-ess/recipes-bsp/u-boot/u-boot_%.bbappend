FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI:append:rpi = " \
    file://01_enable_i2c_cmd.cfg \
    file://0001-patch-u-boot-version-command.patch \
"
