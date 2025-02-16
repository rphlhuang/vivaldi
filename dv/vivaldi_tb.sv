
module vivaldi_tb;

vivaldi_runner vivaldi_runner ();

initial begin
    $dumpfile("dump.fst");
    $dumpvars;
    $display("----  BEGIN SIMULATION  ----");

    vivaldi_runner.hello_cpp();
    vivaldi_runner.reset();
    vivaldi_runner.wait_num_cycles(10);

    // IF YOU WANT TO KEEP YOUR EARDRUMS
    // ALWAYS SET THE GAIN BELOW 100%!
    vivaldi_runner.set_gain_percent(100); 

    vivaldi_runner.open_wav_file();

    vivaldi_runner.select_sine();
    vivaldi_runner.write_next_num_secs(1);
    vivaldi_runner.select_square();
    vivaldi_runner.write_next_num_secs(1);
    vivaldi_runner.select_sawtooth();
    vivaldi_runner.write_next_num_secs(1);
    vivaldi_runner.select_triangle();
    vivaldi_runner.write_next_num_secs(1);

    vivaldi_runner.close_wav_file();

    $display("----  FINISH SIMULATION  ----");
    $finish;
end

endmodule
