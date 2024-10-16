/**
 * alu_tb.sv - Testbench for 32-bit ALU with flags
 * ----STARTER CODE-----
 *
 * @author:	<your name> (<your email address>)
 * @date:	<date created>
 *
 * @brief
 * implements a testbench for the 32-bit ALU with flags 
 *
 * @note:  Based on an exercise from Digital Design and Computer Architecture: RISC-V edition by Sarah Harris and David Harris
 */ 
module alu_tb();
timeunit 1ns/1ns;
 
  // ALU interface signals
  logic [31:0] a, b, result; 
  logic [1:0]  alucontrol; 
  logic [3:0]  flags; 
  // TODO:  Declare your other testbench variables here
  
   /*** BOILER PLATE CODE TO DISPLAY YOUR WORKING DiRECTORY ***/
  // make use of the SystemVerilog C programming interface
  // https://stackoverflow.com/questions/33394999/how-can-i-know-my-current-path-in-system-verilog
  import "DPI-C" function string getenv(input string env_name);  
 
  // instantiate device under test
  // TODO:  Change instantiation to match your alu module  
  alu DUT (
	.a(a),
	.b(b),
	.alucontrol(alucontrol),
	.result(result),
	.flags(flags)
  ); 
 
 
  /*** BOILER PLATE CODE TO DISPLAY YOUR WORKING DIRECTOR ***/ 
  // TODO:  Change the greeting message
  initial begin: display_working_dir
	// display greeting and working directory
    $display("ECE 351 Fall 2024: ALU testbench - Roy Kravitz (roy.kravitz@pdx.edu)");
    $display("Sources: %s\n", getenv("PWD")); 
  end: display_working_dir
 
  // TODO:  Add your testbench code here
  
endmodule: alu_tb 
 
