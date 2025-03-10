
module top (
input clk_i,
input rst_i,
input [3:0] sw,
input [3:0] kpyd_row_i,
output [3:0] kpyd_col_o,
output [7:0] led,
output [23:0] out_sig_o
);

localparam integer SAMPLING_RATE = 48000;

logic [23:0] out_sig_l;

wire [23:0] sine_out_w, square_out_w, tri_out_w, saw_out_w;



sinusoid_wave 
#(.width_p(24), .sampling_freq_p(SAMPLING_RATE), .note_freq_p(440.0))
sine_wave_inst (
  .clk_i(clk_i),
  .reset_i(rst_i),
  .ready_i(sw[0]),
  .valid_i(1'b1),
  .data_o(sine_out_w),
  .valid_o()
);

square_wave
#(.width_p(24), .sampling_freq_p(SAMPLING_RATE), .note_freq_p(440.0))
square_wave_inst (
  .clk_i(clk_i),
  .reset_i(rst_i),
  .ready_i(sw[1]),
  .valid_i(1'b1),
  .data_o(square_out_w),
  .valid_o()
);

triangle_wave 
#(.width_p(24), .sampling_freq_p(SAMPLING_RATE), .note_freq_p(440.0))
triangle_wave_inst (
  .clk_i(clk_i),
  .reset_i(rst_i),
  .ready_i(sw[2]),
  .valid_i(1'b1),
  .data_o(tri_out_w),
  .valid_o()
);

sawtooth_wave 
#(.width_p(24), .sampling_freq_p(SAMPLING_RATE), .note_freq_p(440.0))
saw_wave_inst (
  .clk_i(clk_i),
  .reset_i(rst_i),
  .ready_i(sw[3]),
  .valid_i(1'b1),
  .data_o(saw_out_w),
  .valid_o()
);


always_comb begin : comb_signals
  case (sw)
    4'b0001: out_sig_l = sine_out_w;
    4'b0010: out_sig_l = square_out_w;
    4'b0100: out_sig_l = tri_out_w;
    4'b1000: out_sig_l = saw_out_w;
    default: out_sig_l = '0; 
  endcase
end

assign out_sig_o = out_sig_l;

endmodule
