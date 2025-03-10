module keypad_decoder (
    input wire clk_i,
    input wire rst_i,
    input wire [3:0] key_value_i,  
    output logic [15:0] div_factor_o
);
    always @(posedge clk_i or posedge rst_i) begin
        if (rst_i)
            div_factor_o <= 16'd128; 
        else begin
            case (key_value_i)
                //4'h0: div_factor_o <= 16'd215; // C - 262 Hz
                4'h1: div_factor_o <= 16'd215; // C# - 277 Hz   
                4'h2: div_factor_o <= 16'd204; // D - 294 Hz   
                4'h3: div_factor_o <= 16'd191; // D# - 311 Hz
                4'h4: div_factor_o <= 16'd128; // E - 330 Hz 
                4'h5: div_factor_o <= 16'd171; // F - 349 Hz 
                4'h6: div_factor_o <= 16'd161; // F# - 370 Hz 
                4'h7: div_factor_o <= 16'd152; // G - 392 Hz 
                4'h8: div_factor_o <= 16'd121; // G# - 415 Hz   
                4'h9: div_factor_o <= 16'd136; // A - 440 Hz   
                4'hA: div_factor_o <= 16'd181; // A# - 466 Hz  
                4'hB: div_factor_o <= 16'd145; // B - 494 Hz 
                4'hC: div_factor_o <= 16'd114;
                //4'hD: div_factor_o <= 16'd215;
                //4'hE: div_factor_o <= 16'd203;
                //4'hF: div_factor_o <= 16'd191;
                default: div_factor_o <= 16'd128;
            endcase
        end
    end
endmodule
