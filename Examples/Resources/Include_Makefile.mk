###  -*-Makefile-*-
# Copyright (c) 2016-2020 Bluespec, Inc.  All Rights Reserved.

# ================================================================
# This is an example Makefile for the examples in this tutorial

# You should only have to edit the variable definitions in the
# following section (or override them from the 'make' command line)

# Your PATH should include the directory where your 'bsc' binary lives
# For example, if you cloned:
#     https://github.com/B-Lang-org/bsc
# into
#     ~/git_clones/bsc
# and built 'bsc' there using the standard 'make all', you'd add
#     ~/git_clones/bsc/inst/bin
# to your PATH
#
# Do 'bsc -v' or 'bsc -help' to test that you can invoke bsc.

# ================================================================
# Please modify the following for your installation and setup

# Directory containing this tutorial
TUTORIAL ?= ..

# Set this to the command that invokes your Verilog simulator
V_SIM ?= iverilog
# V_SIM ?= cvc
# V_SIM ?= cver
# V_SIM ?= vcsi
# V_SIM ?= vcs
# V_SIM ?= modelsim
# V_SIM ?= ncsim
# V_SIM ?= ncverilog

# ================================================================
# You should not have to change anything below this line

RESOURCES_DIR ?= $(TUTORIAL)/Resources

TOPLANG ?= BH

ifeq ($(TOPLANG),BSV)
  SRC_EXT=bsv
else ifeq ($(TOPLANG),BH)
  SRC_EXT=bs
else
  SRC_EXT=TOPLANG_NOT_DEFINED
endif

TOPFILE   ?= src/Top.$(SRC_EXT)
TOPMODULE ?= mkTop

BSC_COMP_FLAGS += -keep-fires  -aggressive-conditions  -no-warn-action-shadowing  -check-assert  -cpp \
		+RTS -K128M -RTS  -show-range-conflict \
		$(BSC_COMP_FLAG1)  $(BSC_COMP_FLAG2)  $(BSC_COMP_FLAG3)

BSC_LINK_FLAGS += -keep-fires

BSC_PATHS = -p $(BSC_PATH1)src:$(RESOURCES_DIR):+

.PHONY: help
help:
	@echo ""
	@echo "Targets for 'make':"
	@echo "    help                Print this information"
	@echo ""
	@echo "    Bluesim:"
	@echo "        b_compile       Compile for Bluesim"
	@echo "        b_link          Link a Bluesim executable"
	@echo "        b_sim           Run the Bluesim simulation executable"
	@echo "        b_all           Convenience for 'make b_compile b_link b_sim'"
	@echo "        b_sim_vcd       Run the Bluesim simulation executable and generate VCD"
	@echo ""
	@echo "    Verilog generation and Verilog sim:"
	@echo "        v_compile       Compile for Verilog (Verilog files generated in verilog_RTL/)"
	@echo "        v_link          Link a Verilog simulation executable"
	@echo "                            (current simulator:" $(V_SIM) " (redefine V_SIM for other Verilog simulators)"
	@echo "        v_sim           Run the Verilog simulation executable"
	@echo "        v_all           Convenience for 'make v_compile v_link v_sim'"
	@echo "        v_sim_vcd       Run the Verilog simulation executable and dump VCD"
	@echo ""
	@echo "    clean               Delete intermediate files in build_b_sim/ and build_v/ dirs"
	@echo "    full_clean          Delete all but this Makefile"

# ================================================================
# Bluesim compile/link/simulate

B_SIM_DIRS = -simdir build_b_sim -bdir build_b_sim -info-dir build_b_sim
B_SIM_EXE = $(TOPMODULE)_b_sim

.PHONY: b_all
b_all: b_compile  b_link    b_sim

.PHONY: b_compile
b_compile:
	mkdir  -p build_b_sim
	@echo Compiling for Bluesim ...
	bsc -u -sim $(B_SIM_DIRS) $(BSC_COMP_FLAGS) $(BSC_PATHS) -g $(TOPMODULE)  $(TOPFILE) 
	@echo Compiling for Bluesim finished

.PHONY: b_link
b_link:
	@echo Linking for Bluesim ...
	bsc -e $(TOPMODULE) -sim -o $(B_SIM_EXE) $(B_SIM_DIRS) $(BSC_LINK_FLAGS) $(BSC_PATHS)
	@echo Linking for Bluesim finished

.PHONY: b_sim
b_sim:
	@echo Bluesim simulation ...
	./$(B_SIM_EXE)
	@echo Bluesim simulation finished

.PHONY: b_sim_vcd
b_sim_vcd:
	@echo Bluesim simulation and dumping VCD in dump.vcd ...
	./$(B_SIM_EXE)  -V
	@echo Bluesim simulation and dumping VCD in dump.vcd finished

# ----------------------------------------------------------------
# Verilog compile/link/sim

V_DIRS = -vdir verilog_RTL -bdir build_v -info-dir build_v
V_SIM_EXE = $(TOPMODULE)_v_sim

.PHONY: v_all
v_all: v_compile  v_link  v_sim

.PHONY: v_compile
v_compile:
	mkdir  -p build_v
	mkdir  -p verilog_RTL
	@echo Compiling for Verilog ...
	bsc -u -verilog $(V_DIRS) $(BSC_COMP_FLAGS) $(BSC_PATHS) -g $(TOPMODULE)  $(TOPFILE)
	@echo Compiling for Verilog finished

.PHONY: v_link
v_link:
	@echo Linking for Verilog sim ...
	bsc -e $(TOPMODULE) -verilog -o ./$(V_SIM_EXE) $(V_DIRS) -vsim $(V_SIM)  verilog_RTL/$(TOPMODULE).v
	@echo Linking for Verilog sim finished

.PHONY: v_sim
v_sim:
	@echo Verilog simulation...
	./$(V_SIM_EXE)
	@echo Verilog simulation finished

.PHONY: v_sim_vcd
v_sim_vcd:
	@echo Verilog simulation and dumping VCD in dump.vcd ...
	./$(V_SIM_EXE)  +bscvcd
	@echo Verilog simulation and dumping VCD in dump.vcd finished

# ----------------------------------------------------------------

.PHONY: clean
clean:
	rm -f  build_b_sim/*  build_v/*  *~  src/*~

.PHONY: full_clean
full_clean:
	rm -r -f  build_b_sim  build_v  verilog_RTL  *~  src/*~
	rm -f  *$(TOPMODULE)*  *.vcd
