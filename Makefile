FILE = ICFP2020_Bluespec_Tutorial

.PHONY: default
default: doc_BH

.PHONY: help
help:
	@echo "Usage:    make doc"
	@echo "    Will process AsciiDoc $(FILE).adoc into $(FILE).html"

.PHONY: doc_BH
doc_BH:
	make -C Figures
	asciidoctor -v  --attribute BH_MODE  --out-file $(FILE)_BH.html  \
		$(FILE).adoc

.PHONY: doc_BSV
doc_BSV:
	make -C Figures
	asciidoctor -v  --attribute BSV_MODE  --out-file $(FILE)_BSV.html  \
		$(FILE).adoc

.PHONY: clean
clean:
	make -C Figures  clean
	rm -r -f  *~  */*~

.PHONY: full_clean
full_clean:
	make -C Figures  full_clean
	rm -r -f  *~  */*~  *_BH.html  *_BSV.html
