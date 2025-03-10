module clock_divider (
    input wire clk_i,
    input wire rst_i,
    input wire [15:0] div_factor,  // Selected division factor from keypad
    output logic clk_out
);
    logic [15:0] counter;

    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i) begin
            counter <= 0;
            clk_out <= 0;
        end else begin
            if (counter >= (div_factor - 1)) begin
                counter <= 0;
                clk_out <= ~clk_out; // Toggle output clock
            end else begin
                counter <= counter + 1;
            end
        end
    end
endmodule