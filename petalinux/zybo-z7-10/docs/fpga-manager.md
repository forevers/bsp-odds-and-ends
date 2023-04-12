# FPGA Manager (see ug1144)

- CONFIG_SUBSYSTEM_FPGA_MANAGER enable the fpga manager

- 'FPGA manager overrides all the options of the device tree overlay. Device Tree Overlay will come into play only when FPGA manager is not selected.'

- 'The FPGA manager provides an interface to Linux for configuring the programmable logic (PL). It packs the dtbos and bitstreams into the /lib/firmware/xilinx directory in the root file system.'

- 'Generates the pl.dtsi nodes as a dt overlay (dtbo).'

- 'fpgautil linux utility to load PL at runtime'