# Yocto SDK Creation

- build sdk
    ```console
    pokyuser:/workdir/bsp/build-rpi-ess$ bitbake -c populate_sdk ess-image
    ```

- install sdk
    ```console
    host$ ./tmp/deploy/sdk/poky-glibc-x86_64-ess-image-cortexa72-raspberrypi4-64-ess-toolchain-1.0.0.sh
    ```

- run following to configure sdk environment at a specified location
    ```console
    . <path to installed sdk>/environment-setup-cortexa72-poky-linux
    ```

- verify kernel memory leak detection fs exposure
    ```console
    root@ess-hostname:~# ls /sys/kernel/debug/kmemleak
    /sys/kernel/debug/kmemleak
    ```

## References
[sdk docker container](https://github.com/crops/extsdk-container/blob/master/README.md)
