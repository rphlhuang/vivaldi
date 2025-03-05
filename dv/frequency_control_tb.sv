
module frequency_control_tb;

frequency_control_runner frequency_control_runner ();

initial begin
    $dumpfile("dump.fst");
    $dumpvars;
    $display("----  BEGIN SIMULATION  ----");

    frequency_control_runner.hello_cpp();
    frequency_control_runner.reset();
    frequency_control_runner.wait_num_cycles(10);

    // IF YOU WANT TO KEEP YOUR EARDRUMS
    // ALWAYS SET THE GAIN BELOW 100%!
    frequency_control_runner.set_gain_percent(80); 

    frequency_control_runner.open_wav_file();

    frequency_control_runner.select_sine();
    frequency_control_runner.write_next_num_secs(10);

    // repeat(100) frequency_control_runner.reset();
    // frequency_control_runner.select_square();
    // frequency_control_runner.write_next_num_secs(5);

    // repeat(100) frequency_control_runner.reset();
    // frequency_control_runner.select_triangle();
    // frequency_control_runner.write_next_num_secs(5);

    // repeat(100) frequency_control_runner.reset();
    // frequency_control_runner.select_sawtooth();
    // frequency_control_runner.write_next_num_secs(5);

    frequency_control_runner.close_wav_file();

    $display("----  FINISH SIMULATION  ----");
    $finish;
end

endmodule
