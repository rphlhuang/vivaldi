dv/frequency_control_runner.sv
dv/frequency_control_tb.sv

dv/wav_utils/wavewriter.sv
dv/wav_utils/fileutil.cpp

dv/amp_modulator_tb.sv
dv/amp_modulator_runner.sv
dv/adsr_envelope_tb.sv
dv/adsr_envelope_runner.sv

--timing
-j 0
-Wall
--assert
--trace-fst
--trace-structs
--main-top-name "-"

// Run with +verilator+rand+reset+2
--x-assign unique
--x-initial unique

-Werror-IMPLICIT
-Werror-USERERROR
-Werror-LATCH

// for ARM Macs
-CFLAGS -std=c++14
