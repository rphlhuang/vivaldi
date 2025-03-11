`timescale 1ns / 1ps
module noise_gen
#()
(
    input [0:0] clk_i,
    input [0:0] rst_i,
    output signed [23:0] noise_o
);

    // 24-bit LFSR with tap bits at positions 0, 2, 3, and 23
    localparam logic [23:0] SEED = 24'b1000_1001_0110_0100_1100_1110;
    
    logic [23:0] lfsr_l;
    logic feedback;

    always_ff @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            lfsr_l <= SEED;
        end else begin
            feedback = lfsr_l[23] ^ lfsr_l[3] ^ lfsr_l[2] ^ lfsr_l[0];
            // add new bit to shift reg
            lfsr_l <= {lfsr_l[22:0], feedback};
        end
    end

    assign noise_o = lfsr_l;

endmodule
