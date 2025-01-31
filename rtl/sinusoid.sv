module sinusoid
  #(parameter width_p = 12
   ,parameter real sampling_freq_p = 44.1 * 10 ** 3
   ,parameter real note_freq_p = 440.0
   )
  (input [0:0] clk_i
  ,input [0:0] reset_i
  ,input [0:0] ready_i
  ,output [width_p-1:0] data_o
  ,output [0:0] valid_o
   );

  localparam depth_p = $rtoi(sampling_freq_p / note_freq_p);
  localparam depth_log2_p = $clog2(depth_p);

  logic [depth_log2_p-1:0] addr_w;
  logic [width_p - 1 : 0] sine_w;
  assign valid_o = 1'b1;

  sinusoid_counter
    #(.max_val_p(depth_p - 1))
  addr_counter_inst
    (.clk_i(clk_i)
    ,.reset_i(reset_i)
    ,.up_i(ready_i)
    ,.down_i(1'b0)
    ,.count_o(addr_w));

  assign data_o = sine_w;

  logic [width_p-1 : 0] mem [0 : depth_p - 1];
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
    for (int i = 0; i < depth_p; i++)
      mem[i] = $rtoi((max_val_lp) * $sin(note_freq_p * i * 2 * pi_lp / sampling_freq_p));
  end
endmodule


module sinusoid_counter
  // this is just a regular counter, named differently to not conflict with
  // any other counter you  might use
  #(parameter [31:0] max_val_p = 15
   ,parameter width_p = $clog2(max_val_p)
    /* verilator lint_off WIDTHTRUNC */
   ,parameter [width_p-1:0] reset_val_p = '0
    )
    /* verilator lint_on WIDTHTRUNC */
   (input [0:0] clk_i
   ,input [0:0] reset_i
   ,input [0:0] up_i
   ,input [0:0] down_i
   ,output logic [width_p-1:0] count_no
   ,output logic [width_p-1:0] count_o);

  localparam [width_p-1:0] max_val_lp = max_val_p[width_p-1:0];

  always_ff @(posedge clk_i)
    if (reset_i)
      count_o <= reset_val_p;
    else
      count_o <= count_no;

  always_comb begin
    count_no = count_o;
    if (up_i & ~down_i)
      if (count_o == max_val_lp)
        count_no = 0;
      else
        count_no = count_o + 1;
    else if (down_i)
      if (count_o == 0)
        count_no = max_val_lp;
      else
        count_no = count_o - 1;
  end

endmodule
