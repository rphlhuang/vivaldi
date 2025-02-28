module nexysVideo (
    input [0:0] sys_clk,
    input [0:0] btnC, // reset
    input [3:0] sw, // For selecting wave
    input [3:4] ja, // PMOD connector pins
    input [3:0] kpyd_row_i,
    output [3:0] kpyd_col_o,
     
    // I2C Config Interface
    inout [0:0] adau1761_cclk,
    inout [0:0] adau1761_cout,

    // Audio stuff
    input [0:0] ac_adc_sdata,
    output [0:0] ac_mclk,
    output [0:0] ac_dac_sdata,
    output [0:0] ac_bclk,
    output [0:0] ac_lrclk,

    output [7:0] led
);

wire [7:0] led_temp;
// Rotary Encoder Controls
wire [4:0] enc_o;
encoder_debounce
#()
(
    .clk(clk_12),
    .A_i(ja[4]),
    .B_i(ja[5]),
    .A_o(A_O),
    .B_o(B_O)
);

encoder
#()
(
    .clk(clk_12),
    .A_i(A_O),
    .B_i(B_O),
    .BTN_i(ja[6]),
    .EncPos_o(enc_o),
    .LED_o(led_temp)
);

wire logic rst_n = btnC;

logic clk_12;

clk_wizard pll (
    .clk_100(sys_clk),
    .clk_12(clk_12)
);

logic clk_48kHz;
logic [31:0] counter;
localparam div_factor = 125; // 256 for 12.288 MHz -> 48 kHz

always_ff @(posedge clk_12 or posedge rst_n) begin
    if (rst_n) begin
        counter <= 0;
        clk_48kHz <= 0;
    end else begin
        if (counter == (div_factor - 1)) begin
            clk_48kHz <= ~clk_48kHz; // Toggle clock every 256 cycles
            counter <= 0;
        end else begin
            counter <= counter + 1;
        end
    end
end

// Audio data busses
wire [23:0] in_audioL;
wire [23:0] in_audioR;
wire [23:0] out_audioL;
wire [23:0] out_audioR;

wire [23:0] out_sig_w;

codec_init
#()
codec_init_inst
(
    .clk(sys_clk),
    .rst(rst_n),
    .sda(adau1761_cout),
    .scl(adau1761_cclk)
);

top top_inst (
    .clk_48kHz(clk_48kHz),
    .rst_n(rst_n),
    .sw(sw),
    .kpyd_row_i(kpyd_row_i),
    .kpyd_col_o(kpyd_col_o),
    .out_sig_w(out_sig_w),
    .led(led)
);


assign out_audioL = out_sig_w;
assign out_audioR = out_sig_w;

assign ac_mclk = clk_12;  

i2s_ctrl
#()
i2s_ctrl_inst
(
    .CLK_I(clk_12),
    .RST_I(rst_n),
    .EN_TX_I(1'b1),
    .EN_RX_I(1'b0),
    .FS_I(4'b0011), // div rate of 4, clock rate of 12.288 should result in 48 khz sample rate
    .MM_I(1'b0),
    .D_L_I(out_sig_w),
    .D_R_I(out_sig_w),  // change to whatever wave 
    .D_L_O(),
    .D_R_O(),
    .BCLK_O(ac_bclk),
    .LRCLK_O(ac_lrclk),
    .SDATA_O(ac_dac_sdata),
    .SDATA_I(1'b0)
);

endmodule
