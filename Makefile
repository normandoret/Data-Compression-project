#!/usr/bin/make -f

OUT_DIR = output

ARITHMETIC_DIR = Arithmetic
ARITHMETIC_SRCS += \
	$(ARITHMETIC_DIR)/compress.cpp \
	$(ARITHMETIC_DIR)/decode.cpp \
	$(ARITHMETIC_DIR)/encode.cpp \
	$(ARITHMETIC_DIR)/main.cpp
ARITHMETIC_EXECUTABLE = arithmetic

.PHONY: build
all: arithmetic huffman

.PHONY: arithmetic
arithmetic: create_out_dir
	g++ -O2 -o $(OUT_DIR)/$(ARITHMETIC_EXECUTABLE) $(ARITHMETIC_SRCS) -I$(ARITHMETIC_DIR)

.PHONY: test
test:

.PHONY: clean
clean:
	rm -rf $(OUT_DIR)

.PHONY: create_out_dir
create_out_dir:
	mkdir -p $(OUT_DIR)
