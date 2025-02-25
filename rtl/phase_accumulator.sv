module phase_accumulator
  #(parameter ACC_WIDTH = 32,
    parameter ADDR_WIDTH = 8)
  (
    input clk,
    input reset,
    input [ACC_WIDTH-1:0] phase_inc,
    output logic [ADDR_WIDTH-1:0] addr
  );

  logic [ACC_WIDTH-1:0] phase;

  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      phase <= 0;
    else
      phase <= phase + phase_inc;
  end

  assign addr = phase[ACC_WIDTH-1 -: ADDR_WIDTH];
endmodule
