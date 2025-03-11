module envelope_generator #(parameter DATA_WIDTH = 24, parameter DEPTH = 1024)(
    input clk_pll_12_28_i,
    input rst_i,
    input [DATA_WIDTH-1:0] signal_i,
    input [4:0] attack_factor_i,
    input [4:0] release_time_i,
    input [4:0] sw_i,

    output [DATA_WIDTH-1:0] top_synth_o
);


//envelope generator controlled by onboard decoders
logic [DATA_WIDTH-1:0] sustain_level_i;
logic [DATA_WIDTH-1:0] envelope_o;
assign sustain_level_i = 16'd16384;
assign decay_time_i = 16'd16384;
adsr_envelope #(.DATA_WIDTH(DATA_WIDTH)) adsr_envelope_inst(
    .clk_i(clk_pll_12_28_i),
    .rst_i(rst_i),
    .valid_i(|sw_i),
    .attack_time_i({attack_factor_i, {(DATA_WIDTH-5){1'b0}}}), 
    .decay_time_i(decay_time_i), 
    .sustain_level_i(sustain_level_i),
    .release_time_i({release_time_i, {(DATA_WIDTH-5){1'b0}}}),
    .ready_o(),//we do not give a FUGG
    .envelope_o(envelope_o)
);

//modulator
logic [DATA_WIDTH-1:0] amp_modulator_signal_o;
amp_modulator #(.DATA_WIDTH(DATA_WIDTH)) amp_modulator_inst(
    .clk_i(clk_pll_12_28_i),
    .rst_i(rst_i),
    .valid_i(|sw_i),
    .signal_i(signal_i), //selected carrier wave
    .modulator_i(envelope_o), //envelope geenrated from adsr
    .signal_o(amp_modulator_signal_o),
    .ready_o()//we do not give a 
);


//output
assign top_synth_o = amp_modulator_signal_o;


endmodule
