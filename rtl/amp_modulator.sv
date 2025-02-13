//takes in carrier signal of high frequency,
module amp_modulator #(parameter DATA_WIDTH = 16)(
    input clk_i,
    input rst_i,
    input valid_i,
    input logic signed [DATA_WIDTH-1:0] signal_i,//carrier signal, actual wave that gets modulated high freq
    input logic signed [DATA_WIDTH-1:0] modulator_i,//modulating signal, controls amplitude low freq
    output logic signed [DATA_WIDTH-1:0] signal_o,
    output ready_o
);
/*
//multiply signal
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        modulated_signal_reg <= 0;
    end else begin
        //add one to prevent flipping carrier signal
        modulated_signal_reg <= signal_i * (1+modulator_i);//we should rplace with DSP later, just for testing purposes
    end
end
*/

logic signed [2*DATA_WIDTH-1:0] modulated_signal_reg;
logic signed [17:0] modulated_input;//18-bit width for DSP48E1 B input
logic signed [29:0] a_input;//30-bit width for DSP48E1 A input
logic signed [24:0] d_input;//25-bit width for DSP48E1 D input (A+D pre-adder)
logic signed [47:0] dsp_out;//DSP output

assign a_input = 30'd1;
assign d_input = {{(18-DATA_WIDTH){1'b0}},modulator_i};//zero pad

//DSP48E1 instance using pre-adder, then multiply
DSP48E1 #(
    .A_INPUT("DIRECT"),
    .B_INPUT("DIRECT"),
    .USE_DPORT("TRUE"),//to use pre adder d input
    .USE_MULT("MULTIPLY"),
    .USE_SIMD("ONE48"),
    .ACASCREG(0),
    .BREG(2),//using both registers pipeline to match pre adder stage 2 cycle delay
    .DREG(1),//we can change this later but for now pipelining inputs to pre adder and inputs to multiply and externally the dsp out
    .MREG(0),
    .PREG(0)
)
DSP48E1_inst (
    .CLK(clk_i),
    .A(a_input),//30-bit input: Constant 1
    .D(d_input),//25-bit input: Modulating signal (pre-adder input)
    .B(modulated_input),//18-bit input: Carrier signal
    .P(dsp_out),//48-bit output: Multiplication result
    .RSTP(rst_i),//reset for pipeline register

    .CEAD(1'b1),//clock enable for the pre-adder output AD pipeline register
    .CED(1'b1),
    .CEA1(1'b0),
    .CEA2(1'b0),
    .CEB1(1'b1),//pipeine stage for inputs
    .CEB2(1'b1),
    .CEM(1'b0),
    .CEP(1'b0)
);

//envelope
//envelope is supposed to show overall trend for amplitue of high frequency signals, ignoring oscillations
//if signal is less than 0, take absolute value
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        signal_o <= 0;
    end else begin
        //fill bit widths for mult result
        signal_o <= dsp_out >>> (DATA_WIDTH - 1);
    end
end
endmodule
