module frequency_control
 #(parameter width_p = 12,
    parameter clk_freq_p = 12_000_000 //frequency of clock input defaults to 12MHz
   )
  (input [0:0] clk_i,
   input [0:0] reset_i,
   input [15:0] freq_ctrl_i, // output frequency (20 Hz - 20 kHz range)
   input [3:0] sw_i,
   input [0:0] ready_i,
   output signed [width_p-1:0] data_o,
   output [0:0] valid_o
   );
    localparam wave_std_freq_lp = 440;
    localparam sample_size_lp = 300;
    logic [15:0] clk_div_l;
    logic [15:0] clk_slow_counter_l;

    wire [width_p-1:0] sinusoid_data_o, square_data_o, triange_data_o, sawtooth_data_o;
    logic [width_p-1:0] data_ol;

    // calculate clock div when the freq_ctrl_i input changes
    always_comb begin
        if(reset_i) begin
            clk_div_l = '0;
        end
        else begin
            clk_div_l = clk_freq_p/(sample_size_lp*freq_ctrl_i);
        end
    end


    // cc counter to slow wave data to desired frequency
    always_ff @(posedge clk_i) begin
        if(reset_i || (clk_slow_counter_l >= clk_div_l)) begin
            clk_slow_counter_l <= '0;
        end 
        else begin
            clk_slow_counter_l <= clk_slow_counter_l + 1;
        end
    end


    sinusoid #(.width_p(width_p)
   ,.sampling_freq_p(sample_size_lp*note_freq_p)
   ,.note_freq_p(note_freq_p)
   )
   sinudoid_inst
  (.clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.ready_i(ready_i && (clk_slow_counter_l === clk_div_l))
  ,.data_o(sinusoid_data_o)
  ,.valid_o());

    square_wave #(.width_p(width_p)
   ,.sampling_freq_p(sample_size_lp*note_freq_p)
   ,.note_freq_p(note_freq_p)
   )
   square_inst
  (.clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.ready_i(ready_i && (clk_slow_counter_l === clk_div_l))
  ,.data_o(square_data_o)
  ,.valid_o());

    triangle_wave #(.width_p(width_p)
   ,.sampling_freq_p(sample_size_lp*note_freq_p)
   ,.note_freq_p(note_freq_p)
   )
   triangle_inst
  (.clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.ready_i(ready_i && (clk_slow_counter_l === clk_div_l))
  ,.data_o(triangle_data_o)
  ,.valid_o());    


    sawtooth_wave #(.width_p(width_p)
   ,.sampling_freq_p(sample_size_lp*note_freq_p)
   ,.note_freq_p(note_freq_p)
   )
   sawtooth_inst
  (.clk_i(clk_i)
  ,.reset_i(reset_i)
  ,.ready_i(ready_i && (clk_slow_counter_l === clk_div_l))
  ,.data_o(sinusoid_data_o)
  ,.valid_o());


always_comb begin
    data_ol = data_o;
    case (sw_i)
        4'b0001: data_ol = sinusoid_data_o;
        4'b0010: data_ol = square_data_o;
        4'b0100: data_ol = triange_data_o;
        4'b1000: data_ol = sawtooth_data_o;
        default: data_ol = data_o;
    endcase
end

assign data_o = data_ol;
assign valid_o = 1'b1;


endmodule