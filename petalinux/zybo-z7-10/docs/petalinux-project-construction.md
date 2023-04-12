# Petalinux Project Construction

## Petalinux project constructed from a prebuilt bsp

- source PL env settings

    ```console
    host:~/projects/zybo-z7-10$ source ~/tools/petalinux_2022_1/settings.sh
    ```

- download the '*.bsp' file from the demo release page

    - ***PetaLinux BSPs are provided in the form of installable BSP files, and include all necessary design and configuration files, pre-built and tested hardware, and software images ready for downloading on your board or for booting in the QEMU system emulation environment.***

    - bsp file can be used in initial PetaLinux project generation vs a template based project generation

    - general repo
        - https://digilent.com/reference/programmable-logic/documents/git

    - zybo z7-10 repo (includes released bsp)
        - https://github.com/Digilent/Zybo-Z7/releases/tag/10%2FPetalinux%2F2022.1-1?_ga=2.77896784.511116902.1668454546-892977042.1667254672

    - bsp zip file elements:
        - /os/hardware/system.bit
        - /os/project-spec/hw-description/system.xsa
            - system.xsa zip file elements:
                ```console
                drivers/axi_i2s_adi_v1_0/data/axi_i2s_adi.mdd
                drivers/axi_i2s_adi_v1_0/data/axi_i2s_adi.tcl
                drivers/axi_i2s_adi_v1_0/src/axi_i2s_adi.c
                drivers/axi_i2s_adi_v1_0/src/axi_i2s_adi.h
                drivers/axi_i2s_adi_v1_0/src/axi_i2s_adi_selftest.c
                drivers/axi_i2s_adi_v1_0/src/Makefile
                drivers/dynclk/data/dynclk.mdd
                drivers/dynclk/data/dynclk.tcl
                drivers/dynclk/src/ddynclk.c
                drivers/dynclk/src/ddynclk.h
                drivers/dynclk/src/ddynclk_g.c
                drivers/dynclk/src/ddynclk_selftest.c
                drivers/dynclk/src/ddynclk_sinit.c
                drivers/dynclk/src/Makefile
                drivers/PWM_v1_0/data/PWM.mdd
                drivers/PWM_v1_0/data/PWM.tcl
                drivers/PWM_v1_0/src/Makefile
                drivers/PWM_v1_0/src/PWM.c
                drivers/PWM_v1_0/src/PWM.h
                drivers/PWM_v1_0/src/PWM_selftest.c
                ps7_init.c
                ps7_init.h
                ps7_init.html
                ps7_init.tcl
                ps7_init_gpl.c
                ps7_init_gpl.h
                sysdef.xml
                system.bda
                system.hwh
                system_wrapper.bit
                xsa.json
                xsa.xml
                ```

- create project based off released BSP

    ```console
    host:~/projects/zybo-z7-10$ petalinux-create -t project -s ../bsp/Zybo-Z7-10-Petalinux-2022-1.bsp
    ```


## Builds created or modified from hdl design (xsa and bit files)

- for modifications to initial fpga design ...
    - ***The petalinux-config --get-hw-description command allows you to initialize or update a PetaLinux project with hardware-specific information from the specified Vivado® Design Suite hardware project. The components affected by this process can include FSBL configuration, U-Boot options, Linux kernel options, and the Linux device tree configuration. This workflow should be used carefully to prevent accidental and/or unintended changes to the hardware configuration for the PetaLinux project. The path used with this workflow is the directory that contains the XSA file rather than the full path to the XSA file itself. This entire option can be omitted if run from the directory that contains the XSA file.***

- place new xsa file in ../bsp/Zybo-Z7-10-Petalinux-2022-1/os/project-spec/hw-description

- config the project based on (potentially new) xsa

    ```console
    host:/bsp-odds-and-ends/petalinux/zybo-z7-10/os$ petalinux-config --get-hw-description ../bsp/Zybo-Z7-10-Petalinux-2022-1/os/project-spec/hw-description --silentconfig
    ```