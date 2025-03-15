start_gui

create_project nexysVideo nexysVideo -part xc7a200tlsbg484-2L -force

# add_files -norecurse {}
# set_property file_type {Memory File} [get_files -all]

add_files -norecurse {
  ../nexysVideo.sv
}
add_files -norecurse [glob -nocomplain ../../../rtl/*]

add_files -fileset constrs_1 -norecurse {
 ../Nexys-Video-Master.xdc
 ../constraints.xdc
}

# Sets top level
set_property top nexysVideo [current_fileset]

# Generate Clock
create_ip -name clk_wiz -vendor xilinx.com -library ip -version 6.0 -module_name clk_wizard
set_property -dict [list \
  CONFIG.CLK_OUT1_PORT {clk_12} \
  CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {12.28879} \
  CONFIG.PRIMARY_PORT {clk_100} \
  CONFIG.USE_LOCKED {false} \
  CONFIG.USE_RESET {false} \
] [get_ips clk_wizard]

#dsp48e1 ip macro, tcl log generated from vivado ip catalog
create_ip -name dsp_macro -vendor xilinx.com -library ip -version 1.0 -module_name xbip_dsp48_macro_0
set_property -dict [list \
CONFIG.instruction1 {B*(A+D)} \
CONFIG.pipeline_options {By_Tier} \
CONFIG.tier_3 {true} \
CONFIG.dreg_3 {true} \
CONFIG.areg_3 {true} \
CONFIG.areg_4 {false} \
CONFIG.breg_3 {true} \
CONFIG.breg_4 {false} \
CONFIG.creg_3 {false} \
CONFIG.creg_4 {false} \
CONFIG.creg_5 {false} \
CONFIG.mreg_5 {false} \
CONFIG.preg_6 {false} \
CONFIG.d_width {18} \
CONFIG.d_binarywidth {0} \
CONFIG.a_width {18} \
CONFIG.a_binarywidth {0} \
CONFIG.b_width {18} \
CONFIG.b_binarywidth {0} \
CONFIG.concat_width {48} \
CONFIG.concat_binarywidth {0} \
CONFIG.c_binarywidth {0} \
CONFIG.pcin_binarywidth {0} \
CONFIG.p_full_width {36} \
CONFIG.p_width {36} \
CONFIG.p_binarywidth {0} \
] [get_ips xbip_dsp48_macro_0]

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

# Open Hardware Manager
open_hw_manager

# Connect to the FPGA
connect_hw_server
open_hw_target

# Set the device (Auto-detect)
set device [lindex [get_hw_devices] 0]
refresh_hw_device -update_hw_probes false $device

# Program the FPGA with the generated bitstream
set bitstream [file normalize "nexysVideo/nexysVideo.runs/impl_1/nexysVideo.bit"]
set_property PROGRAM.FILE $bitstream $device
program_hw_devices $device

# Close the hardware session
close_hw_target
disconnect_hw_server
close_hw_manager


#close_project
#exit
