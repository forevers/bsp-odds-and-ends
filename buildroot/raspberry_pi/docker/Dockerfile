# Dockerfile build :
#   - docker build -t ess/buildroot-builder .
#   - results in "Successfully tagged ess/buildroot-builder:latest"
# Usage :
#   - keep stdin open, psudeo tty
#       --rm    : Automatically remove the container when it exits
#       -t      : Allocate a pseudo-TTY
#       -i      : Keep STDIN open even if not attached
#       docker run -ti --rm ess/buildroot-builder
#           cd ~/buildroot-2023.05
#       docker run -ti --rm -v <host br2-external path>:~/br2_external ess/buildroot-builder

FROM ubuntu:22.04

RUN apt-get update &&  DEBIAN_FRONTEND=noninteractive apt-get install -y -q \
 git \
 vim \
 make \
 gcc \
 autoconf \
 texinfo \
 file \
 g++ \
 unzip \
 bison \
 flex \
 m4 \
 build-essential \
 gettext \
 libncursesw5 \
 libncursesw5-dev \
 fakeroot \
 wget \
 rename \
 cpio \
 rsync \
 bc \
 device-tree-compiler \
 u-boot-tools \
 libssl-dev \
 libtool \
 binutils \
 time \
&& apt-get clean \
&& rm -rf /var/lib/apt/lists/*

# https://git.buildroot.net/buildroot/refs/tags
# Tag: 2023.05, Download equivalent: buildroot-2023.05.tar.bz2
RUN mkdir -p $HOME/buildroot && \
 cd $HOME/buildroot && \
 wget https://buildroot.org/downloads/buildroot-2023.05.tar.gz && \
 tar xvzf buildroot-2023.05.tar.gz && \
rm buildroot-2023.05.tar.gz
