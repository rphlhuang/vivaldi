`timescale 1ns / 1ps
module sawtooth_wave
  #(parameter width_p = 12
   ,parameter real sampling_freq_p = 44.1 * 10 ** 3
   ,parameter real note_freq_p = 440.0
   )
  (input [0:0] clk_i
  ,input [0:0] reset_i
  ,input [0:0] ready_i
  ,input [0:0] valid_i
  ,output [width_p-1:0] data_o
  ,output [0:0] valid_o
   );

  localparam depth_p = $rtoi(sampling_freq_p / note_freq_p);
  localparam depth_log2_p = $clog2(depth_p);

  logic [depth_log2_p-1:0] addr_w;
  logic [width_p - 1 : 0] sawtooth_w;
  assign valid_o = 1'b1;

  wave_counter
    #(.max_val_p(depth_p - 1))
  addr_counter_inst
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.up_i(ready_i&valid_i)
    ,.down_i(1'b0)
    ,.count_o(addr_w));

  assign data_o = sawtooth_w;

  logic [width_p-1 : 0] mem [0 : depth_p - 1];
  always_ff @(posedge clk_i) begin
    if (reset_i)
      sawtooth_w <= '0;
    else
      sawtooth_w <= mem[addr_w];
  end

  // Memory initialization
  // Maximum value sin can get accounting for the sign bit

  localparam real max_val_lp = (1 << (width_p - 1)) - 1;
  localparam int half_depth_p = depth_p / 2;
  localparam real increment_val_lp = max_val_lp/(depth_p/2);
  initial begin
    for (int i = 0; i < depth_p; i++) begin
      mem[i] = ((i+1)*increment_val_lp);
    end
    mem[0] = 0;
    mem[half_depth_p-1] = mem[0];
    mem[depth_p-1] = mem[0];


    // for (int i = 0; i < depth_p; i++)
    //   $display("sawtooth mem[%0d] = %0d (binary: %b)", i, mem[i], mem[i]);
  end
endmodule
