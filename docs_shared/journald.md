# journald

- verify systemd journald installation

    - journald log file location
        ```console
        root@ess-hostname:~# cat /run/log/journal/de0c16ccdb00407ab5ffdf0ac63d5e5b/system.journal
        ```

    - check journald file persistence configuration
        ```console
        root@ess-hostname:~# cat /etc/systemd/journald.conf | grep Storage
        ```

    - entire log
        ```console
        root@ess-hostname:~# journalctl
        ```

    - current boot only log
        ```console
        root@ess-hostname:~# journalctl -b
        ```

    - current boot only kernel log
        ```console
        root@ess-hostname:~# journalctl -k -b
        ```

    - logs specific to a service
        ```console
        root@ess-hostname:~# journalctl -u systemd-networkd.service
        ```

    - restart service (i.e. systemd-networkd.service after conf edits)
        ```console
        root@ess-hostname:~# systemctl restart systemd-networkd.service
        ```
    - restart os
        ```console
        root@ess-hostname:~# systemctl start reboot.target
        ```

- verify systemd networkctl installation

    - verify networkctl device listing
        ```console
        root@ess-hostname:~# networkctl list
        IDX LINK  TYPE     OPERATIONAL SETUP
        1 lo    loopback carrier     unmanaged
        2 eth0  ether    no-carrier  configuring
        3 wlan0 wlan     no-carrier  configuring
        ```

- verify systemd journald installation

    - journald log file location
        ```console
        root@ess-hostname:~# cat /run/log/journal/de0c16ccdb00407ab5ffdf0ac63d5e5b/system.journal
        ```

    - check journald file persistence configuration
        ```console
        root@ess-hostname:~# cat /etc/systemd/journald.conf | grep Storage
        ```

    - entire log
        ```console
        root@ess-hostname:~# journalctl
        ```

    - current boot only log
        ```console
        root@ess-hostname:~# journalctl -b
        ```

    - current boot only kernel log
        ```console
        root@ess-hostname:~# journalctl -k -b
        ```

    - logs specific to a service
        ```console
        root@ess-hostname:~# journalctl -u systemd-networkd.service
        ```
