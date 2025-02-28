`timescale 1ns/1ps

module adsr_envelope_tb;

 adsr_envelope_runner adsr();

  initial begin
    $dumpfile( "dump.fst" );
    $dumpvars;
    $display( "Begin simulation." );
    $urandom(100);
    $timeformat( -3, 3, "ms", 0);
    //amp_runner.init_sine_lut();
    adsr.reset();
    adsr.run_test();
    $display( "End simulation." );
    $finish;
  end

endmodule
