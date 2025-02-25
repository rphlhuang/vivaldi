`timescale 1ns / 1ps
module sinusoid
#(parameter width_p = 12,
parameter depth_p = 512)
  (
    input clk_i,
    input reset_i,
    input [$clog2(depth_p)-1:0] addr_i,
    output signed [width_p-1:0] data_o,
    output valid_o
  );

  localparam depth_log2_p = $clog2(depth_p);

  logic signed [width_p - 1 : 0] sine_w;
  assign valid_o = 1'b1;
  assign data_o = sine_w;

  logic signed [width_p-1 : 0] mem [0 : depth_p - 1];

  always_ff @(posedge clk_i) begin
    if (reset_i)
      sine_w <= '0;
    else
      sine_w <= mem[addr_i];
  end

  localparam real max_val_lp = (1 << (width_p - 1)) - 1;
  localparam real pi_lp = 3.14159;
  initial begin
    for (int i = 0; i < depth_p; i++)
      mem[i] = $rtoi(max_val_lp * $sin(2 * pi_lp * i / depth_p));
  end
endmodule
