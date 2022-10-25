# Base this image on core-image-base
# 'require' is another directive which is similar to 'include', but the major difference
#   is that 'require' will throw an error when it doesn't find that file.
#include recipes-core/images/core-image-base.bb
require recipes-core/images/core-image-base.bb

# i2c-tools (https://i2c.wiki.kernel.org/index.php/I2C_Tools)
# use IMAGE_INSTALL:append instead of +=
# see https://community.nxp.com/t5/i-MX-Processors/Difference-in-installing-process/m-p/723831
# see yocto dev-manual: "Furthermore, you must use _append instead of the += operator if you want to avoid ordering issues.
# The reason for this is because doing so unconditionally appends to the variable and avoids ordering
# problems due to the variable being set in image recipes and .bbclass files with operators like ?=.
# Using _append ensures the operation takes affect.""

IMAGE_INSTALL:append = " i2c-tools"

# enhanced vi editor
IMAGE_INSTALL:append = " vim"

# timezone configuration
IMAGE_INSTALL:append = " tzdata"

# see raspberrypi4-64-ess.conf for machine conf parts of overlayfs
IMAGE_FEATURES:append = " overlayfs-etc"

# change root password
#inherit extrausers
#EXTRA_USERS_PARAMS = "usermod -p $(openssl passwd ess@pwd) root;"

