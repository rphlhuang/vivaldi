module encoder_top(
    input clk_i,
    input [7:4] jcon_i,
    output [4:0] encPos_o,
    output [7:0] led
);

encoder_debounce
#()
(
    .clk(clk_i),
    .A_i(jcon_i[4]),
    .B_i(jcon_i[5]),
    .A_o(A_O),
    .B_o(B_O)
);

encoder
#()
(
    .clk(clk_i),
    .A_i(A_O),
    .B_i(B_O),
    .BTN_i(jcon_i[6]),
    .EncPos_o(encPos_o),
    .LED_o(led)
);
    
endmodule