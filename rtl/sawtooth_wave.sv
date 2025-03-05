`timescale 1ns / 1ps
module sawtooth_wave
  #(parameter width_p = 12,
    parameter depth_p = 512)
  (
    input clk_i,
    input reset_i,
    input [$clog2(depth_p)-1:0] addr_i,
    output [width_p-1:0] data_o,
    output valid_o
  );

  localparam depth_log2_p = $clog2(depth_p);

  logic [width_p - 1 : 0] sawtooth_w;
  assign valid_o = 1'b1;
  assign data_o = sawtooth_w;

  logic [width_p-1 : 0] mem [0 : depth_p - 1];

  always_ff @(posedge clk_i) begin
    if (reset_i)
      sawtooth_w <= '0;
    else
      sawtooth_w <= mem[addr_i];
  end

  localparam real max_val_lp = (1 << (width_p - 1)) - 1;
  localparam real increment_val_lp = max_val_lp/(depth_p/2);
  initial begin
    for (int i = 0; i < depth_p; i++)
      mem[i] = i * increment_val_lp;
  end
endmodule
