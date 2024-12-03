#!/usr/bin/make -f

INST = add inv
INST = add 

hw4.pdf: \
	hw4.tex
	pdflatex hw4.tex

vlog.%: %.sv
	vlog $*.sv && touch vlog.$*

clear:
	clear

.PHONY: clear

run: clear vlog.stackCPU_DEFS vlog.stack_signed vlog.tb_stackCPU vlog.stackCPU
	vsim -c tb_stackCPU

echo:
	echo run -a | make run

%.out: %.mem
	ln -fsn $*.mem program.mem
	echo ''                >  $*.out
	echo '=========================================' >> $*.out
	echo "File: $*.mem"    >> $*.out
	echo ''                >> $*.out
	echo 'Input Program:'  >> $*.out
	cat $*.mem             >> $*.out
	echo ''                >> $*.out
	echo 'Results:'        >> $*.out
	echo run -a | make run >> $*.out
	cat $*.out

UNIT_ARITH = add sub mul div mod
UNIT_LOGIC = and or invert
ERROR      = div0 empty1 empty2 full
ERROR2     = $(patsubst %,error.%,$(ERROR))
UNIT       = $(patsubst %,unit.%,$(UNIT_ARITH) $(UNIT_LOGIC))
COMPLEX = \
	deferred \
	roys

PROGRAMS = \
	$(COMPLEX) \
	$(UNIT) \
	$(ERROR2) \


test_results.txt: $(patsubst %,%.out,$(PROGRAMS))
	cat $(patsubst %,%.out,$(PROGRAMS)) > test_results.txt

package: ece351f24_harke_hw4.zip

ece351f24_harke_hw4.zip: \
	hw4.pdf
	zip ece351f24_harke_hw4 $+
