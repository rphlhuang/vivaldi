module encoder_debounce
#()
(
    input [0:0] clk,
    input [0:0] A_i,
    input [0:0] B_i,
    output [0:0] A_o,
    output [0:0] B_o
);

    logic A_o = 1'b0;
    logic B_o = 1'b0;

	logic [6:0] clkdiv_l = 0;
	logic lastA_l = 0;
	logic lastB_l = 0;

	always @(posedge clk) begin
		lastA_l <= A_i;
		lastB_l <= B_i;

		if(clkdiv_l == 7'b1100100) begin
				if(lastA_l == A_i) begin
						A_o <= A_i;
				end

				if(lastB_l == B_i) begin
						B_o <= B_i;
				end

				clkdiv_l <= 7'b0000000;
		end
		else begin
				clkdiv_l <= clkdiv_l + 7'b0000001;
		end
	end

endmodule
