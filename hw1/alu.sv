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

// package mnemonics;
  typedef enum logic [1:0]
    { ADD = 2'b00
    , SUB = 2'b01
    , AND = 2'b10
    , OR  = 2'b11
    } op_t;
// endpackage // : mnemonics


module alu
  #(parameter WIDTH = 32)
  (a,b,alucontrol,result,flags);

// timeunit 1ns/1ns;

// TODO: for testing, make 32 a parameter
//       then, one test involves setting param to 2 or 3 and doing exhaustive run
  input  logic [WIDTH-1:0] a, b;
  // input  op_t  alucontrol;
  input  logic [1:0]  alucontrol;
  output logic [WIDTH-1:0] result;
  output logic [3:0]  flags;

  logic Cout;
  logic arithmetic;
  logic [WIDTH-1:0] b_pm;
  logic [WIDTH-1:0] sum;
  logic [WIDTH-1:0] resultNeg;

  typedef enum
    { NEGATIVE = 3
    , ZERO     = 2
    , CARRY    = 1
    , OVERFLOW = 0
    } FLAG;

  always_comb
    case (alucontrol[0])
      0: b_pm =  b;
      1: b_pm = ~b;
    endcase

  assign {Cout,sum} = a + b_pm + alucontrol[0];

  always_comb
    unique case (alucontrol)
      ADD, SUB: result = sum;
      AND:      result = a & b;
      OR:       result = a | b;
    endcase


  assign resultNeg       = ~result;
  assign arithmetic      = ~alucontrol[1];
  assign flags[OVERFLOW] = arithmetic
                         & (a[WIDTH-1] ^ sum[WIDTH-1])
                         & (~(alucontrol[0] ^ a[WIDTH-1] ^ b[WIDTH-1]))
                         ;
  assign flags[CARRY]    = arithmetic
                         & Cout
                         ;
  assign flags[ZERO]     = &resultNeg[WIDTH-1:0];
  assign flags[NEGATIVE] = result[WIDTH-1];


endmodule: alu
