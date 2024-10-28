view: hw1_problem1.pdf
	evince hw1_problem1.pdf &

hw1_problem1.pdf: hw1_problem1.tex
	pdflatex hw1_problem1.tex

package: \
	alu.sv \
	alu_tb.sv \
	alu_tb_results.txt \
	hw1_problem1.pdf
	zip ece351f24_harke_hw1 $+

alu_tb_results.txt: alu.sv alu_tb.sv
	echo run -a | make run > alu_tb_results.txt

run:
	vlog alu.sv
	vlog alu_tb.sv
	vsim -c alu_tb
