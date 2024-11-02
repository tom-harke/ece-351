define ABOUT

todo:
 - implement an interface to the peripheral
    - inputs:
       - two (2) character registers (one for each digit),
       - a clock
       - a reset
    - outputs:
       -  to drive the control signals on the PmodSSD.
 - implement the digit to 7-segment decoder
    - it is a combinational block
    - as a module
       - want to instantiate twice
 - provide transcript of simulation.

interface to PmodSSD
 - 7 anode pins (AA-AG)
    - shared between 2 displays
 - digit enable (C)
    - switch at >50Hz

| 0-9   | char '0' to '9'
| 10–15 | char 'A' to 'F'
| 16–22 | single segments a to g
| 23    | Space (Blank)
| 24    | Upper case character H
| 25    | Upper case character L
| 26    | Upper case character R
| 27    | Lower case character L (l)
| 28    | Lower case character R ( r )
| 29–31 | Space (blank)
endef


package: \
	dig2SevenSeg.sv \
	pmodSSD.sv \
	pmodSSD_results.txt
	zip ece351f24_harke_hw2 $+

spec:
	evince docs/ece351f24_hw2.pdf &

pmodSSD_results.txt:
	echo run -a | make run > pmodSSD_results.txt

run:
	vlog dig2SevenSeg.sv
	vlog pmodSSD.sv
	vsim -c TODO
