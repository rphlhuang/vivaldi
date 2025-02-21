module nexysVideo (
    input [0:0] sys_clk,
    input [0:0] btnC, // reset
    input [3:0] sw, // For selecting wave
    input [7:4] ja, // PMOD connector pins

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
    .LED_o(led)
);


wire logic rst_n = btnC;

// PLL Declaration
logic clk_12;

clk_wizard pll (
    .clk_100(sys_clk),
    .clk_12(clk_12)
);


// Wave clock generation
logic clk_48kHz;
logic [31:0] counter;
localparam div_factor = 128; // 256 for 12.288 MHz -> 48 kHz

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

// Wave initializations
wire [23:0] sine_out_w, square_out_w, tri_out_w, saw_out_w;
logic [23:0] out_sig_l;

sinusoid
#(.width_p(24), .sampling_freq_p(48 * 10 ** 3), .note_freq_p(440.0))
sine_wave_inst
(
    .clk_i(clk_48kHz),
    .reset_i(rst_n),
    .ready_i(sw[0]),
    .data_o(sine_out_w),
    .valid_o()
);

square_wave
#(.width_p(24), .sampling_freq_p(48 * 10 ** 3), .note_freq_p(440.0))
square_wave_inst
(
    .clk_i(clk_48kHz),
    .reset_i(rst_n),
    .ready_i(sw[1]),
    .data_o(square_out_w),
    .valid_o()
);

triangle_wave
#(.width_p(24), .sampling_freq_p(48 * 10 ** 3), .note_freq_p(440.0))
triangle_wave_inst
(
    .clk_i(clk_48kHz),
    .reset_i(rst_n),
    .ready_i(sw[2]),
    .data_o(tri_out_w),
    .valid_o()
);

sawtooth_wave
#(.width_p(24), .sampling_freq_p(48 * 10 ** 3), .note_freq_p(440.0))
saw_wave_inst
(
    .clk_i(clk_48kHz),
    .reset_i(rst_n),
    .ready_i(sw[3]),
    .data_o(saw_out_w),
    .valid_o()
);

// Audio data busses
wire [23:0] in_audioL;
wire [23:0] in_audioR;
wire [23:0] out_audioL;
wire [23:0] out_audioR;

codec_init
#()
codec_init_inst
(
    .clk(sys_clk),
    .rst(rst_n),
    .sda(adau1761_cout),
    .scl(adau1761_cclk)
);

// Send sine wave output to DAC instead of passthrough
always_comb begin : comb_signals
  case (sw)
    4'b0001: out_sig_l = sine_out_w;
    4'b0010: out_sig_l = square_out_w;
    4'b0100: out_sig_l = tri_out_w;
    4'b1000: out_sig_l = saw_out_w;
    default: out_sig_l = '0; 
  endcase
end
assign out_audioL = out_sig_l;
assign out_audioR = out_sig_l;

i2s_ctrl
#()
i2s_ctrl_inst
(
    .CLK_I(clk_12),
    .RST_I(rst_n),
    .EN_TX_I(1'b1),
    .EN_RX_I(1'b0),
    .FS_I(4'b0101), // div rate of 4, clock rate of 12.288 should result in 48 khz sample rate
    .MM_I(1'b0),
    .D_L_I(out_audioL),
    .D_R_I(out_audioR),
    .D_L_O(),
    .D_R_O(),
    .BCLK_O(ac_bclk),
    .LRCLK_O(ac_lrclk),
    .SDATA_O(ac_dac_sdata),
    .SDATA_I(1'b0)
);

endmodule
