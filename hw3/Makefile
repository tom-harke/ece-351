
INST = add inv
INST = add 

hw3.pdf: \
	add.timing.pdf \
	imm.timing.pdf \
	inv.timing.pdf \
	hw3.tex
	pdflatex hw3.tex

#all: $(patsubst,%,%.timing.pdf,$(INST))

%.timing.pdf: %.timing.tex
	pdflatex $*.timing.tex

clean:
	echo TODO

vlog.%: %.sv
	vlog $*.sv && touch vlog.$*

clear:
	clear

.PHONY: clear

run: clear vlog.stackCPU_DEFS vlog.stack_signed vlog.tb_stackCPU vlog.stackCPU
	vsim -c tb_stackCPU

echo:
	echo run -a | make run

