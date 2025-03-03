#ifndef ASSEMBLER_TOOL_H
#define ASSEMBLER_TOOL_H
#include <iostream>
#include <fstream>
#include <getopt.h>
#include <string>

class Assembler_tool {
public:
    std::string commands[8] = {"ADD", "SUB", "AND", "OR", "XOR", "SHL", "SHR", "CMP"};
    Assembler_tool();
    int Assemble(std::string instruction);
    int AssembleGeneral(std::string instruction);
    int AssembleImmediate(std::string instruction);
    int AssembleCondition(std::string instruction);
    std::string Disassemble(int instruction);
    std::string DisassembleGeneral(int instruction);
    std::string DisassembleImmediate(int instruction);
    std::string DisassembleCondition(int instruction);
};

#endif