
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
