
module top_runner;

localparam SAMPLE_FREQUENCY = 44.1 * (10 ** 3); // 44.1kHz typical
localparam NUM_CHANNELS = 2; // 1 for mono, 2 for stereo
localparam BITS_PER_SAMPLE = 24; // 16 typical, 8 also ok
localparam BYTES_PER_SAMPLE = BITS_PER_SAMPLE / 8;

import "DPI-C" context function void hello();
import "DPI-C" context function int open_file(string filename);
import "DPI-C" context function void write_data_bytes(string data, int len, int flip_endian);
import "DPI-C" context function void write_wav_header(int sample_rate, int num_channels, int bits_per_sample);
import "DPI-C" context function void update_wav_header();
import "DPI-C" context function void close_file();

logic clk_i;
logic rst_i;

// default gain percent to zero
real gain_percent;
initial begin
  gain_percent = 0.0;
end

// clocks
localparam realtime ClockPeriod = 20.833ns; // 48Mhz
initial begin
  clk_i = 0;
  forever begin
    #(ClockPeriod/2);
    clk_i = !clk_i;
  end
end

wire clk_48kHz;
logic rst_n;
logic [3:0] sw;
logic [3:0] kpyd_row_i;
logic [3:0] kpyd_col_o;
logic [7:0] led;
logic signed [23:0] out_sig;

top top_inst (.*, .out_sig_o(out_sig));

logic signed [23:0] out_audioL, out_audioR;
assign out_audioL = out_sig;
assign out_audioR = out_sig;

task automatic set_frequency(input int freq);
  top_inst.freq = freq;
endtask

// tasks
task automatic reset;
  rst_i = 1;
  sw = 4'b0000;
  @(posedge clk_i);
  @(posedge clk_i);
  rst_i = 0;
endtask

task automatic set_gain_percent(input real percent);
  gain_percent = (percent) / 100.0;
endtask

task automatic select_sine;
  @(posedge clk_i);
  sw = 4'b0001;
endtask

task automatic select_square;
  @(posedge clk_i);
  sw = 4'b0010;
endtask

task automatic select_triangle;
  @(posedge clk_i);
  sw = 4'b0100;
endtask

task automatic select_sawtooth;
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
    write_data_bytes(out_audioL, BYTES_PER_SAMPLE, 1);
    if (NUM_CHANNELS === 2) begin
      write_data_bytes(out_audioR, BYTES_PER_SAMPLE, 1);
    end

    if (sw === 4'b0001 && i < 1000) begin
      $display("Writing %d to .wav (binary %b)", out_audioL, out_audioL);
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
