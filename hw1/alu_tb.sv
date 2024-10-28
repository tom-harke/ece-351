/**
 * alu_tb.sv - Testbench for 32-bit ALU with flags
 *
 * @author:	Tom Harke (harke@pdx.edu)
 * @date:	2024/10/26
 *
 * @brief
 * implements a testbench for the 32-bit ALU with flags
 *
 * @note:
 *    - Exercise based on one from Digital Design and Computer Architecture: RISC-V edition by Sarah Harris and David Harris
 *    - Draft testbench from Roy Kravitz (roy.kravitz@pdx.edu)
 */

typedef enum bit [1:0]
  // I tried to get mnemonic names, but it didn't quite work
    { ADD = 2'b00
    , SUB = 2'b01
    , AND = 2'b10
    , OR  = 2'b11
  } BINOP;

module alu_tb
  // I really want a 2nd instance of the DUT, with 32 bits & a small set of vectors, but ran out of time
  #(
    parameter WIDTH = 3,
    parameter FILE = "vectors_short.txt"
  )
  ();
  timeunit 1ns/1ns;

  parameter VEC_LEN = 2       // opcode
                    + 3*WIDTH // 2 inputs + 1 output, same length
                    + 4       // flags
                    ;

  logic [WIDTH-1:0] a, b, result;
  logic [1:0]       alucontrol;
  logic [3:0]       flags;

  logic [WIDTH-1:0] result_exp;
  logic [3:0]       flags_exp;


  logic [VEC_LEN-1:0]  testvectors[255:0];
  logic clk;
  int vectornum, pass, fail;

  import "DPI-C" function string getenv(input string env_name);

  alu #(WIDTH) DUT (
	.a(a),
	.b(b),
	.alucontrol(alucontrol),
	.result(result),
	.flags(flags)
  );


  initial begin: display_working_dir
    $display("ECE 351 Fall 2024: ALU testbench - Tom Harke (harke@pdx.edu)");
    $display("Sources: %s\n", getenv("PWD"));
  end: display_working_dir

  initial begin: prep_vectors
    alucontrol = OR;  // to avoid initial X violating unique case
    {vectornum,pass,fail} = 0;
    $readmemb(FILE, testvectors);
  end: prep_vectors

  // generate clock
  always 
    begin
      clk = 1; #5;
      clk = 0; #5;
    end


  // apply test vectors on rising edge of clk
  always @(posedge clk)
    begin
      #1;
      {alucontrol, a, b, result_exp, flags_exp} = testvectors[vectornum];
    end

  always @(negedge clk)
    begin
      #1;
      case (alucontrol)
        10, 11: 
                // The flags aren't meaningful for logic operations.
                // This branch ignores flags.
                if ( result == result_exp )
                  begin
                    pass = pass+1;
                  end
                else
                  begin
                    $display("vector %d is %b",  vectornum, testvectors[vectornum]);
                    $display("op is %b, a is %b(%d), b is %b(%d)", alucontrol, a, a, b, b);
                    $display("expect: %b(%d)", result_exp, result_exp);
                    $display("got   : %b(%d)", result,     result,   );
                    fail = fail + 1;
                    $display("so far: %d passed, %d failed\n", pass, fail);
                    $display("");
                  end
        00, 01: 
                // This branch checks flags.
                if ( {result,flags} == {result_exp,flags_exp} )
                  begin
                    pass = pass+1;
                  end
                else
                  begin
                    $display("vector %d is %b",  vectornum, testvectors[vectornum]);
                    $display("op is %b, a is %b(%d), b is %b(%d)", alucontrol, a, a, b, b);
                    $display("expect: %b(%d) with flags %b", result_exp, result_exp, flags_exp);
                    $display("got   : %b(%d) with flags %b", result,     result,     flags    );
                    fail = fail + 1;
                    $display("so far: %d passed, %d failed\n", pass, fail);
                    $display("");
                  end
      endcase;
      vectornum = vectornum + 1;
      if (testvectors[vectornum] === 15'bx) begin
        $display("%d passed, %d failed\n", pass, fail);
        $stop;
      end

    end

endmodule: alu_tb

/*
module alu_tb_what_I_want();

  alu_tb(3, "vectors_short.txt");
  alu_tb(32, "vectors_long.txt");

endmodule: alu_tb_what_I_want
*/
