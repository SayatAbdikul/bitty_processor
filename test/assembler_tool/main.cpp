#include "Assembler_tool.h"
#include <iostream>
#include <fstream>
#include <getopt.h>
#include <string>

int main(int argc, char *argv[]) {
    Assembler_tool tool;
    std::string mode, inputFileName, outputFileName;

    // Parsing CL arguments
    int opt, output_file_bool=0; //output_file_bool is to know is there an output file
    while ((opt = getopt(argc, argv, "i:o:ad")) != -1) {
        switch (opt) {
            case 'i':
                inputFileName = optarg;
                break;
            case 'o':
                outputFileName = optarg;
                output_file_bool = 1;
                break;
            case 'a':
                mode = "assemble";
                break;
            case 'd':
                mode = "disassemble";
                break;
            default:
                std::cerr << "Usage: " << argv[0] << " -i <input file> [-o <output file>] -a|-d\n";
                return EXIT_FAILURE;
        }
    }
    if (mode == "assemble") {
        std::ifstream inputFile(inputFileName);
        std::ofstream outputFile(outputFileName, std::ios::binary);
        if(output_file_bool){
            if (!inputFile.is_open() || !outputFile.is_open()) {
                std::cerr << "Error opening file(s)" << std::endl;
                return EXIT_FAILURE;
            }
        }

        std::string line;
        while (std::getline(inputFile, line)) {
            int instruction = tool.Assemble(line);
            if(output_file_bool) outputFile.write(reinterpret_cast<char*>(&instruction), sizeof(instruction));
        }

        inputFile.close();
        if(output_file_bool) outputFile.close();
    } else if (mode == "disassemble") {
        std::ifstream inputFile(inputFileName, std::ios::binary);
        std::ofstream outputFile(outputFileName);
        if(output_file_bool){
            if (!inputFile.is_open() || !outputFile.is_open()) {
                std::cerr << "Error opening file(s)" << std::endl;
                return EXIT_FAILURE;
            }
        }

        int instruction;
        while (inputFile.read(reinterpret_cast<char*>(&instruction), sizeof(instruction))) {
            std::string disassembled = tool.Disassemble(instruction);
            if(output_file_bool) outputFile << disassembled << std::endl;
        }

        inputFile.close();
        if(output_file_bool) outputFile.close();
    } else {
        std::cerr << "Invalid mode" << std::endl;
        return EXIT_FAILURE;
    }

    return EXIT_SUCCESS;
}
