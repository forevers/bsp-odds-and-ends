
# Petalinx -> Yocto Project Migration

This document sumarizes the steps required to migrate from a xilinx petlainux to yocto project. The petalinux/zybo-z7-10 project main branch d8fe977f50169558aae51f6a48e9fb555cc62db0 was used as a starting point

## petalinux project migration

- source PL env using xilinx provides script and create the .run binary
    ```sh
    $ source ~/tools/petalinux_2022_1/settings.sh
    bsp-odds-and-ends/petalinux/zybo-z7-10/scripts/yocto_migration$ chmod a+x yocto-migrate.sh
    bsp-odds-and-ends/petalinux/zybo-z7-10/scripts/yocto_migration$ ./yocto-migrate.sh /mnt/data/projects/clones/bsp-odds-and-ends/petalinux/zybo-z7-10/os
    bsp-odds-and-ends/petalinux/zybo-z7-10/scripts/yocto_migration$ ls *.run
    plnx-yocto-migrate.run
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

1. The manifest for yocto layers repo sync'ed are contained in .repo/manifest.xml
    ```sh
    bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ cat .repo/manifest.xml 
    <manifest>
    <remote fetch="https://github.com/Xilinx" name="xilinx"/>
    
    <default sync-j="4"/>
    
    <project name="meta-browser" path="sources/meta-browser" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-clang" path="sources/meta-clang" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-jupyter" path="sources/meta-jupyter" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-mingw" path="sources/meta-mingw" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-openamp" path="sources/meta-openamp" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-openembedded" path="sources/meta-openembedded" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-petalinux" path="sources/meta-petalinux" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-python2" path="sources/meta-python2" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-qt5" path="sources/meta-qt5" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-security" path="sources/meta-security" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-som" path="sources/meta-som" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-virtualization" path="sources/meta-virtualization" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-xilinx" path="sources/meta-xilinx" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-xilinx-tools" path="sources/meta-xilinx-tools" remote="xilinx" revision="rel-v2022.1"/>
    <project name="poky" path="sources/core" remote="xilinx" revision="rel-v2022.1"/>
    <project name="yocto-manifests" path="sources/manifest" remote="xilinx" revision="rel-v2022.1"/>
    <project name="yocto-scripts" path="sources/yocto-scripts" remote="xilinx" revision="rel-v2022.1">
        <copyfile dest="setupsdk" src="setupsdk"/>
    </project>
    <project name="meta-ros" path="sources/meta-ros" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-xilinx-tsn" path="sources/meta-xilinx-tsn" remote="xilinx" revision="rel-v2022.1"/>
    <project name="meta-vitis" path="sources/meta-vitis" remote="xilinx" revision="rel-v2022.1"/>
    </manifest>
    ```

    1. These git repositories can be added to parent git project as submodules by using git submodules. The above manifest can be used to construct a .gitmodules file as follows: 
        ```sh
        bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto$ cat .gitmodules
        [submodule "sources/meta-browser"]
            path = sources/meta-browser
            url = https://github.com/Xilinx/meta-browser
            branch = rel-v2022.1
        ...
        ```

    1. see 'git submodule add [URL to Git repo]', 'git submodule init', 'git submodule update'

1. migrate the petalinux design into <yocto project>/sources/petalinux/
    ```sh
    bsp-odds-and-ends/petalinux/zybo-z7-10/scripts/yocto_migration$ ./plnx-yocto-migrate.run /mnt/data/projects/clones/bsp-odds-and-ends/petalinux_yocto/zybo-z7-10/yocto
    ```

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
