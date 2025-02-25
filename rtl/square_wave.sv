`timescale 1ns / 1ps
module square_wave
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

  logic [width_p - 1 : 0] square_w;
  assign valid_o = 1'b1;
  assign data_o = square_w;

  logic [width_p-1 : 0] mem [0 : depth_p - 1];

  always_ff @(posedge clk_i) begin
    if (reset_i)
      square_w <= '0;
    else
      square_w <= mem[addr_i];
  end

  localparam real max_val_lp = (1 << (width_p - 1)) - 1;
  initial begin
    mem[0] = '0;
    for (int i = 1; i < depth_p; i++)
      mem[i] = (i < (depth_p / 2)) ? max_val_lp : -max_val_lp;
    for (int i = 0; i < depth_p; i++)
      $display("square mem[%0d] = %0d (binary: %b)", i, mem[i], mem[i]);
  end
endmodule
