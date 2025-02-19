#include <iostream>
#include <iomanip>
#include <fstream>
#include <string>
#include <cmath>
#include <vector>
#include <algorithm>


extern "C" {

    // global output file stream (for simplicity)
    std::ofstream g_out;
    int g_dataBytesWritten = 0;

    // open a file for binary writing; returns true if successful
    int open_file(const std::string &filename) {
        g_out.open(filename, std::ios::binary | std::ios::out);
        if (!g_out.is_open()) {
            std::cerr << "Error: could not open file " << filename << "\n";
            return 1;
        }
        return 0;
    }

    // write data and update the global counter
    void write_data_bytes(const unsigned char* data, int length, int flip_endian) {
        if (!g_out) {
            std::cerr << "Error: file not open for writing.\n";
            return;
        }
        if (length < 0) {
            std::cerr << "Error: negative length provided.\n";
            return;
        }

        if (flip_endian == 1) {
            // create a temporary copy and reverse it
            std::vector<unsigned char> tmp(data, data + length);
            std::reverse(tmp.begin(), tmp.end());
            g_out.write(reinterpret_cast<const char*>(tmp.data()), length);
        } else {
            g_out.write(reinterpret_cast<const char*>(data), length);
        }

        g_dataBytesWritten += length;
        // std::cout << "Wrote " << length << " bytes; total written: " << g_dataBytesWritten << std::endl;
    }

    void write_wav_header(int sample_rate, int num_channels, int bits_per_sample) {
        if (!g_out) {
            std::cerr << "Error: file not open for writing.\n";
            return;
        }

        // RIFF header
        g_out.write("RIFF", 4);         // RIFF
        g_out.write("\0\0\0\0", 4);     // Chunk Size: size of entire file without RIFF and this field (file size - 8)
        g_out.write("WAVE", 4);         // WAVE

        // fmt subchunk / SubChunk1
        g_out.write("fmt ", 4);         // SubChunk1ID: fmt
        g_out.write("\x10\0\0\0", 4);   // SubChunk1Size size of fmt chunk: 16 for PCM
        g_out.write("\x01\0", 2);       // AudioFormat: 1 = PCM
        g_out.write(reinterpret_cast<const char*>(&num_channels), 2);                                       // NumChannels: 1 for mono, 2 for stereo
        g_out.write(reinterpret_cast<const char*>(&sample_rate), 4);                                        // SampleRate: 8000, 44100, etc.
        int byte_rate = sample_rate * num_channels * bits_per_sample / 8;
        g_out.write(reinterpret_cast<const char*>(&byte_rate), 4);                                          // ByteRate: SampleRate * NumChannels * BitsPerSample/8
        int block_align = num_channels * bits_per_sample / 8;
        g_out.write(reinterpret_cast<const char*>(&block_align), 2);                                        // BlockAlign: NumChannels * BitsPerSample/8
        g_out.write(reinterpret_cast<const char*>(&bits_per_sample), 2);                                    // BitsPerSample: 8 bits = 8, 16 bits = 16

        // data subchunk
        g_out.write("data", 4);         // SubChunk2ID: data
        g_out.write("\0\0\0\0", 4);     // SubChunk2Size: placeholder for data size
    }

    void write_sine(int sample_rate, int num_channels, int bits_per_sample, int num_samples, int frequency) {
        if (!g_out) {
            std::cerr << "Error: file not open for writing.\n";
            return;
        }

        const float amplitude = 0.5f;
        const float two_pi = 6.28318530718f;
        const float increment = 1.0f / static_cast<float>(sample_rate);
        float t = 0.0f;

        for (int i = 0; i < num_samples; i++) {
            float value = amplitude * sin(two_pi * frequency * t);
            // scale amplitude up to 16-bit range
            short sample = static_cast<short>(value * 32767.0f);
            // std::cout << "Writing sample w/ value " << std::setw(10) << sample << std::endl;
            // write sample to each channel
            for (int j = 0; j < num_channels; j++) {
                write_data_bytes(reinterpret_cast<const unsigned char*>(&sample), bits_per_sample / 8, 0);
            }
            t += increment;
        }
    }

    // call this after all audio data has been written, to update the header with the correct data size
    void update_wav_header() {
        if (!g_out) {
            std::cerr << "Error: file not open for updating header.\n";
            return;
        }
        // calculate sizes
        int dataSize = g_dataBytesWritten;
        int chunkSize = 36 + dataSize; // total file size - 8
        std::cout << "Updating header w/ chunk size: " << chunkSize << " bytes\n";
        std::cout << "Updating header w/ data size: " << dataSize << " bytes\n";

        // update ChunkSize at byte offset 4 (4 bytes)
        g_out.seekp(4, std::ios::beg);
        g_out.write(reinterpret_cast<const char*>(&chunkSize), 4);

        // update SubChunk2Size at byte offset 40 (4 bytes)
        g_out.seekp(40, std::ios::beg);
        g_out.write(reinterpret_cast<const char*>(&dataSize), 4);

        // move pointer back to end of file
        g_out.seekp(0, std::ios::end);
    }


    // // write 'length' bytes from data array to the open file
    // void write_bytes(const unsigned char* data, int length) {
    //     if (!g_out) {
    //         std::cerr << "Error: file not open for writing.\n";
    //         return;
    //     }
    //     if (length < 0) {
    //         std::cerr << "Error: negative length provided.\n";
    //         return;
    //     }
    //     g_out.write(reinterpret_cast<const char*>(data), static_cast<std::streamsize>(length));
    //     if (!g_out.good())
    //         std::cerr << "Error: writing failed.\n";
    // }

    // close the file if it is open
    void close_file() {
        if (g_out.is_open())
            g_out.close();
    }

    void hello() {
        std::cout << "Hello from C++\n" << std::endl;
    }
}
