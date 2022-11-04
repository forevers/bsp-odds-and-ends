#!/bin/sh

start() {
    /usr/share/qt5everywheredemo-1.0/QtDemo
}

stop() {
    /usr/bin/killall QtDemo
}

case "$1" in
    start|restart)
        echo "Starting QtDemo"
        stop
        start
        ;;
    stop)
        echo "Stopping QtDemo"
        stop
        ;;
esac