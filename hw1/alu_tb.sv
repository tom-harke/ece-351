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
module alu_tb();
timeunit 1ns/1ns;
 
  // ALU interface signals
  logic [31:0] a, b, result; 
  logic [1:0]  alucontrol; 
  logic [3:0]  flags; 
  // TODO:  Declare your other testbench variables here
  
  import "DPI-C" function string getenv(input string env_name);  
 
  alu DUT (
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
 
  // TODO:  Add your testbench code here
  
endmodule: alu_tb 
 
