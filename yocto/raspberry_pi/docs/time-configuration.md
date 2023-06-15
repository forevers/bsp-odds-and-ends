# time configuration

- tzdata support

    ```console
    root@ess-hostname:~# timedatectl list-timezones

    root@ess-hostname:~# timedatectl show
    Timezone=America/Los_Angeles
    LocalRTC=no
    CanNTP=yes
    NTP=yes
    NTPSynchronized=no
    TimeUSec=Thu 2022-04-28 10:43:16 PDT

    root@ess-hostname:~# timedatectl set-timezone Pacific/Tahiti
    root@ess-hostname:~# timedatectl show
    Timezone=Pacific/Tahiti
    LocalRTC=no
    CanNTP=yes
    NTP=yes
    NTPSynchronized=no
    TimeUSec=Thu 2022-04-28 07:48:31 -10

    root@ess-hostname:~# timedatectl set-timezone UTC
    root@ess-hostname:~# timedatectl show
    Timezone=UTC
    LocalRTC=no
    CanNTP=yes
    NTP=yes
    NTPSynchronized=no
    TimeUSec=Thu 2022-04-28 17:49:28 UTC
    ```
