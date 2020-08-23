Figs = \
	HW_Dev_Flows.png \
	FPGA_Model.png \
	Accelerator_Models.png \
	Accelerator_Flow.png \
	Hello_World_A_0.png \
	Hello_World_A_1.png \
	Haskell_vs_Bluespec.png \
	Hello_World_C_mkTop_0.png \
	Hello_World_C_mkTop_1.png \
	Hello_World_C_mkDeepThought_0.png \
	Hello_World_C_mkDeepThought_1.png \
	RISCV_SW_Flow.png \



all: $(Figs)

$(Figs): %.png: %.svg
	inkscape --export-filename=$@  --export-area-drawing  -d 300 -y 0.0 $<


.PHONY: clean
clean:
	rm -r -f  *~

.PHONY: full_clean
full_clean:
	rm -r -f  *~  $(Figs)
