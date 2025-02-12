module wavewriter;

import "DPI-C" context function void hello();
import "DPI-C" context function int open_file(string filename);
import "DPI-C" context function void write_bytes(string data, int len);
import "DPI-C" context function void write_wav_header(int sample_rate, int num_channels, int bits_per_sample);
import "DPI-C" context function void write_sine(int sample_rate, int num_channels, int bits_per_sample, int num_samples, int frequency);
import "DPI-C" context function void update_wav_header();
import "DPI-C" context function void close_file();

logic [31:0] error;
int sample_rate, num_channels, bits_per_sample;

initial begin
  hello();
  error = open_file("test.wav");
  if (error === 1) begin
    $display("Error opening file");
    $finish;
  end

  sample_rate = 44100;
  num_channels = 2;
  bits_per_sample = 16;

  write_wav_header(sample_rate, num_channels, bits_per_sample);
  write_sine(sample_rate, num_channels, bits_per_sample, sample_rate, 220);
  update_wav_header();
  // write_bytes("Hello World", 11);
  close_file();
  $finish;
end

endmodule
