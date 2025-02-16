
module vivaldi_runner;

localparam SAMPLE_FREQUENCY = 44.1 * 10 ** 3; // 44.1kHz typical
localparam NUM_CHANNELS = 2; // 1 for mono, 2 for stereo
localparam BITS_PER_SAMPLE = 16; // 16 typical, 8 also ok
localparam BYTES_PER_SAMPLE = BITS_PER_SAMPLE / 8;

import "DPI-C" context function void hello();
import "DPI-C" context function int open_file(string filename);
import "DPI-C" context function void write_data_bytes(string data, int len);
import "DPI-C" context function void write_wav_header(int sample_rate, int num_channels, int bits_per_sample);
import "DPI-C" context function void update_wav_header();
import "DPI-C" context function void close_file();

logic clk_i;
logic rst_i;

logic [3:0] sw; // For selecting wave

// default gain percent to zero
real gain_percent;
initial begin
  gain_percent = 0.0;
end

// clocks
localparam realtime ClockPeriod = 58.823ns; // 17Mhz
initial begin
  clk_i = 0;
  forever begin
    #(ClockPeriod/2);
    clk_i = !clk_i;
  end
end

// wave mod insts
wire [15:0] sine_out_w, square_out_w, tri_out_w, saw_out_w, out_sig_w;

sinusoid
#(.width_p(16), .sampling_freq_p(SAMPLE_FREQUENCY), .note_freq_p(440.0))
sine_wave_inst
(
  .clk_i(clk_i),
  .reset_i(rst_i),
  .ready_i(sw[0]),
  .data_o(sine_out_w),
  .valid_o()
);

square_wave
#(.width_p(16), .sampling_freq_p(SAMPLE_FREQUENCY), .note_freq_p(440.0))
square_wave_inst
(
  .clk_i(clk_i),
  .reset_i(rst_i),
  .ready_i(sw[1]),
  .data_o(square_out_w),
  .valid_o()
);

triangle_wave
#(.width_p(16), .sampling_freq_p(SAMPLE_FREQUENCY), .note_freq_p(440.0))
triangle_wave_inst
(
  .clk_i(clk_i),
  .reset_i(rst_i),
  .ready_i(sw[2]),
  .data_o(tri_out_w),
  .valid_o()
);

sawtooth_wave
#(.width_p(16), .sampling_freq_p(SAMPLE_FREQUENCY), .note_freq_p(440.0))
saw_wave_inst
(
  .clk_i(clk_i),
  .reset_i(rst_i),
  .ready_i(sw[3]),
  .data_o(saw_out_w),
  .valid_o()
);

// output signal mux
wire [15:0] out_audioL;
wire [15:0] out_audioR;
assign out_sig_w = sine_out_w + square_out_w + tri_out_w + saw_out_w;
assign out_audioL = out_sig_w * gain_percent;
assign out_audioR = out_sig_w * gain_percent;


// tasks
task automatic reset;
  rst_i = 1;
  @(posedge clk_i);
  rst_i = 0;
endtask

task automatic set_gain_percent(input real percent);
  gain_percent = (percent / 50.0) / 100.0;
endtask

task automatic select_sine;
  @(posedge clk_i);
  sw = 4'b0001;
endtask

task automatic select_square;
  @(posedge clk_i);
  sw = 4'b0010;
endtask

task automatic select_sawtooth;
  @(posedge clk_i);
  sw = 4'b0100;
endtask

task automatic select_triangle;
  @(posedge clk_i);
  sw = 4'b1000;
endtask


task automatic hello_cpp();
  hello();
endtask

task automatic open_wav_file();
  int error;
  error = open_file("out.wav");
  if (error === 1) begin
      $display("Error opening file!");
      $finish;
  end
  write_wav_header(SAMPLE_FREQUENCY, NUM_CHANNELS, BITS_PER_SAMPLE);
endtask

task automatic write_next_num_secs(input int num_secs);
  // write next num_secs * sample_freq cycles to wav
  int num_cycles = num_secs * SAMPLE_FREQUENCY;
  for (int i = 0; i < num_cycles; i += NUM_CHANNELS) begin
    write_data_bytes(out_audioL, BYTES_PER_SAMPLE);
    if (NUM_CHANNELS === 2) begin
      write_data_bytes(out_audioR, BYTES_PER_SAMPLE);
    end
    @(posedge clk_i);
  end
endtask

task automatic close_wav_file();
  update_wav_header();
  close_file();
endtask

task automatic wait_num_cycles(input int num_cycles);
  repeat(num_cycles) begin
    @(posedge clk_i);
  end
endtask

endmodule
