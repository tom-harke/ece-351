/**
 * stackCPU.sv - stack-based CPU
 *
 * @author Tom Harke (harke@pdx.edu)
 * @date   2024 Nov 27
 *
 * @brief
 * TODO
 * 
 *
 * @note:  TODO
 */

import stackCPU_DEFS::*;

module stackCPU
#(
  parameter DATA_WIDTH  = 3,
  parameter STACK_DEPTH = 3,
  parameter INSTR_WIDTH = 3,
  parameter PC_WIDTH    = 3
)
(
  input  logic clk, reset,
  input  logic [INSTR_WIDTH-1:0] instruction,
  output logic [PC_WIDTH-1:0] pc,
  output logic signed [DATA_WIDTH-1:0] result,
  output logic valid_result, error, halt
);

opcode_t CP;
state_t current, next;
logic foo;
logic signed [9:0] value;

always_ff @(posedge clk, posedge reset)
  if (reset)
    begin
      pc <= 0;
      current <= IDLE;
    end
  else
    pc <= pc+1;

always_comb
  begin
    case (current)
      IDLE:
        case (CP)
          PUSH_IMMEDIATE: next = PUSH;
          INVERT:         next = POP1;
          default:        next = POP2;
        endcase
      POP2: next = POP1;
      POP1: next = PUSH;
      PUSH: next = IDLE;
    endcase
  end

assign
    result = pc;

always_comb
  begin
    {CP,foo,value} = instruction;
    valid_result = 1;
  end

endmodule: stackCPU
