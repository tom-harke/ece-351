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
logic unused;
logic pop, push;
logic signed [9:0] value;
logic signed [DATA_WIDTH-1:0] top, op1, op2;

  Stack #(
    .DATA_WIDTH(DATA_WIDTH),
    .DEPTH(STACK_DEPTH)
  ) STACK
  (
    .clk(clk),
    .reset(reset),
    .push(push),
    .pop(pop),
    .data_in(result),
    .data_out(top),
    // .*
    .full(),         // TODO
    .empty(),        // TODO
    .one_or_more(),  // TODO
    .two_or_more()   // TODO
  );


always_ff @(posedge clk or posedge reset)
  if (reset)
    begin
      pc <= 0;
      current <= IDLE;
      // TODO: clear stack
    end
  else
    begin
      current <= next;
      if (current==IDLE) // TODO: may need previous state
        pc <= pc+1;
    end

always_ff @(posedge clk)
  // Copy stack data into operand registers.
  // For the sake of simple code, copy even if it's not needed for the operation.
  begin
    case (current)
      IDLE: op2 <= top; // only used for binary, copied regardless
      POP2: op1 <= top; // not used for immediate, copied regardless
    endcase
  end


always_comb // Next State & push/pop control signals
  begin
    case (current)
      IDLE:
        case (CP)
          PUSH_IMMEDIATE: {next,pop,push} = {PUSH,1'b0,1'b1}; // TODO want HI/LO instead of 1/0
          INVERT:         {next,pop,push} = {POP1,1'b1,1'b0};
          default:        {next,pop,push} = {POP2,1'b1,1'b0};
        endcase
      POP2: {next,pop,push} = {POP1,1'b1,1'b0};
      POP1: {next,pop,push} = {PUSH,1'b0,1'b1};
      PUSH: {next,pop,push} = {IDLE,1'b0,1'b0};
    endcase
  end


always_comb
  begin
    case (current)
      //A: 
      //IDLE: result = pc; // TODO
      PUSH_IMMEDIATE: result = value;
      ADD:            result = op1 + op2;
      MUL:            result = op1 * op2;
      default: result = -17;
    endcase
  end

always_comb // Extract components of instruction
  begin
    {CP,unused,value} = instruction;
    valid_result = 1; // TODO ????
  end

endmodule: stackCPU
