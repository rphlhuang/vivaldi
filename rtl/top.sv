
module top (
input clk_48kHz,
input rst_n,
input [3:0] sw,
input [3:0] kpyd_row_i,
output [3:0] kpyd_col_o,
output [7:0] led,
output [23:0] out_sig_o
);

wire [3:0] freq;
logic [23:0] out_sig_l;

wire [23:0] sine_out_w, square_out_w, tri_out_w, saw_out_w;

logic [5:0] clk_div; 
wire slow_clk;

always_ff @(posedge clk_48kHz) begin
  if (rst_n || clk_div == 6'd15) begin
    clk_div <= 6'd0;
  end else begin
    clk_div <= clk_div + 1'b1;
  end
end

assign slow_clk = (clk_div == 6'd15); 

logic [3:0] col_select;

always_ff @(posedge clk_48kHz) begin
  if (rst_n) begin
    col_select <= 4'b0001;  
  end else if (slow_clk) begin
    col_select <= {col_select[2:0], col_select[3]};  
  end
end

assign kpyd_col_o = ~col_select;  

wire [3:0] pressed_row = ~kpyd_row_i;  
wire key_pressed = |pressed_row;       

wire [7:0] kpyd = {~kpyd_row_i, ~kpyd_col_o}; 

kpyd2hex top_inst (
    .kpyd_i(kpyd),
    .clk_i(clk_48kHz),
    .reset_i(rst_n),
    .hex_o(freq[3:0])
);

logic [31:0] note_lut [0:15];

initial begin
  note_lut[0]  = 261; 
  note_lut[1]  = 294; 
  note_lut[2]  = 330; 
  note_lut[3]  = 349; 
  note_lut[4]  = 392; 
  note_lut[5]  = 440; 
  note_lut[6]  = 494; 
  note_lut[7]  = 523;
  note_lut[8]  = 587; 
  note_lut[9]  = 659; 
  note_lut[10] = 698; 
  note_lut[11] = 784; 
  note_lut[12] = 880; 
  note_lut[13] = 988; 
  note_lut[14] = 1046; 
  note_lut[15] = 1174; 
end

localparam integer SAMPLING_RATE = 48000;
localparam integer ACC_WIDTH     = 32;

localparam integer DEPTH = 1024;
localparam integer DEPTH_LOG2 = 10; 

logic [31:0] desired_freq;

logic [ACC_WIDTH-1:0] phase_inc;

always_comb begin
  desired_freq = note_lut[freq];
  phase_inc = (desired_freq * (64'd1 << ACC_WIDTH)) / SAMPLING_RATE;
end

wire [DEPTH_LOG2-1:0] shared_addr;

phase_accumulator #(
  .ACC_WIDTH(ACC_WIDTH),
  .ADDR_WIDTH(DEPTH_LOG2)
) phase_acc_inst (
  .clk(clk_48kHz),
  .reset(rst_n),
  .phase_inc(phase_inc),
  .addr(shared_addr)
);

sinusoid #(.width_p(24), .depth_p(DEPTH))
sine_wave_inst (
  .clk_i(clk_48kHz),
  .reset_i(rst_n),
  .addr_i(shared_addr),
  .data_o(sine_out_w),
  .valid_o()
);

square_wave #(.width_p(24), .depth_p(DEPTH))
square_wave_inst (
  .clk_i(clk_48kHz),
  .reset_i(rst_n),
  .addr_i(shared_addr),
  .data_o(square_out_w),
  .valid_o()
);

triangle_wave #(.width_p(24), .depth_p(DEPTH))
triangle_wave_inst (
  .clk_i(clk_48kHz),
  .reset_i(rst_n),
  .addr_i(shared_addr),
  .data_o(tri_out_w),
  .valid_o()
);

sawtooth_wave #(.width_p(24), .depth_p(DEPTH))
saw_wave_inst (
  .clk_i(clk_48kHz),
  .reset_i(rst_n),
  .addr_i(shared_addr),
  .data_o(saw_out_w),
  .valid_o()
);

always_comb begin
  if (rst_n) begin
    led[7:0] = 8'b0;
  end else begin
    led[7:0] = {kpyd_row_i, kpyd_col_o};
  end
end

wire signed [23:0] sine_sel = (key_pressed) ? sine_out_w : 24'd0;
wire signed [23:0] square_sel = (key_pressed) ? square_out_w : 24'd0;
wire signed [23:0] tri_sel = (key_pressed) ? tri_out_w : 24'd0;
wire signed [23:0] saw_sel = (key_pressed) ? saw_out_w : 24'd0;

always_comb begin : comb_signals
  case (sw)
    4'b0001: out_sig_l = sine_sel;
    4'b0010: out_sig_l = square_sel;
    4'b0100: out_sig_l = tri_sel;
    4'b1000: out_sig_l = saw_sel;
    default: out_sig_l = '0; 
  endcase
end

assign out_sig_o = out_sig_l;
assign led[7] = shared_addr[DEPTH_LOG2-1]; 
assign led[6:4] = freq[3:1]; 
assign led[3:0] = kpyd_col_o;  

endmodule