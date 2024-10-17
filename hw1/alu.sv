/**
 * alu.sv - 32-bit ALU with flags
 *
 * @author:	Tom Harke (harke@pdx.edu)
 * @date:	2024/10/16
 *
 * @brief
 * implements a 32-bit ALU with flags 
 *
 * @note:  Based on an exercise from Digital Design and Computer Architecture: RISC-V edition by Sarah Harris and David Harris
 */ 

/* Questions
    - 'self checking'
    - how fold a 32-bit-array into 1 bit of output

 */
module alu();
// timeunit 1ns/1ns;

// TODO: for testing, make 32 a parameter
//       then, one test involves setting param to 2 or 3 and doing exhaustive run 
  logic [31:0] a, b, result; 
  logic [1:0]  alucontrol; 
  logic [3:0]  flags; 

  logic Cout;
  logic arithmetic;
  logic [31:0] a_pm;
  logic [31:0] Result;
  logic [31:0] ResultNeg;

  enum BINOP
    { ADD = 2'b00
    , SUB = 2'b01
    , AND = 2'b10
    , OR  = 2'b11
    };

  enum
    { NEGATIVE
    , ZERO
    , CARRY
    , OVERFLOW
    };

  always_comb
    case (alucontrol[0])
      0: a_pm =  a;
      1: a_pm = ~a;
    end case

  assign {Cout,Sum} = a_pm + b;

  always_comb
    unique case (alucontrol)
      ADD, SUB: Result = Sum; // TODO: add 1 ?? AHA: via Cin
      // ADD: Result = Sum;
      // SUB: Result = Sum; // TODO: add 1 ??
      AND: Result = a & b;
      OR:  Result = a | b;
    end case


  assign ResultNeg       = ~Result;
  assign arithmetic      = ~alucontrol[1];
  assign flags[OVERFLOW] = arithmetic
                         & (a[31] ^ Sum[31])
                         & (~(alucontrol[0] ^ a[31] ^ b[31]))
                         ;
  assign flags[CARRY]    = arithmetic
                         & Cout
                         ;
  assign flags[ZERO]     = ... and of all ... ResultNeg[31:0];
  assign flags[NEGATIVE] = Result[31];

  
endmodule: alu
