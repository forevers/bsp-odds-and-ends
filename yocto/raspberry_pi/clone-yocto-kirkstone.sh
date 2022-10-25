#!/usr/bin/env bash

set -e

usage() {
  echo "description: initial yocto layer clones"
  echo "usage: $0 <target-directory>"
  echo ""
  echo "example: $0 ./ess"
}

if [ $# -ne 1 ]; then
  usage
  exit 1
fi

directory=$1

if [ -e "${directory}" ]; then
  echo "error: \"${directory}\" already exists"
  usage
fi

# create the directory
mkdir -p "${directory}/sources" && cd "${directory}"

# clone poky, rpi, and oe utilities
git clone -b kirkstone git://git.yoctoproject.org/poky.git sources/poky
git clone -b kirkstone git://git.yoctoproject.org/meta-raspberrypi.git sources/meta-raspberrypi
git clone -b kirkstone https://github.com/openembedded/meta-openembedded.git sources/meta-openembedded

# original
# git clone -b kirkstone https://github.com/agherzan/meta-raspberrypi.git sources/meta-raspberrypi

# yoctoproject raspberry rpi repo
# https://www.interelectronix.com/yocto-build-raspberry-pi-4-docker-environment.html
# git://git.yoctoproject.org/meta-raspberrypi

echo "Done, type \"cd ${directory} && . ./sources/poky/oe-init-build-env" to create the build environment"