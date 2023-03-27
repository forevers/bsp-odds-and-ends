
# petalinx -> yocto project migration
This document sumarizes the steps required to migrate from a xilinx petlainux to yocto project. The petalinux/zybo-z7-10 project main branch d8fe977f50169558aae51f6a48e9fb555cc62db0 was used as a starting point

## petalinux project migration

- source PL env using xilinx provides script and create the .run binary
    ```sh
    $ source ~/tools/petalinux_2022_1/settings.sh
    bsp-odds-and-ends/petalinux/zybo-z7-10/scripts/yocto_migration$ chmod a+x yocto-migrate.sh
    bsp-odds-and-ends/petalinux/zybo-z7-10/scripts/yocto_migration$ ./yocto-migrate.sh /mnt/data/projects/clones/bsp-odds-and-ends/petalinux/zybo-z7-10/os
    ```

## repo tool
- google repo tool// current repo
    ```sh
    curl https://storage.googleapis.com/git-repo-downloads/repo-1 > ~/bin/repo
    ```

# construct and bake yocto project
1. Create yocto project using below steps
    ```sh
    bsp-odds-and-ends/petalinux_yocto/zybo-z7-10$ mkdir yocto && cd yocto
    
1. specify and sync manifest
    ```
    bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ repo init -u https://github.com/Xilinx/yocto-manifests.git -b  rel-v2022.1
    bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ repo sync
    bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ chmod 666 setupsdk
    ```

1. migrate the petalinux design into <yocto project>/sources/petalinux/
    ```sh
    bsp-odds-and-ends/petalinux/zybo-z7-10/scripts/yocto_migration$ ./plnx-yocto-migrate.run /mnt/data/projects/clones/bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto
    ``

1. manually copy the dts overlay source petalinux/zybo-z7-10/dts-overlays/ess-dma-moc-overlay.dts ... TODO review location external to original petalinux project directory

1. source the setupsdk to copy plnxtool.conf file into yocto/build/conf directory from yocto/sources/petalinux and add yocto/sources/petalinux/project-spec/meta-user layer into yocto/build/conf/bblayers.conf file
    ```sh
    bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ PLNX_SETUP=1 source setupsdk
    ```

1. bake
    ```sh
    bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ bitbake petalinux-image-minimal
    ```
    
## references
- https://xilinx-wiki.atlassian.net/wiki/spaces/A/pages/757891119/Migrate+from+PetaLinux+project+to+Yocto+project




Step 2: To import the petalinux data into yocto project run the plnx-yocto-migrate.run which is generated in the section 'Exporting Petalinux Project' above. This will create and extract the files into yocto/sources/petalinux directory.

bsp-odds-and-ends/petalinux/zybo-z7-10/scripts/yocto_migration$ ./plnx-yocto-migrate.run /mnt/data/projects/clones/bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto

$ ls <yocto project>/sources/petalinux/
etc  plnx-setupsdk  plnxtool.conf  project-spec


plnx-setupsdk -
Setup script to add petalinux project environment into the yocto project. This will be called inside the setupsdk file if you specify the PLNX_SETUP=1.

etc/ -
This directory will contain the tcl script which will be used to create the uboot/device-tree configuration files Ex: system-conf.dtsi.

plnxtool.conf -
Petalinux generated .conf file with yocto variables. You can edit this file as required and build in yocto project.

project-spec/ -
Project configuration files directory. It will have the hardware file(xsa) which was included in petalinux project.

Step 3: source the setupsdk and build 

bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ PLNX_SETUP=1 source setupsdk
- The above will copy plnxtool.conf file into yocto/build/conf directory from yocto/sources/petalinux and add yocto/sources/petalinux/project-spec/meta-user layer into yocto/build/conf/bblayers.conf file.
- It is always recomended to use PLNX_SETUP=1 when sourcing the setupsdk to setup petalinux environment properly otherwise build may fail.

bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ bitbake petalinux-image-minimal
- The images/linux directory will be created in yocto/sources/petalinux/
- **User can not run any petalinux commands in <yocto project>/source/petalinux(for example, petalinux-package to generate BOOT.BIN), an error will be encountered since the current directory is not part of a petalinux project. Instead user can copy images/linux directory into the petalinux project for running any subsequent petalinux commands.**

build errors

TODO - revisit overlay directory location

ERROR: device-tree-xilinx-v2022.2+gitAUTOINC+24d29888d0-r0 do_fetch: Fetcher failure: Unable to find file file:///mnt/data/projects/clones/bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto/build/../../dts-overlays/ess-dma-moc-overlay.dts anywhere. The paths that were searched were:

ERROR: device-tree-xilinx-v2022.2+gitAUTOINC+24d29888d0-r0 do_fetch: Fetcher failure for URL: 'file:///mnt/data/projects/clones/bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto/build/../../dts-overlays/ess-dma-moc-overlay.dts'. Unable to fetch URL from any source.
ERROR: Logfile of failure stored in: /mnt/data/projects/clones/bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto/build/tmp/work/zynq_generic-xilinx-linux-gnueabi/device-tree/xilinx-v2022.2+gitAUTOINC+24d29888d0-r0/temp/log.do_fetch.53276
ERROR: Task (/mnt/data/projects/clones/bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto/sources/core/../meta-xilinx/meta-xilinx-core/recipes-bsp/device-tree/device-tree.bb:do_fetch) failed with exit code '1'

manual location of dts overlay directory

build errors

ERROR: linux-xlnx-5.15.36+gitAUTOINC+machine-r0 do_kernel_version_sanity_check: Package Version (5.15.36+gitAUTOINC+machine) does not match of kernel being built (5.15.19). Please update the PV variable to match the kernel source or set KERNEL_VERSION_SANITY_SKIP="1" in your recipe.
ERROR: linux-xlnx-5.15.36+gitAUTOINC+machine-r0 do_kernel_version_sanity_check: ExecutionError('/mnt/data/projects/clones/bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto/build/tmp/work/zynq_generic-xilinx-linux-gnueabi/linux-xlnx/5.15.36+gitAUTOINC+machine-r0/temp/run.do_kernel_version_sanity_check.73544', 1, None, None)
ERROR: Logfile of failure stored in: /mnt/data/projects/clones/bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto/build/tmp/work/zynq_generic-xilinx-linux-gnueabi/linux-xlnx/5.15.36+gitAUTOINC+machine-r0/temp/log.do_kernel_version_sanity_check.73544
ERROR: Task (/mnt/data/projects/clones/bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto/sources/core/../meta-xilinx/meta-xilinx-core/recipes-kernel/linux/linux-xlnx_2022.2.bb:do_kernel_version_sanity_check) failed with exit code '1'

switch back to 2022.1 version