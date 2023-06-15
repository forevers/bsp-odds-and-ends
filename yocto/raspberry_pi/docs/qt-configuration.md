# QT Configuration

## meta-toolchain-qt5 SDK Creation

- build sdk
    ```console
    pokyuser:/workdir/bsp/build-rpi-ess$ bitbake meta-toolchain-qt5
    ```

- install sdk
    ```console
    host$ ./tmp/deploy/sdk/poky-glibc-x86_64-meta-toolchain-qt5-cortexa72-raspberrypi4-64-ess-toolchain-1.0.0.sh
    ```

- run following to configure sdk environment at a specified location
    ```console
    . <path to installed meta-toolchain-qt5 sdk>/environment-setup-cortexa72-poky-linux
    ```

## qtcreator Configuration

- identify Qt version running on target
    ```console
    root@ess-hostname:~# qmake --version
    QMake version 3.1
    Using Qt version 5.15.3 in /usr/lib
    ```

- configure Qt target device in qtcreator

    ``` console
    File > New File or Project ...

    Project Name: ess-sdk
    Build System: qmake
    Minimal Required Qt Version: 5.15

    Kit Selection > Manage > Add
        ess-yocto
        Device TYpe: Generic Linux Device
        Device > Manage > Add >Devices > Add > Generic Linux Device > Start Wizard
            ess-rpi / <ip> / root
            > next
            select private key file (rsa)
            > Deploy Public Key
            > Finish

    ess-rpi device now configured
    ```

- configure compilers

## QT5 Testing

    ```console
    root@ess-hostname:~# qt5-opengles2-test -platform eglfs
    root@ess-hostname:~# /usr/share/qt5everywheredemo-1.0/QtDemo -platform eglfs
    root@ess-hostname:~# qmlscene /usr/share/qt5ledscreen-1.0/example_billboard.qml -platform eglfs
    root@ess-hostname:~# qmlscene /usr/share/qt5ledscreen-1.0/example_combo.qml -platform eglfs
    root@ess-hostname:~# qmlscene /usr/share/qt5ledscreen-1.0/example_hello.qml -platform eglfs
    root@ess-hostname:~# /usr/share/qt5nmapcarousedemo-1.0/Qt5_NMap_CarouselDemo -platform eglfs
    root@ess-hostname:~# /usr/share/qt5nmapper-1.0/Qt5_NMapper -platform eglfs
    root@ess-hostname:~# qmlscene /usr/share/quitindicators-1.0.1/qml/main.qml -platform eglfs
    root@ess-hostname:~# qmlscene /usr/share/qtsmarthome-1.0.1/qml/main.qml -platform eglfs
    ```


## References

- [qt5 in linux](https://doc.qt.io/qt-5/embedded-linux.html)
- [qt6 in linux](https://doc.qt.io/qt-6/embedded-linux.html)
- [qt5/6 platform abstraction](https://doc.qt.io/qt-5/qpa.html)
- [graphical backend managers](https://doc.qt.io/qt-5/embedded-linux.html#embedded-eglfs)
- [graphical backend managers](https://doc.qt.io/qt-5/embedded-linux.html#linuxfb)
- [qpaintdevice](https://doc.qt.io/qt-6.2/qpaintdevice.html (xcb x11))
- [linux x11](https://doc.qt.io/qt-5/linux.html)
- [qpa](https://doc.qt.io/qt-6/qpa.html)
- [yocto rpi index](https://git.yoctoproject.org/meta-raspberrypi)
