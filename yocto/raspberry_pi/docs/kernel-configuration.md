# kernel configuration

## stack usage

    ```console
    root@ess-hostname:~# journalctl -b | grep "used greatest stack depth"
    Apr 28 10:42:27 ess-hostname kernel: cryptomgr_test (44) used greatest stack depth: 15232 bytes left
    Apr 28 10:42:27 ess-hostname kernel: cryptomgr_test (45) used greatest stack depth: 14880 bytes left
    ...
    ```

## i2c tools

- i2cdetect

    ```console
    $ ls /dev/i2c*
    $ i2cdetect -l
    ```

- i2c configuration resides in cat /boot/config.txt

    ```console
    root@ess-hostname:~# cat /boot/config.txt | grep
    ...
    dtparam=i2c1=on
    dtparam=i2c_arm=on
    ```
