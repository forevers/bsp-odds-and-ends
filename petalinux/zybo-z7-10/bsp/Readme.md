# after new hdl design ...
- place bsp file in this directory
- unzip it
- unzip its /os/project-spec/hw-description/system.xsa
- copy ./os/hardware/system.bit to $TOPDIR/os/project-spec/hw-description/
- run 'petalinux-config --get-hw-description $TOPDIR/bsp/os/project-spec/hw-description/system.xsa'