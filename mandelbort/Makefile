CC = icpx
SRC = src/mandelbrot.cpp
BUILD = build210

FLAGS = -O2 -march=native -fopenmp

NAME = $(basename $(notdir $(SRC)))

TARGET = $(BUILD)/$(NAME)

all: $(TARGET)

$(TARGET): $(SRC) | $(BUILD)
	$(CC) $(FLAGS) $< -o $@

$(BUILD):
	mkdir -p $(BUILD)

clean:
	rm -rf $(BUILD)
