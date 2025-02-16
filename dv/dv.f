
dv/dv_pkg.sv

dv/vivaldi_tb.sv
dv/wav_utils/wavewriter.sv
dv/wav_utils/fileutil.cpp

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
