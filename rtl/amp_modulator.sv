`timescale 1ns / 1ps

module amp_modulator #(parameter DATA_WIDTH = 16)(
    input clk_i,
    input rst_i,
    input valid_i,
    input logic signed [DATA_WIDTH-1:0] signal_i,   // Carrier signal (high freq)
    input logic signed [DATA_WIDTH-1:0] modulator_i, // Modulating signal (low freq)
    output logic signed [DATA_WIDTH-1:0] signal_o,
    output ready_o
);

logic signed [15:0] b_input; 
logic signed [15:0] a_input;  
logic signed [15:0] d_input; 
logic signed [32:0] dsp_out;

assign b_input = {{(16-DATA_WIDTH){signal_i[DATA_WIDTH-1]}}, signal_i};
assign d_input = 16'sd1;
assign a_input = {{(16-DATA_WIDTH){modulator_i[DATA_WIDTH-1]}}, modulator_i};

xbip_dsp48_macro_0 U0 (
    .CLK(clk_i),
    .A(a_input),
    .B(b_input),
    .D(d_input),
    .P(dsp_out)
);

always_ff @(posedge clk_i) begin
    if (rst_i) begin
        signal_o <= 0;
    end else begin
        signal_o <= dsp_out >>>(DATA_WIDTH-1);
    end
end

assign ready_o = 1'b1;

endmodule

