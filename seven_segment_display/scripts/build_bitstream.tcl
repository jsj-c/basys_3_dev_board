# build settings
set design_name "ss_driver"
set board_name "basys_3"
set fpga_part "xc7a35ticpg236-1L"

# set reference directories for source files
set src_dir     [file normalize "./src"]
set build_dir   [file normalize "./build"]
set origin_dir  [file normalize "../"]

# read design sources
read_vhdl -library srcLib [ glob ${src_dir}/*.vhd ]


# read constraints
read_xdc "${origin_dir}/${board_name}.xdc"

# synth
synth_design -top "top_${design_name}" -part ${fpga_part}

# place and route
opt_design
place_design
route_design

# write bitstream
file mkdir ${build_dir}
write_bitstream -force "${build_dir}/${design_name}.bit"