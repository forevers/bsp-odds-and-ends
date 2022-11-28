# systemd

- list currently running services
    ```console
    root@ess-hostname:~# systemctl --type=service
    ```

- list active units
    ```console
    root@ess-hostname:~# systemctl list-units
    ```

- list all units
    ```console
    root@ess-hostname:~# systemctl list-units --all
    ```

- list service dependencies
    ```console
    root@ess-hostname:~# systemctl list-dependencies systemd-networkd.service
    root@ess-hostname:~# systemctl list-dependencies -all systemd-networkd.service
    ```

- query service status
    ```console
    root@ess-hostname:~# systemctl list-units | grep service
    root@ess-hostname:~# systemctl status systemd-networkd.service
    ```

- query service config file
    ```console
    root@ess-hostname:~# systemctl cat systemd-networkd.service
    ```

- edit service config rile
    ```console
    root@ess-hostname:~# systemctl edit --full systemd-networkd.service
    ```

- query service properties
    ```console
    root@ess-hostname:~# systemctl show systemd-networkd.service
    ```

- inspect systemd targets (similar to sysv run levels)

    - get boot target
        ```console
        root@ess-hostname:~# systemctl get-default
        ```

    - set a new boot target
        ```console
        root@ess-hostname:~# systemctl set-default <a new target>
        ```

    - list all possible targets. note sysv runlevel targets aliased to systemd targets.
        ```console
        root@ess-hostname:~# systemctl list-unit-files --type=target
        ```

- system control commands
    ```console
    root@ess-hostname:~# systemctl poweroff
    root@ess-hostname:~# systemctl reboot
    root@ess-host
- list currently running services
    ```console
    root@ess-hostname:~# systemctl --type=service
    ```

- list active units
    ```console
    root@ess-hostname:~# systemctl list-units
    ```

- list all units
    ```console
    root@ess-hostname:~# systemctl list-units --all
    ```

- list service dependencies
    ```console
    root@ess-hostname:~# systemctl list-dependencies systemd-networkd.service
    root@ess-hostname:~# systemctl list-dependencies -all systemd-networkd.service
    ```

- query service status
    ```console
    root@ess-hostname:~# systemctl list-units | grep service
    root@ess-hostname:~# systemctl status systemd-networkd.service
    ```

- query service config file
    ```console
    root@ess-hostname:~# systemctl cat systemd-networkd.service
    ```

- edit service config rile
    ```console
    root@ess-hostname:~# systemctl edit --full systemd-networkd.service
    ```

- query service properties
    ```console
    root@ess-hostname:~# systemctl show systemd-networkd.service
    ```

- inspect systemd targets (similar to sysv run levels)

    - get boot target
        ```console
        root@ess-hostname:~# systemctl get-default
        ```

    - set a new boot target
        ```console
        root@ess-hostname:~# systemctl set-default <a new target>
        ```

    - list all possible targets. note sysv runlevel targets aliased to systemd targets.
        ```console
        root@ess-hostname:~# systemctl list-unit-files --type=target
        ```

- system control commands
    ```console
    root@ess-hostname:~# systemctl poweroff
    root@ess-hostname:~# systemctl reboot
    root@ess-hostname:~# systemctl rescue
    ```

- restart service (i.e. systemd-networkd.service after conf edits)
    ```console
    root@ess-hostname:~# systemctl restart systemd-networkd.service
    ```

- verify networkctl device listing
    ```console
    root@ess-hostname:~# networkctl list
    IDX LINK  TYPE     OPERATIONAL SETUP
    1 lo    loopback carrier     unmanaged
    2 eth0  ether    no-carrier  configuring
    3 wlan0 wlan     no-carrier  configuring
    ```
