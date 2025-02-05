
# Vivaldi

A mini FPGA synthesizer built for the [Nexys Video Artix-7 FPGA](https://digilent.com/reference/programmable-logic/nexys-video/start?redirect=1) from Digilent.

## Vivado Notes

- Most installations of Vivado will not contain the Nexys Video Board.
  - In the board configuration page in project setup, click Refresh, then wait a couple minutes for Vivado to pull all board files. T
  - Search for "Nexys Video", and click the Download button to retrieve the board files.

## General Notes

- Upload bitstreams with [OpenFPGALoader](https://github.com/trabucayre/openFPGALoader)
  - `openFPGALoader -b nexysVideo bitstream.bit`

## References

- Tiny Synth (VHDL): [https://github.com/gundy/tiny-synth](https://github.com/gundy/tiny-synth)
  - Blog: [https://thetinysynth.wordpress.com/technical-details/](https://thetinysynth.wordpress.com/technical-details/)
- FPGA Wave Generator: [https://github.com/kiran2s/FPGA-Synthesizer](https://github.com/kiran2s/FPGA-Synthesizer)
- MichD FPGA MIDI Synth: [https://michd.me/blog/yearproject-fpga-midi-synth/](https://michd.me/blog/yearproject-fpga-midi-synth/)
- .wav testbench
  - Reading .wav using DPI-C: [https://www.rtlaudiolab.com/009-reading-wave-files-in-systemverilog/](https://www.rtlaudiolab.com/009-reading-wave-files-in-systemverilog/)
  - Wave format specifics: [http://soundfile.sapp.org/doc/WaveFormat/](http://soundfile.sapp.org/doc/WaveFormat/)
-
