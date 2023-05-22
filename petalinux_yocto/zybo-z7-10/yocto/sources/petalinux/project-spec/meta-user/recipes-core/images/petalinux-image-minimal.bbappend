IMAGE_INSTALL:append = " \
    ess-uio-mem-test \
    build-version \
    xilinx-bootbin \
"

IMAGE_FSTYPES = "wic.xz tar.gz cpio.gz.u-boot ext4"

IMAGE_BOOT_FILES = " \
    boot.bin \
    boot.scr \
    Image \
"
