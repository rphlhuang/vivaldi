`timescale 1ns/1ps

module amp_modulator_runner;

  parameter DATA_WIDTH = 16;
  parameter CLK_PERIOD = 10;
  parameter integer SINE_SAMPLE_SIZE = 256; //256 samples for full sine wave
  parameter real PI = 3.14159;

  logic clk;
  logic rst;
  logic signed [DATA_WIDTH-1:0] signal;
  logic signed [DATA_WIDTH-1:0] modulator;
  logic signed [DATA_WIDTH-1:0] signal_out;

  // Instantiate the DUT
  amp_modulator #(.DATA_WIDTH(DATA_WIDTH)) uut (
      .clk_i(clk),
      .rst_i(rst),
      .signal_i(signal),
      .modulator_i(modulator),
      .signal_o(signal_out)
  );

  always #(CLK_PERIOD / 2) clk = ~clk;

  //lut
  logic signed [DATA_WIDTH-1:0] sine_lut [0:SINE_SAMPLE_SIZE-1];

  task automatic init_sine_lut;
    int i;
    for (i = 0; i < SINE_SAMPLE_SIZE; i++) begin
      sine_lut[i] = $rtoi($sin(2 * PI * i / SINE_SAMPLE_SIZE) * (2**(DATA_WIDTH-2)));//sigmoid of sine wave
    end
  endtask

  task automatic reset;
    int i;
    rst = 1;
    #(CLK_PERIOD * 5);
    rst = 0;
  endtask

  task automatic run_test;
    for (i = 0; i < SINE_SAMPLE_SIZE * 3; i++) begin//n periods
      signal = sine_lut[i % SINE_SAMPLE_SIZE];//actual sin wave generated
      modulator = (i / 10) * 256;//increase volume
      #(CLK_PERIOD);
    end
    $stop;
  endtask

endmodule
