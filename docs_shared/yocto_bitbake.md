# bitbake

- list all recipes available

    ```console
    pokyuser:/workdir/bsp/build$ bitbake -s
    ```

- list all recipe tasks for specific recipe

    ```console
    pokyuser:/workdir/bsp/build$ bitbake -c listtasks ess-image
    ```

- inspect image recipe MACHINE_FEATURES (hw device related)

    ```console
    pokyuser:/workdir/bsp/build$ bitbake ess-image -e | grep MACHINE_FEATURES
    ```

- inspect image recipe DISTRO_FEATURES (sw related)

    ```console
    pokyuser:/workdir/bsp/build$ bitbake ess-image -e | grep DISTRO_FEATURES
    ```

- search for location of vim recipe

    ```console
    pokyuser:/workdir/bsp/build-rpi-ess$ bitbake-layers show-recipes vim
    ...
    === Matching recipes: ===
    vim:
    meta                 9.0.0541
    ```

- build the vim package

    ```console
    pokyuser:/workdir/bsp/build$ bitbake vim
    ```

- clean the vim package

    ```console
    pokyuser:/workdir/bsp/build$ bitbake -c clean vim
    ```

- poky license file types

    ```console
    pokyuser:/workdir/bsp/build-rpi-ess$ ls ../sources/poky/meta/files/common-licenses
    ```

- determine compiler version used by bitbake ... see sources/poky/meta/recipes-devtools/gcc

    ```console
    pokyuser:/workdir/bsp/build-rpi-ess$ bitbake -e | grep "^GCCVERSION="
    GCCVERSION="11.%"
    ```

- quick return to build directory

    ```console
    pokyuser:/workdir/bsp/build-rpi-ess/tmp/work/raspberrypi4_64_ess-poky-linux/linux-raspberrypi/1_5.15.34+gitAUTOINC+e1b976ee4f_0086da6acd-r0$ cd $BUILDDIR/
    pokyuser:/workdir/bsp/build-rpi-ess$
    ```

- devtool

    - list workspaces
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess$ devtool status
        NOTE: Starting bitbake server...
        linux-raspberrypi: /workdir/bsp/build-rpi-ess/workspace/sources/linux-raspberrypi
        ```

- oe-pkgdata-util

    - list recipe files installed on target
        ```console
        pokyuser:/workdir/bsp/build-rpi-ess$ oe-pkgdata-util list-pkg-files <recipe name>
        ```

- yocto common tasks
    - bsp/sources/poky/documentation/dev-manual/common-tasks.rst
