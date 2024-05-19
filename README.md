# Basys 3 Dev Board projects

This repo contains VHDL code which builds for the Digilent BASYS 3 dev board.

## Projects

### Seven Segment Display

The seven_segment_display subdirectory contains a driver for the display which takes in an array of unsigned numbers (1 to 9) which it will then use to drive the outputs `segment` and `selector`. These outputs are wired up in the top level file to the `seg` and `an` ports from the `basys_3.xdc` file.

The top level file currently implements some simple logic which counts up every second and sends the digits of the current number to the display driver. In theory, with the driver being generic, any sort of number-based logic could be implemented and its output displayed using the driver.

## Building

All projects are built using Vivado tcl files which are wrapped in make files.

To build any project run `make` in the project's subdirectory.
```bash
$ make -C seven_segment_display
```

There is also a make rule to help flash the bitstreams onto the board. This requires that the board is connected to your dev machine.

To flash any project's bitstream onto a board run `make flash` in the project's subdirectory
```bash
$ make -C seven_segment_display flash
```

All of a project's build products can be removed using `make clean`.