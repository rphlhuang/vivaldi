module kypd_select(
    input clk_12,
    input rst_i,
    input [3:0] kpyd_row_i,

    output [3:0] kpyd_col_o,
    output logic freqy_clk_o,
    output [0:0] noise_o
);

wire [3:0] freq;
wire [15:0] div_rate;


/* ADD OCTAVE SELECT SOMEWHERE

wire [0:0] octave_up, octave_down;
assign octave_up = sw[6];
assign octave_down = sw[7];

*/

kpyd2hex 
#()
kpyd_top_inst (
    .clk(clk_12),
    .Row(kpyd_row_i),
    .Col(kpyd_col_o),
    .DecodeOut(freq)
);

keypad_decoder
#()
decode_inst
(
    .clk_i(clk_12),
    .rst_i(rst_i),
    .key_value_i(freq),
    .div_factor_o(div_rate),
    .noise_en_o(noise_o)
);

clock_divider
#()
divider_inst
(
    .clk_i(clk_12),
    .rst_i(rst_i),
    .div_factor(div_rate),
    .clk_out(freqy_clk_o)
);

endmodule