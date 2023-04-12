# Xilinx Tools Installation

- Note: tool installation on Ubuntu 22.04 (not formally sported by Xilinx)

## Vitis/Vivado installation

- references:

    - https://digilent.com/reference/programmable-logic/zybo-z7/demos/petalinux
    - https://digilent.com/reference/programmable-logic/guides/installing-vivado-and-vitis
    
- 2022.1 is latest support toolchain version fpr zybo z7 platforms:

    - https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2022-1.html

- install the tools to default location /tools/Xilinx. only 7 series devices required for zybo.

    ```console
    chmod +x Xilinx_Unified_2022.1_0420_0327_Lin64.bin && sudo ./Xilinx_Unified_2022.1_0420_0327_Lin64.bin
    ```

- installation includes:

    - vivado - hdl
    - vitis - vitis hls, sw sdk

- see ug973 for cable driver instructions
    
    ```console
    host:/tools/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/install_script/install_drivers$ sudo ./install_drivers
    INFO: Installing cable drivers.
    ...
    CRITICAL WARNING: Cable(s) on the system must be unplugged then plugged back in order for the driver scripts to update the cables.
    steve@embedify:/tools/Xilinx/Vivado/2022.1/data/xicom/cable_drivers/lin64/
    ```

- digilent board files

    - https://github.com/Digilent/vivado-boards/archive/master.zip?_ga=2.26386043.719103120.1668636885-892977042.1667254672
    - vivado-boards-master.zip
        - copy its new/board_files folder to /tools/Xilinx/Vivado/2022.1/data/boards/board_files

- digilent zybo-z7 project repo at https://github.com/Digilent/Zybo-Z7-HW/tree/10/Petalinux/master

    ```console
    $ git clone -b 10/Petalinux/master --recursive git@github.com:Digilent/Zybo-Z7-HW.git
    ```

- [reconstructing the project](https://digilent.com/reference/programmable-logic/documents/git?redirect=1)

    - *The Vivado project must be recreated from its source before use. To create the project, first launch the supported version of Vivado1). Open Vivado's TCL console, and enter the command below. This will recreate and open the Vivado project.*
        ```console
        set argv ""; source {local root repo}/hw/scripts/digilent_vivado_checkout.tcl
        ```
    - Note: the digilent_vivado_checkout.tcl does not appear to be in the git repo

- verify install

    - vivado launch
        ```console
        $ source /tools/Xilinx/Vivado/2022.1/settings64.sh
        $ vivado
        ```

    - vitis launch
        ```console
        $ source /tools/Xilinx/Vitis/2022.1/settings64.sh
        $ vitis
        ```

## PetaLinux installation

- 2022.1 installer: https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools/2022-1.html

- Ubuntu 22.01 host required install gcc-multilib package in order to install PL

    ```console
    host:~/tools$ ./petalinux-v2022.1-04191534-installer.run --dir ~/tools/petalinux_2022_1
    ```