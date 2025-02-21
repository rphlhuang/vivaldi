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

  adsr_envelope #(
    .DATA_WIDTH(DATA_WIDTH),
    .CLK_PERIOD(CLK_PERIOD),
    .ATTACK_TIME(100),//clk cycles
    .DECAY_TIME(100),
    .SUSTAIN_LEVEL(0.5),//sustain levelm what it drops to
    .RELEASE_TIME(100)
    ) adsr (
        .clk_i(clk),
        .rst_i(rst),
        .valid_i(valid_i),
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
  endtask

  task automatic run_test;
    int i;
    #100;
    valid_i = 1'b1;
    #1_000_000;
    valid_i = 1'b0;
    #1_000_000;
/*
    for (i = 0; i < SINE_SAMPLE_SIZE * 20; i++) begin //n periods
        //input sin
        signal_i = sine_lut[i % SINE_SAMPLE_SIZE];
        //modulator with lower frequency
        modulator_index = i * modulator_frequency;//to make it some scale less frequent than the input signal sin
        modulator_wave_value = $sin(2 * PI * modulator_index / SINE_SAMPLE_SIZE);
        modulator_i = modulator_wave_value * 256;//scale amplitude
        #(CLK_PERIOD);
    end
    */
endtask


endmodule
