
# Vivaldi

A mini FPGA synthesizer built for the [Nexys Video Artix-7 FPGA](https://digilent.com/reference/programmable-logic/nexys-video/start?redirect=1) from Digilent. Contains 4 oscillators (sine, square, sawtooth, triangle), an envelope generator, an amplitude modulator, and a top module that accepts [encoder](https://digilent.com/shop/pmod-enc-rotary-encoder/?srsltid=AfmBOoo1wKf2iMx46q_8YFrvncR6rilzPuZqXuqj_DP1sRqSlVcLAPNx) inputs from the attack and delay parameters of the envelope, as well as a [keypad](https://digilent.com/shop/pmod-kypd-16-button-keypad/?srsltid=AfmBOopqdB8xALTOwe-Yw8rOTSu3CqQDX95_Dyj0c3LvjP7ewICEGAvx) input that controls the frequency of the output signal.

- Run testbench: `make sim`
- Run synthesis, implementation, and upload to Nexys Video: 

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
