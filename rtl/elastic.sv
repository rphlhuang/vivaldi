module elastic
  #(
    parameter [31:0] width_p = 8
   ,parameter [0:0] datapath_gate_p = 0
   ,parameter [0:0] datapath_reset_p = 0
   )
  (input [0:0] clk_i
  ,input [0:0] reset_i

  ,input [width_p - 1:0] data_i
  ,input [0:0] valid_i
  ,output [0:0] ready_o

  ,output [0:0] valid_o
  ,output [width_p - 1:0] data_o
  ,input [0:0] ready_i
  );

  logic [width_p-1:0] data_l;
  logic [0:0] valid_l;

  always_ff @(posedge clk_i) begin
    if ((reset_i)) begin
      valid_l <= 0;
      if (datapath_reset_p) begin
        data_l <= '0;
      end
    end
    else if (ready_o) begin
      if (datapath_gate_p && valid_i) begin
        data_l <= data_i;
        valid_l <= 1;
      end
      else begin
        data_l <= data_i;
        valid_l <= valid_i;
      end
    end
  end

  assign data_o = data_l;
  assign valid_o = valid_l;
  assign ready_o = ~valid_l | ready_i;

endmodule
