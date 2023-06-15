# overlayfs

- verify /etc overlayfs-etc

    ```console
    root@ess-hostname:~# ls -l /data/overlay-etc/work/
    d---------    2 root     root          4096 Jan  1  1970 work
    root@ess-hostname:~# ls -l /data/overlay-etc/upper/
    -rw-r--r--    1 root     root           695 Apr 28 17:42 group
    -rw-r--r--    1 root     root           681 Mar  9  2018 group-
    -r--------    1 root     root           582 Apr 28 17:42 gshadow
    -r--------    1 root     root           570 Mar  9  2018 gshadow-
    -rw-r--r--    1 root     root          3687 Apr 28 17:42 ld.so.cache
    -rw-r--r--    1 root     root            33 Apr 28 17:42 machine-id

    root@ess-hostname:~# echo ess-hostname-overlay  > /data/overlay-etc/upper/hostname

    root@ess-hostname:~# cat /etc/hostname
    ess-hostname-overlay

    root@ess-hostname:~# shutdown -r now
    ...

    root@ess-hostname-overlay:~# ls -l /data/overlay-etc/upper/
    -rw-r--r--    1 root     root           695 Apr 28 17:42 group
    -rw-r--r--    1 root     root           681 Mar  9  2018 group-
    -r--------    1 root     root           582 Apr 28 17:42 gshadow
    -r--------    1 root     root           570 Mar  9  2018 gshadow-
    -rw-r--r--    1 root     root            21 Apr 28 19:37 hostname
    -rw-r--r--    1 root     root          3687 Apr 28 17:42 ld.so.cache
    -rw-r--r--    1 root     root            33 Apr 28 17:42 machine-id

    root@ess-hostname-overlay:~# rm -rf /data/overlay-etc/

    root@ess-hostname:~# shutdown -r now
    ...

    root@ess-hostname:~#
    ```

## References
- [linux overlayfs doc](https://docs.kernel.org/filesystems/overlayfs.html)
- [yocto overlayfs-etc class](https://docs.yoctoproject.org/ref-manual/classes.html#overlayfs-etc-bbclass)
- [yocot overlayfs class](https://git.yoctoproject.org/poky/plain/meta/classes-recipe/overlayfs.bbclass)
- [overlayfs-etc IMAGE_FEATURE](https://git.yoctoproject.org/poky/plain/meta/files/overlayfs-etc-preinit.sh.in)
