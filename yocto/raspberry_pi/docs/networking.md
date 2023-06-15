# Networking documentation

## debugging

root@ess-hostname:~# systemctl mask wpa_supplicant.service
Created symlink /etc/systemd/system/wpa_supplicant.service -> /dev/null.

root@ess-hostname:~# ls -l /etc/systemd/system | grep wpa
lrwxrwxrwx 1 root root    9 Jun 15 09:45 wpa_supplicant.service -> /dev/null





root@ess-hostname:~# nmcli con edit eth0
Error: Unknown connection 'eth0'.

nmcli connection add type ethernet con-name eth0

root@ess-hostname:/# cat /etc/NetworkManager/system-connections/eth0.nmconnection
[connection]
id=eth0
uuid=5d5395dd-6a4d-492a-ba61-707b5bfd3a1e
type=ethernet

[ethernet]

[ipv4]
method=auto

[ipv6]
addr-gen-mode=stable-privacy
method=auto

[proxy]

Q: NOT SURE WHERE THIS INFO RESIDES IN FS?

root@ess-hostname:/# nmcli con up eth0
Error: Connection activation failed: No suitable device found for this connection (device lo
 not available because device is strictly unmanaged).

NOTE: NETWORKIN SERVICES
  network-manager.service                                                                           loaded active exited    >
  NetworkManager.service
  systemd-network-generator.service
systemd-resolved.service




## Network Manager

The NetworkManager service manages the ethernet and wifi interfaces. The install nmcli command line interface provides a means for created connection profiles to the various networking interfaces.

### Network Manager state

```
root@ess-hostname:~# cat /var/lib/NetworkManager/NetworkManager.state
[main]
NetworkingEnabled=true
WirelessEnabled=true
WWANEnabled=true

root@ess-hostname:~# nmcli device
DEVICE  TYPE      STATE      CONNECTION
eth0    ethernet  connected  eth0
wlan0   wifi      connected  <SSID>
lo      loopback  unmanaged  --
```

## NetworkManager d-bus

/usr/share/dbus-1/system.d/org.freedesktop.NetworkManager.conf

### NetworkManager.conf directories

NetworkManager configuration is controlled by NetworkManager.conf configuration files which can be located in several locations such as:
    ```
    /usr/lib/NetworkManager/conf.d
    /etc/NetworkManager/conf.d
    ```

See yocto/raspberry_pi/bsp/sources/meta-ess/recipes-connectivity/networkmanager for config file customization.

### NetworkManager interface connection files
    ```
    root@ess-hostname:~# ls -l /etc/NetworkManager/system-connections/
    total 8
    -rw------- 1 root root 289 Jun 14 14:55 '<SSID>.nmconnection'
    -rw------- 1 root root 167 Apr 28  2022  eth0.nmconnection
    ```

### nmcli utility

- List WAPs
    ```
    nmcli -c no dev wifi
    ```

- Connect to SSID or BSSID. Creates
    ```
    nmcli -c no dev wifi connect <SSID_or_BSSID> password <password>
    ```

- Show password cached for the above secure connection type
    ```
    nmcli connection show <SSID> -s | grep psk
    ```

- Disconnect link
    ```
    nmcli device disconnect wlan0
    ```

- Connect connection file to interface
    ```
    nmcli -p con up "connectionfile_prefix" ifname wlan0
    ```

- Connect using profile.
    ```
    nmcli connection up <profile name>
    ```

- Delete profile on RW root filesystem.
    ```
    nmcli connection delete <profile name>
    ```

- List network device states.
    ```
    nmcli device
    ```

- Wifi Radio off/on state persists through reboots.
    ````
    nmcli radio wifi off
    nmcli radio wifi on
    ````

## ifconfig utility

- disable/enable eth link
    ```
    sudo ifconfig eth0 down
    sudo ifconfig eth0 up
    ```

## iperf utility

1. Disable port firewall and start iperf on server
    ```
    sudo ufw allow 7575
    iperf3 -s -p 7575
    ```

1. Start client iperf to server
    ```
    iperf3 -c <iperf server> -p 7575
    ```

1. Enable firewall
    ```
    sudo ufw deny 7575
    ```

## iw utility

- List WAPs
    ```
    iw list
    ```

- Scan for WAPs
    ```
    iw scan
    ```

- Link status
    ```
    iw dev wlan0 link
    ```

- Link statistics
    ```
    iw dev wlan0 station dump
    ```

## References
- https://networkmanager.dev/docs/api/latest/
- https://developer-old.gnome.org/NetworkManager/stable/NetworkManager.conf.html
- https://wiki.archlinux.org/title/NetworkManager
- https://wireless.wiki.kernel.org/en/users/documentation/iw
