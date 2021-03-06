#!/usr/bin/make -f

OUT_DIR = output
COMPRESSED_DATA_DIR=$(OUT_DIR)/compressed
DECOMPRESSED_DATA_DIR=$(OUT_DIR)/decompressed

.PHONY: build
build: static_huffman adaptive_huffman golomb tunstall arithmetic lz77 lzw


STATHUFF_DIR = static-huffman
STATHUFF_SRCS = $(STATHUFF_DIR)/*.c
STATHUFF_EXECUTABLE = static-huffman
.PHONY: static_huffman
static_huffman: create_out_dir
	gcc -O2 -std=c11 -D_POSIX_C_SOURCE=2 -o $(OUT_DIR)/$(STATHUFF_EXECUTABLE) $(STATHUFF_SRCS) -I$(STATHUFF_DIR)


ADAPTHUFF_DIR = adaptive-huffman
ADAPTHUFF_SRCS = $(ADAPTHUFF_DIR)/*.c
ADAPTHUFF_EXECUTABLE = adaptive-huffman
.PHONY: adaptive_huffman
adaptive_huffman: create_out_dir
	gcc -O2 -std=c99 -lm -o $(OUT_DIR)/$(ADAPTHUFF_EXECUTABLE) $(ADAPTHUFF_SRCS) -I$(ADAPTHUFF_DIR)

GOLOMB_DIR = golomb-coding
GOLOMB_SRCS = $(GOLOMB_DIR)/*.c
GOLOMB_EXECUTABLE = golomb
.PHONY: golomb
golomb: create_out_dir
	gcc -O2 -o $(OUT_DIR)/$(GOLOMB_EXECUTABLE) $(GOLOMB_SRCS) -I$(GOLOMB_DIR) -lz -lm

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
	gcc -O2 -o $(OUT_DIR)/$(LZ77_EXECUTABLE) $(LZ77_SRCS) -I$(LZ77_DIR) -lm


LZW_DIR = lzw
LZW_SRCS =	$(LZW_DIR)/lzw.c
LZW_EXECUTABLE = lzw
.PHONY: lzw
lzw: create_out_dir
	gcc -O2 -o $(OUT_DIR)/$(LZW_EXECUTABLE) $(LZW_SRCS) -I$(LZW_DIR)


TARGET_DATA_SETS=dnahh englishhh SD1 SD2 SD3 SD4 xmlhh
DATA_DIR=Data
.PHONY: compress-all
compress-all: build
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(STATHUFF_EXECUTABLE) \
		-i $(DATA_DIR)/$(data) -o $(COMPRESSED_DATA_DIR)/$(data).$(STATHUFF_EXECUTABLE);)
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(ADAPTHUFF_EXECUTABLE) \
		-c $(DATA_DIR)/$(data) $(COMPRESSED_DATA_DIR)/$(data).$(ADAPTHUFF_EXECUTABLE);)
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(TUNSTALL_EXECUTABLE) \
		c $(DATA_DIR)/$(data) $(COMPRESSED_DATA_DIR)/$(data).$(TUNSTALL_EXECUTABLE);)
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(ARITHMETIC_EXECUTABLE) \
		e $(DATA_DIR)/$(data) $(COMPRESSED_DATA_DIR)/$(data).$(ARITHMETIC_EXECUTABLE);)
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(LZ77_EXECUTABLE) \
		-c -i $(DATA_DIR)/$(data) -o $(COMPRESSED_DATA_DIR)/$(data).$(LZ77_EXECUTABLE);)
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(LZW_EXECUTABLE) \
		c $(DATA_DIR)/$(data) $(COMPRESSED_DATA_DIR)/$(data).$(LZW_EXECUTABLE);)
	
.PHONY: decompress-all
decompress-all:
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(STATHUFF_EXECUTABLE) \
		-d -i $(COMPRESSED_DATA_DIR)/$(data).$(STATHUFF_EXECUTABLE) -o $(DECOMPRESSED_DATA_DIR)/$(data).$(STATHUFF_EXECUTABLE);)
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(ADAPTHUFF_EXECUTABLE) \
		-d $(COMPRESSED_DATA_DIR)/$(data).$(ADAPTHUFF_EXECUTABLE) $(DECOMPRESSED_DATA_DIR)/$(data).$(ADAPTHUFF_EXECUTABLE);)
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(TUNSTALL_EXECUTABLE) \
		d $(COMPRESSED_DATA_DIR)/$(data).$(TUNSTALL_EXECUTABLE) $(DECOMPRESSED_DATA_DIR)/$(data).$(TUNSTALL_EXECUTABLE);)
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(ARITHMETIC_EXECUTABLE) \
		d $(COMPRESSED_DATA_DIR)/$(data).$(ARITHMETIC_EXECUTABLE) $(DECOMPRESSED_DATA_DIR)/$(data).$(ARITHMETIC_EXECUTABLE);)
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(LZ77_EXECUTABLE) \
		-d -i $(COMPRESSED_DATA_DIR)/$(data).$(LZ77_EXECUTABLE) -o $(DECOMPRESSED_DATA_DIR)/$(data).$(LZ77_EXECUTABLE);)
	$(foreach data,$(TARGET_DATA_SETS),$(OUT_DIR)/$(LZW_EXECUTABLE) \
		d $(COMPRESSED_DATA_DIR)/$(data).$(LZW_EXECUTABLE) $(DECOMPRESSED_DATA_DIR)/$(data).$(LZW_EXECUTABLE);)

.PHONY: clean
clean:
	rm -rf $(OUT_DIR)

.PHONY: create_out_dir
create_out_dir:
	mkdir -p $(OUT_DIR) $(COMPRESSED_DATA_DIR) $(DECOMPRESSED_DATA_DIR)
