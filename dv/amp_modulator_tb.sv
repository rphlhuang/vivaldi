`timescale 1ns/1ps

module amp_modulator_tb;

  amp_modulator_runner amp_runner();

  initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);
    $timeformat( -3, 3, "ms", 0);
    amp_runner.init_sine_lut();
    amp_runner.reset();
    amp_runner.run_test();
    $display( "End simulation." );
    $finish;
  end

endmodule
