module frequency_control
 #(parameter width_p = 24)
  (input [0:0] clk_i,
   input [0:0] reset_i,
   input [0:0] ready_i,
   input [3:0] sw_i,
   output signed [width_p-1:0] data_o
   );

    localparam SAMPLING_FREQ = 48 * (10 ** 3);
    localparam wave_std_freq_lp = 440.0;

    wire signed [width_p-1:0] sinusoid_data_o, square_data_o, triangle_data_o, sawtooth_data_o, noise_data_o, filtered_noise_o;
    logic signed [width_p-1:0] data_ol;

    sinusoid_wave #(.width_p(width_p)
   ,.sampling_freq_p(SAMPLING_FREQ)
   ,.note_freq_p(wave_std_freq_lp)
   )
   sinusoid_inst 
  (.clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.ready_i(ready_i)
  ,.data_o(sinusoid_data_o)
  ,.valid_i(1'b1)
  ,.valid_o());

    square_wave #(.width_p(width_p)
   ,.sampling_freq_p(SAMPLING_FREQ)
   ,.note_freq_p(wave_std_freq_lp)
   )
   square_inst
  (.clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.ready_i(ready_i)
    ,.valid_i(1'b1)
  ,.data_o(square_data_o)
  ,.valid_o());

    triangle_wave #(.width_p(width_p)
   ,.sampling_freq_p(SAMPLING_FREQ)
   ,.note_freq_p(wave_std_freq_lp)
   )
   triangle_inst
  (.clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.ready_i(ready_i)
  ,.data_o(triangle_data_o)
  ,.valid_i(1'b1)
  ,.valid_o());    


    sawtooth_wave #(.width_p(width_p)
   ,.sampling_freq_p(SAMPLING_FREQ)
   ,.note_freq_p(wave_std_freq_lp)
   )
   sawtooth_inst
  (.clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.ready_i(ready_i)
  ,.data_o(sawtooth_data_o)
  ,.valid_i(1'b1)
  ,.valid_o());


always_comb begin
    case (sw_i[3:0])
        4'b000001: data_ol = sinusoid_data_o;
        4'b000010: data_ol = square_data_o;
        4'b000100: data_ol = sawtooth_data_o;
        4'b001000: data_ol = triangle_data_o;
        default: data_ol = '0;
    endcase
end

assign data_o = data_ol;

endmodule
