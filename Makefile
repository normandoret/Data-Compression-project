#!/usr/bin/make -f

OUT_DIR = output


.PHONY: all
all: tunstall arithmetic lz77 lzw

TUNSTALL_DIR = tunstall
TUNSTALL_SRCS += \
	$(TUNSTALL_DIR)/main.cpp \
	$(TUNSTALL_DIR)/tunstall.cpp
TUNSTALL_EXECUTABLE = tunstall
.PHONY: tunstall
tunstall: create_out_dir
	g++ -O2 -o $(OUT_DIR)/$(TUNSTALL_EXECUTABLE) $(TUNSTALL_SRCS) -I$(TUNSTALL_DIR)


ARITHMETIC_DIR = Arithmetic
ARITHMETIC_SRCS = $(ARITHMETIC_DIR)/*.cpp
ARITHMETIC_EXECUTABLE = arithmetic
.PHONY: arithmetic
arithmetic: create_out_dir
	g++ -O2 -o $(OUT_DIR)/$(ARITHMETIC_EXECUTABLE) $(ARITHMETIC_SRCS) -I$(ARITHMETIC_DIR)


LZ77_DIR = lz77
LZ77_SRCS =	$(LZ77_DIR)/*.c
LZ77_EXECUTABLE = lz77
.PHONY: lz77
lz77: create_out_dir
	gcc -O2 -std=c90 -o $(OUT_DIR)/$(LZ77_EXECUTABLE) $(LZ77_SRCS) -I$(LZ77_DIR)


LZW_DIR = lzw
LZW_EXECUTABLE = lzw
.PHONY: lzw
lzw: create_out_dir
	gcc -O2 -o $(OUT_DIR)/$(LZW_EXECUTABLE) $(LZW_DIR)/lzw.c -I$(LZW_DIR)


.PHONY: test
test:

.PHONY: clean
clean:
	rm -rf $(OUT_DIR)

.PHONY: create_out_dir
create_out_dir:
	mkdir -p $(OUT_DIR)
