module nexysVideo (
    input [0:0] sys_clk,
    input [0:0] btnC, // reset
    input [3:0] sw, // For selecting wave

    // I2C Config Interface
    inout [0:0] adau1761_cclk,
    inout [0:0] adau1761_cout,

    // Audio stuff
    input [0:0] ac_adc_sdata,
    output [0:0] ac_mclk,
    output [0:0] ac_dac_sdata,
    output [0:0] ac_bclk,
    output [0:0] ac_lrclk,

    output [3:0] led
);

wire logic rst_n = btnC;

logic clk_50;
mmcm_100_to_50 pll (
    .clk_100(sys_clk),
    .clk_50(clk_50)
);


// Instantiate the sine wave generator
wire [23:0] sine_out_w;
wire sine_valid_w;

sinusoid
#(.width_p(24), .sampling_freq_p(44.1 * 10 ** 3), .note_freq_p(440.0))
sine_wave_inst
(
    .clk_i(sys_clk),
    .reset_i(rst_n),
    .ready_i(1'b1),
    .data_o(sine_out_w),
    .valid_o(sine_valid_w)
);

// Audio data busses
wire [23:0] in_audioL;
wire [23:0] in_audioR;
wire [23:0] out_audioL;
wire [23:0] out_audioR;

codec_init
#()
codec_init_inst
(
    .clk(sys_clk),
    .rst(rst_n),
    .sda(adau1761_cout),
    .scl(adau1761_cclk)
);

assign led[3:0] = sw[3:0];

// Send sine wave output to DAC instead of passthrough
assign out_audioL = sw[0] ? sine_out_w : in_audioL;
assign out_audioR = sw[0] ? sine_out_w : in_audioR;

i2s_ctrl
#()
i2s_ctrl_inst
(
    .CLK_I(clk_50),
    .RST_I(rst_n),
    .EN_TX_I(1'b1),
    .EN_RX_I(1'b1),
    .FS_I(4'b0001),
    .MM_I(1'b0),
    .D_L_I(out_audioL),
    .D_R_I(out_audioR),
    .D_L_O(),
    .D_R_O(),
    .BCLK_O(ac_bclk),
    .LRCLK_O(ac_lrclk),
    .SDATA_O(ac_dac_sdata),
    .SDATA_I(ac_adc_sdata)
);

endmodule
