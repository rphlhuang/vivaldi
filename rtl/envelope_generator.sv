module envelope_generator #(parameter DATA_WIDTH = 24, parameter DEPTH = 1024)(
    input clk_pll_12_28_i,
    input clk_slow_i,
    input rst_i,
    input [DATA_WIDTH-1:0] signal_i,
    input [4:0] attack_factor_i,
    input [4:0] release_time_i,
    input [0:0] valid_i,

    output [DATA_WIDTH-1:0] top_synth_o
);


//envelope generator controlled by onboard decoders
logic [DATA_WIDTH-1:0] sustain_level_i, decay_time_i;
logic [DATA_WIDTH-1:0] envelope_o;
assign sustain_level_i = 16'd16383;
assign decay_time_i = 16'd16384;

adsr_envelope #(.DATA_WIDTH(DATA_WIDTH)) adsr_envelope_inst(
    .clk_i(clk_slow_i),
    .rst_i(rst_i),
    .valid_i(valid_i),
    .attack_time_i({{3{attack_factor_i}}, 1'b1}), 
    .decay_time_i(decay_time_i), 
    .sustain_level_i(sustain_level_i),
    .release_time_i({{3{release_time_i}}, 1'b1}),
    .ready_o(),//we do not give a FUGG
    .envelope_o(envelope_o)
);

//modulator
logic [DATA_WIDTH-1:0] amp_modulator_signal_o;
amp_modulator #(.DATA_WIDTH(DATA_WIDTH)) amp_modulator_inst(
    .clk_i(clk_pll_12_28_i),
    .rst_i(rst_i),
    .valid_i(valid_i),
    .signal_i(signal_i), //selected carrier wave
    .modulator_i(envelope_o), //envelope geenrated from adsr
    .signal_o(amp_modulator_signal_o),
    .ready_o()//we do not give a 
);


//output
assign top_synth_o = (valid_i) ? amp_modulator_signal_o : signal_i;


endmodule

