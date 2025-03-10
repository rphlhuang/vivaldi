`timescale 1ns / 1ps
module sinusoid_wave
  #(parameter width_p = 12
   ,parameter real sampling_freq_p = 44.1 * 10 ** 3
   ,parameter real note_freq_p = 440.0
   )
  (input [0:0] clk_i
  ,input [0:0] reset_i
  ,input [0:0] ready_i
  ,input [0:0] valid_i
  ,output signed [width_p-1:0] data_o
  ,output [0:0] valid_o
   );

  localparam depth_p = $rtoi(sampling_freq_p / note_freq_p);
  localparam depth_log2_p = $clog2(depth_p);

  logic signed [depth_log2_p-1:0] addr_w;
  logic signed [width_p - 1 : 0] sine_w;
  assign valid_o = 1'b1;

  wave_counter
    #(.max_val_p(depth_p - 1))
  addr_counter_inst
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.up_i(ready_i&valid_i)
    ,.down_i(1'b0)
    ,.count_o(addr_w));

  assign data_o = sine_w;

  logic signed [width_p-1 : 0] mem [0 : depth_p - 1];
  always_ff @(posedge clk_i) begin
    if (reset_i)
      sine_w <= '0;
    else
      sine_w <= mem[addr_w];
  end

  // Memory initialization
  // Maximum value sin can get accounting for the sign bit
  localparam real max_val_lp = (1 << (width_p - 1)) - 1;
  localparam real pi_lp = 3.14159;
  initial begin
    for (int i = 0; i < depth_p; i++) begin
      mem[i] = $rtoi(max_val_lp * $sin(2 * pi_lp * i / depth_p));

    end
    mem[depth_p/2] = mem[0];
    mem[depth_p] = mem[0];

  end
endmodule