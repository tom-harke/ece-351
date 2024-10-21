/**
 * alu_tb.sv - Testbench for 32-bit ALU with flags
 *
 * @author:	Tom Harke (harke@pdx.edu)
 * @date:	2024/10/16
 *
 * @brief
 * implements a testbench for the 32-bit ALU with flags
 *
 * @note:
 *    - Exercise based on one from Digital Design and Computer Architecture: RISC-V edition by Sarah Harris and David Harris
 *    - Draft testbench from Roy Kravitz (roy.kravitz@pdx.edu)
 */

  typedef enum bit [1:0]
    { ADD = 2'b00
    , SUB = 2'b01
    , AND = 2'b10
    , OR  = 2'b11
    } BINOP;

module alu_tb();
timeunit 1ns/1ns;


  // parameter WIDTH = 32;
  parameter WIDTH = 4;

  // ALU interface signals
  logic [WIDTH-1:0] a, b, result;
  logic [1:0]  alucontrol;
  // BINOP  alucontrol;
  logic [3:0]  flags;
  // TODO:  Declare your other testbench variables here

  import "DPI-C" function string getenv(input string env_name);

  alu #(WIDTH) DUT (
	.a(a),
	.b(b),
	.alucontrol(alucontrol),
	.result(result),
	.flags(flags)
  );


  initial begin: display_working_dir
    //alucontrol = 0;
    $display("ECE 351 Fall 2024: ALU testbench - Tom Harke (harke@pdx.edu)");
    $display("Sources: %s\n", getenv("PWD"));
  end: display_working_dir

  initial begin: foo
    alucontrol = ADD;
  end: foo

  initial begin: drive_tests

    // $monitor("Result %d", result);
    #10;
    a = 4'b0110; // 6;
    b = 4'b0101; // 5;

    #10;
    alucontrol = ADD;
    #1;
    $display("result %d, op %b a=%d b=%d\n", result, alucontrol, a, b);

    #10;
    alucontrol = SUB;
    #1;
    $display("result %d, op %b a=%d b=%d\n", result, alucontrol, a, b);

    #10;
    alucontrol = AND;
    #1;
    $display("result %b, op %b a=%b b=%b\n", result, alucontrol, a, b);

    #10;
    alucontrol = OR;
    #1;
    $display("result %b, op %b a=%b b=%b\n", result, alucontrol, a, b);

  end: drive_tests

  // TODO:  Add your testbench code here

endmodule: alu_tb

