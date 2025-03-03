# Variables
CXX = g++
CXXFLAGS = -Wall -g
TARGET = assembler_tool
SRC = main.cpp Assembler_tool.cpp

# Default target: build the assembler_tool executable
all: $(TARGET)

# Rule to build the executable
$(TARGET): $(SRC)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SRC)

# Clean up
clean:
	rm -f $(TARGET) *.o

.PHONY: all clean
