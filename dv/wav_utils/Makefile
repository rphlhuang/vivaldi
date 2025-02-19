
run: new
	verilator --binary fileutil.cpp wavewriter.sv --top wavewriter -CFLAGS "--std=c++14"
	./obj_dir/Vwavewriter

read:
	rm -f obj_dir/wavereader.fst
	verilator --binary wavereader.sv -CFLAGS "--std=c++14" -Wno-fatal --trace
	./obj_dir/Vwavereader
new:
	rm test.wav
	touch test.wav

clean:
	rm -rf obj_dir

