#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <fstream>

extern "C" {
    void hello() {
        std::cout << "Hello from C++\n" << std::endl;
    }
}
