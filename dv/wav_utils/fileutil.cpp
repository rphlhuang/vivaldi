#include <iostream>
#include <fstream>
#include <string>

extern "C" {

    // global output file stream (for simplicity)
    std::ofstream g_out;

    // open a file for binary writing; returns true if successful
    int open_file(const std::string &filename) {
        g_out.open(filename, std::ios::binary | std::ios::out);
        if (!g_out.is_open()) {
            std::cerr << "error: could not open file " << filename << "\n";
            return 0;
        }
        return 1;
    }

    // write 'length' bytes from data array to the open file
    void write_bytes(const unsigned char* data, int length) {
        if (!g_out) {
            std::cerr << "error: file not open for writing.\n";
            return;
        }
        if (length < 0) {
            std::cerr << "error: negative length provided.\n";
            return;
        }
        g_out.write(reinterpret_cast<const char*>(data), static_cast<std::streamsize>(length));
        if (!g_out.good())
            std::cerr << "error: writing failed.\n";
    }

    // close the file if it is open
    void close_file() {
        if (g_out.is_open())
            g_out.close();
    }

    void hello() {
        std::cout << "Hello from C++\n" << std::endl;
    }
}
