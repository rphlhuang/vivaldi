module amp_modulator #(parameter DATA_WIDTH = 16)(
    input clk_i,
    input rst_i,
    input signed [DATA_WIDTH-1:0] signal_i,//actual signal
    input signed [DATA_WIDTH-1:0] modulator_i,//nvelope
    output signed [DATA_WIDTH-1:0] signal_o
);
logic signed [2*DATA_WIDTH-1:0] modulated_signal_reg;
logic signed [DATA_WIDTH-1:0] envelope;

//multiply signal
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        modulated_signal_reg <= 0;
    end else begin
        modulated_signal_reg <= signal_i * modulator_i;//we should rplace with DSP later, just for testing purposes
    end
end

//envelope
//envelope is supposed to show overall trend for amplitue of high frequency signals, ignoring oscillations
//if signal is less than 0, take absolute value
always_ff @(posedge clk_i) begin
    if (rst_i) begin
        signal_o <= 0;
    end else begin
        //if negative peak,
        signal_o <= modulated_signal_reg < 0 ? -modulated_signal_reg : modulated_signal_reg;
    end
end
endmodule
