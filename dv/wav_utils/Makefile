
run: new
	verilator --binary fileutil.cpp wavewriter.sv --top wavewriter -CFLAGS "--std=c++14"
	./obj_dir/Vwavewriter

new:
	rm test.wav
	touch test.wav

clean:
	rm -rf obj_dir

