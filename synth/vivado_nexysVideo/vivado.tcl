# start_gui

create_project nexysVideo nexysVideo -part xc7a200tlsbg484-2L

# add_files -norecurse {}
# set_property file_type {Memory File} [get_files -all]

add_files -norecurse {
 ../nexysVideo.sv
}
add_files -fileset constrs_1 -norecurse {
 ../Nexys-Video-Master.xdc
 ../constraints.xdc
}

# Sets top level
set_property top nexysVideo [current_fileset]

# Generate Clock
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name mmcm_100_to_50
set_property -dict [list \
  CONFIG.CLK_OUT1_PORT {clk_50} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {50} \
  CONFIG.PRIMARY_PORT {clk_100} \
  CONFIG.USE_LOCKED {false} \
  CONFIG.USE_RESET {false} \
] [get_ips mmcm_100_to_50]

# Run Synthesis
set_property STEPS.SYNTH_DESIGN.ARGS.FLATTEN_HIERARCHY none [get_runs synth_1]
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Run PNR
launch_runs impl_1
wait_on_run impl_1

# Create Bitstream
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1

exit
