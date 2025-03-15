module nexysVideo (
    input [0:0] sys_clk,
    input [0:0] btnC, // reset
    input [0:0] btnU,
    input [7:0] sw, // For selecting wave
    input [7:4] JB_i, // PMOD connector pins
    input [7:4] JC_i,
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

logic clk_12;
wire rst_n = btnC;
wire signed [15:0] soundwave_o, out_sig_w, freq_ctrl_w, noise_w, noise_data_w, synth_sound_o;
wire signed [15:0] modulator_sound_o;
 

clk_wizard pll (
    .clk_100(sys_clk),
    .clk_12(clk_12)
);

// Modulator clock
logic [15:0] mod_count_l;
logic [0:0] mod_clk_w;

    always @(posedge sys_clk) begin
        if (rst_n) begin
            mod_count_l <= 0;
            mod_clk_w <= 0;
        end else begin
            if (mod_count_l >= 2000) begin
                mod_count_l <= 0;
                mod_clk_w <= ~mod_clk_w;
            end else begin
                mod_count_l <= mod_count_l + 1;
            end
        end
    end

// Attack Encoder
wire [4:0] attack_factor_o, release_factor_o;
wire [0:0] noise_en_w;

encoder_top
#()
jb_encoder_inst
(
  .clk_i(clk_12),
  .jcon_i(JB_i),
  .encPos_o(attack_factor_o),
  .led(led[7:4])
);

// Release Encoder
encoder_top
#()
jc_encoder_inst
(
  .clk_i(clk_12),
  .jcon_i(JC_i),
  .encPos_o(release_factor_o),
  .led(led[3:0])
);

wire [0:0] freqy_clk;

kypd_select
#()
kypd_select_inst
(
  .clk_12(clk_12),
  .rst_i(rst_n),
  .kpyd_row_i(kpyd_row_i),
  .kpyd_col_o(kpyd_col_o),
  .freqy_clk_o(freqy_clk),
  .noise_o(noise_en_w)
);

frequency_control
#(.width_p(16))
freq_ctrl_inst
(
  .clk_i(freqy_clk),
  .reset_i(rst_n),
  .ready_i(|sw[3:0]), // change to rely on key pressed
  .sw_i(sw[3:0]),
  .data_o(freq_ctrl_w)
);

noise_gen
#()
noise_inst
(
  .clk_i(clk_12),
  .rst_i(rst_n),
  .noise_o(noise_w)
);

assign noise_data_w =  (|sw[3:0]) ? noise_w : '0;
assign out_sig_w = (noise_en_w) ? noise_data_w : freq_ctrl_w;


envelope_generator
#(.DATA_WIDTH(16))
envelope_gen_inst
(
  .clk_pll_12_28_i(clk_12),
  .clk_slow_i(mod_clk_w),
  .rst_i(rst_n),
  .signal_i(out_sig_w),
  .attack_factor_i(attack_factor_o),
  .release_time_i(release_factor_o),
  .valid_i(btnU),
  .top_synth_o(synth_sound_o)
);


codec_init
#()
codec_init_inst
(
    .clk(sys_clk),
    .rst(rst_n),
    .sda(adau1761_cout),
    .scl(adau1761_cclk)
);

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
    .D_L_I(synth_sound_o),
    .D_R_I(synth_sound_o),  // change to whatever wave 
    .D_L_O(),
    .D_R_O(),
    .BCLK_O(ac_bclk),
    .LRCLK_O(ac_lrclk),
    .SDATA_O(ac_dac_sdata),
    .SDATA_I(1'b0)
);

endmodule
