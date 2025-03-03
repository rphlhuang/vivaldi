module top_tb;

top_runner top_runner ();

initial begin
    $dumpfile("dump.fst");
    $dumpvars;
    $display("----  BEGIN SIMULATION  ----");

    top_runner.hello_cpp();
    top_runner.reset();
    top_runner.wait_num_cycles(10);

    // IF YOU WANT TO KEEP YOUR EARDRUMS
    // ALWAYS SET THE GAIN BELOW 100%!
    top_runner.set_gain_percent(80); 

    top_runner.open_wav_file();

    top_runner.set_frequency(4'd5);

    top_runner.select_sine();
    top_runner.write_next_num_secs(1);
    top_runner.select_square();
    top_runner.write_next_num_secs(1);
    top_runner.select_triangle();
    top_runner.write_next_num_secs(1);
    top_runner.select_sawtooth();
    top_runner.write_next_num_secs(1);

    top_runner.close_wav_file();

    $display("----  FINISH SIMULATION  ----");
    $finish;
end

endmodule
