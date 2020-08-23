###  -*-Makefile-*-

# *** DO NOT EDIT! ***
# *** This file is program-generated, not hand-written. ***
# ================================================================

REPO ?= $(FLUTE)
ARCH ?= RV64ACIMU

# ================================================================
# RISC-V config macros passed into Bluespec 'bsc' compiler

BSC_COMPILATION_FLAGS += \
	-D RV64 \
	-D ISA_PRIV_M  -D ISA_PRIV_U  \
	-D ISA_I  -D ISA_M  -D ISA_A  -D ISA_C  \
	-D SHIFT_BARREL    \
	-D MULT_SYNTH    \
	-D Near_Mem_Caches    \
	-D FABRIC64    \
	-D WATCH_TOHOST    \
	-D INCLUDE_ACCEL0    \


CUSTOM_DIRS = ./src

# Default ISA test

TEST ?= rv64ui-p-add

#================================================================
# Common boilerplate rules

include  ./Include_Common.mk

#================================================================
# Makefile rules for building for specific simulator: bluesim

include  ./Include_bluesim.mk

#================================================================
# Test runs

.PHONY: run_hello
run_hello:
	cp  ../Resources/C_programs/hello/hello_Mem.hex     ./Mem.hex
	cp  ../Resources/C_programs/hello/symbol_table.txt  ./symbol_table.txt
	./exe_HW_sim  +tohost

.PHONY: run_mergesort
run_mergesort:
	cp  ../Resources/C_programs/mergesort/mergesort_Mem.hex  ./Mem.hex
	cp  ../Resources/C_programs/mergesort/symbol_table.txt   ./symbol_table.txt
	./exe_HW_sim  +tohost
