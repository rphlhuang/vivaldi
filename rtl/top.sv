module top #(parameter DATA_WIDTH = 16, parameter DEPTH = 1024)(
    input clk_pll_12_28_i,
    input rst_i,
    input [3:0] sw_i,
    input [3:0] kpyd_row_i,
    input [3:0] kypd_row_i,
    input [3:0] JA_i,//Jx_i[3] pmod switch input
    input [3:0] JB_i,
    input [3:0] JC_i,


    output [DATA_WIDTH-1:0] top_synth_o
);

//encoder inst 1 debouncer
wire JA_0_i_debounced, JA_1_i_debounced;
encoder_debounce encoder_JA_debounce_inst(
    .clk(clk_i),
    .A_i(JA_i[0]),
    .B_i(JA_i[1]),
    .A_o(JA_0_i_debounced),
    .B_o(JA_1_i_debounced)
);

//encoder instance
wire [3:0] encoder_JA_o;
encoder encoder_JA_inst(
    .clk(clk_i),
    .A_i(JA_0_i_debounced),
    .B_i(JA_1_i_debounced),
    .BTN_i(JA_i[2]),
    .EncPos_o(encoder_JA_o),
    .LED_o()
);

//encoder inst 2 debouncer
wire JB_0_i_debounced, JB_1_i_debounced;
encoder_debounce encoder_JB_debounce_inst(
    .clk(clk_i),
    .A_i(JB_i[0]),
    .B_i(JB_i[1]),
    .A_o(JB_0_i_debounced),
    .B_o(JB_1_i_debounced)
);

//encoder instance
wire [3:0] encoder_JB_o;
encoder encoder_JB_inst(
    .clk(clk_i),
    .A_i(JB_0_i_debounced),
    .B_i(JB_1_i_debounced),
    .BTN_i(JB_i[2]),
    .EncPos_o(encoder_JB_o),
    .LED_o()
);

//encoder inst 3 debouncer
wire JC_0_i_debounced, JC_1_i_debounced;
encoder_debounce encoder_JC_debounce_inst(
    .clk(clk_i),
    .A_i(JC_i[0]),
    .B_i(JC_i[1]),
    .A_o(JC_0_i_debounced),
    .B_o(JC_1_i_debounced)
);

//encoder instance
wire [3:0] encoder_JC_o;
encoder encoder_JC_inst(
    .clk(clk_i),
    .A_i(JC_0_i_debounced),
    .B_i(JC_1_i_debounced),
    .BTN_i(JC_i[2]),
    .EncPos_o(encoder_JC_o),
    .LED_o()
);

//sin wave generator
logic signed [DATA_WIDTH-1:0] sine_wave_out_w;
sinusoid_wave #(.width_p(DATA_WIDTH), .depth_p(DEPTH)) sine_wave_inst (
  .clk_i(clk_pll_12_28_i),
  .reset_i(rst_i),
  .addr_i(shared_addr),
  .data_o(sine_wave_out_w),
  .ready_i(1'b1),
  .valid_i(sw_i[0]),
  .valid_o()//we do not give a 
);

//square wave generator
logic signed [DATA_WIDTH-1:0] square_wave_out_w;
square_wave #(.width_p(24), .depth_p(DEPTH))
square_wave_inst (
  .clk_i(clk_pll_12_28_i),
  .reset_i(rst_i),
  .addr_i(shared_addr),
  .data_o(square_wave_out_w),
  .ready_i(1'b1),
  .valid_i(sw_i[1]),
  .valid_o()//we do not give a 
);

//triangle wave generator
logic signed [DATA_WIDTH-1:0] triangle_wave_out_w;
triangle_wave #(.width_p(24), .depth_p(DEPTH)) triangle_wave_inst (
  .clk_i(clk_pll_12_28_i),
  .reset_i(rst_i),
  .addr_i(shared_addr),
  .data_o(triangle_wave_out_w),
  .ready_i(1'b1),
  .valid_i(sw_i[2]),
  .valid_o()//we do not give a 
);

//sawtooth wave generator
logic signed [DATA_WIDTH-1:0] sawtooth_wave_out_w;
sawtooth_wave #(.width_p(24), .depth_p(DEPTH)) saw_wave_inst (
  .clk_i(clk_pll_12_28_i),
  .reset_i(rst_i),
  .addr_i(shared_addr),
  .data_o(sawtooth_wave_out_w),
  .ready_i(1'b1),
  .valid_i(sw_i[3]),
  .valid_o()//we do not give a 
);

//wave output selector
logic signed [DATA_WIDTH-1:0] mux_wav_o;
always_comb begin : comb_signals
  case (sw_i)
    4'b0001: mux_wav_o = sine_out_w;
    4'b0010: mux_wav_o = square_sel_o;
    4'b0100: mux_wav_o = tri_sel_o;
    4'b1000: mux_wav_o = saw_sel_o;
    default: mux_wav_o = '0; 
  endcase
end

//envelope generator controlled by onboard decoders
logic [DATA_WIDTH-1:0] sustain_level_i;
logic [DATA_WIDTH-1:0] envelope_o;
assign sustain_level_i = 16'd16384;
adsr_envelope #(.DATA_WIDTH(DATA_WIDTH)) adsr_envelope_inst(
    .clk_i(clk_pll_12_28_i),
    .rst_i(rst_i),
    .valid_i(|sw_i),
    .attack_time_i({(DATA_WIDTH-4){1'b0}, encoder_JA_o}), 
    .decay_time_i({(DATA_WIDTH-4){1'b0}, encoder_JB_o}), 
    .sustain_level_i(sustain_level_i),
    .release_time_i({(DATA_WIDTH-4){1'b0}, encoder_JC_o}),
    .ready_o(),//we do not give a FUGG
    .envelope_o(envelope_o)
);

//modulator
logic [DATA_WIDTH-1:0] amp_modulator_signal_o;
amp_modulator #(.DATA_WIDTH(DATA_WIDTH)) amp_modulator_inst(
    .clk_i(clk_pll_12_28_i),
    .rst_i(rst_i),
    .valid_i(|sw_i),
    .signal_i(mux_wav_o), //selected carrier wave
    .modulator_i(envelope_o), //envelope geenrated from adsr
    .signal_o(amp_modulator_signal_o),
    .ready_o()//we do not give a 
);

//output
assign top_synth_o = amp_modulator_signal_o;

endmodule
