`timescale 1ns/1ps

module adsr_envelope_runner;

  parameter DATA_WIDTH = 16;
  parameter CLK_PERIOD = 10;
  parameter integer SINE_SAMPLE_SIZE = 256; //256 samples for full sine wave
  parameter real PI = 3.14159;

  logic clk;
  logic rst;
  logic valid_i;
  logic ready_o;
  logic signed [DATA_WIDTH-1:0] envelope_o;
  logic [DATA_WIDTH-1:0] attack_time, decay_time, sustain_level, release_time;

  adsr_envelope #(.DATA_WIDTH(DATA_WIDTH)) uut (
      .clk_i(clk),
      .rst_i(rst),
      .valid_i(valid_i),
      .attack_time_i(attack_time),    
      .decay_time_i(decay_time),      
      .sustain_level_i(sustain_level),
      .release_time_i(release_time),  
      .ready_o(ready_o),
      .envelope_o(envelope_o)
  );

  always #(CLK_PERIOD / 2) clk = ~clk;

  //lut
  //logic signed [DATA_WIDTH-1:0] sine_lut [0:SINE_SAMPLE_SIZE-1];
/*
  task automatic init_sine_lut;
    int i;
    for (i = 0; i < SINE_SAMPLE_SIZE; i++) begin
      sine_lut[i] = $rtoi($sin(2 * PI * i / SINE_SAMPLE_SIZE) * (2**(DATA_WIDTH-2)));//sigmoid of sine wave scaled to fit within bit width signed range
    end
  endtask
*/
  task automatic reset;
    clk = 0;
    rst = 1;
    #(CLK_PERIOD * 5);
    rst = 0;
    attack_time = 16'd100;
    decay_time = 16'd100;
    release_time = 16'd100;
    sustain_level = 16'd16384;//0.5*(2^(16-1)) fixed point
  endtask

  task automatic run_test;
    int i;
    #100;
    valid_i = 1'b1;
    #10_000;
    valid_i = 1'b0;
    #1_000;
endtask


endmodule
