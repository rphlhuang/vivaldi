module nexysVideo (
    input [0:0] sys_clk,
    input [0:0] btnC, // reset
    input [7:0] sw, // For selecting wave
    input [7:4] jb, // PMOD connector pins
    input [3:0] kpyd_row_i,
    output [3:0] kpyd_col_o,
     
    // I2C Config Interface
    inout [0:0] adau1761_cclk,
    inout [0:0] adau1761_cout,

    // Audio stuff
    input [0:0] ac_adc_sdata,
    output [0:0] ac_mclk,
    output [0:0] ac_dac_sdata,
    output [0:0] ac_bclk,
    output [0:0] ac_lrclk,

    output [7:0] led
);

logic clk_12;

clk_wizard pll (
    .clk_100(sys_clk),
    .clk_12(clk_12)
);

wire [7:0] led_temp;
wire [15:0] div_rate;
// Rotary Encoder Controls
wire [4:0] enc_o;
encoder_debounce
#()
(
    .clk(clk_12),
    .A_i(jb[4]),
    .B_i(jb[5]),
    .A_o(A_O),
    .B_o(B_O)
);

encoder
#()
(
    .clk(clk_12),
    .A_i(A_O),
    .B_i(B_O),
    .BTN_i(jb[6]),
    .EncPos_o(enc_o),
    .LED_o(led_temp)
);

wire logic rst_n = btnC;
wire logic freqy_clk;

wire [3:0] freq;

kpyd2hex 
#()
kpyd_top_inst (
    .clk(sys_clk),
    .Row(kpyd_row_i),
    .Col(kpyd_col_o),
    .DecodeOut(freq[3:0])
);

keypad_decoder
#()
decode_inst
(
    .clk_i(clk_12),
    .rst_i(rst_n),
    .key_value_i(freq),
    .div_factor_o(div_rate)
);

wire [0:0] octave_up, octave_down;
assign octave_up = sw[6];
assign octave_down = sw[7];

clock_divider
#()
divider_inst
(
    .clk_i(clk_12),
    .rst_i(rst_n),
    .div_factor(div_rate),
    .clk_out(freqy_clk)
);

wire [23:0] out_sig_w;

top top_inst (
    .clk_i(freqy_clk),
    .rst_i(rst_n),
    .sw(sw),
    .kpyd_row_i(kpyd_row_i),
    .kpyd_col_o(kpyd_col_o),
    .out_sig_o(out_sig_w),
    .led()
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


//assign out_audioL = (key_pressed) ? out_sig_w : '0;
//assign out_audioR = (key_pressed) ? out_sig_w : '0;

assign ac_mclk = clk_12;  

i2s_ctrl
#()
i2s_ctrl_inst
(
    .CLK_I(clk_12),
    .RST_I(rst_n),
    .EN_TX_I(1'b1),
    .EN_RX_I(1'b0),
    .FS_I(4'b0101), // div rate of 4, clock rate of 12.288 should result in 48 khz sample rate
    .MM_I(1'b0),
    .D_L_I(out_sig_w),
    .D_R_I(out_sig_w),  // change to whatever wave 
    .D_L_O(),
    .D_R_O(),
    .BCLK_O(ac_bclk),
    .LRCLK_O(ac_lrclk),
    .SDATA_O(ac_dac_sdata),
    .SDATA_I(1'b0)
);

assign led[7:4] = freq;
assign led[0] = key_pressed;
assign led[1] = extra;

endmodule
