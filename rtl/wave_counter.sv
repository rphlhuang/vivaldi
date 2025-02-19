`timescale 1ns / 1ps
module wave_counter
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
