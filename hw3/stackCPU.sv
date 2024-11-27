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
  parameter DATA_WIDTH  = 10,
  parameter STACK_DEPTH = 10,
  parameter INSTR_WIDTH = 10,
  parameter PC_WIDTH    = 10
)
(
  input  logic clk, reset,
  input  logic [INSTR_WIDTH-1:0] instruction,
  output logic [PC_WIDTH-1:0] pc,
  output logic signed [DATA_WIDTH-1:0] result,
  output logic valid_result, error, halt
);

  opcode_t opcode;
  state_t current, next;
  logic unused;
  logic pop, push;
  logic signed [9:0] immediate;
  logic signed [DATA_WIDTH-1:0] top, op1, op2;

  logic HI, LO;
  assign HI = 1;
  assign LO = 1;

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

    .full(),         // TODO
    .empty(),        // TODO
    .one_or_more(),  // TODO
    .two_or_more()   // TODO
  );


  always_ff @(posedge clk or posedge reset)
    if (reset)
      begin
        pc <= 0;
        current <= DECODE;
        // TODO: clear stack
      end
    else
      begin
        current <= next;
        if (next==FETCH)
          begin
            pc <= pc+1;
        end
      end

  always_ff @(posedge clk)
    // Copy stack data into operand registers.
    // For the sake of simple code, copy even if it's not needed for the operation.
    begin
      case (current)
        DECODE: op2 <= top; // only used for binary, copied regardless
        POP2:   op1 <= top; // not used for immediate, copied regardless
        PUSH: // This part isn't necessary, but it makes it easier to understand the output
          begin
            op1 <= 1'bx;
            op2 <= 1'bx;
          end
      endcase
    end


  always_comb // Next State & push/pop control signals
    begin
      case (current)
        FETCH: {next,pop,push} = {DECODE,1'b0,1'b0};
        DECODE:
          case (opcode)
            PUSH_IMMEDIATE: {next,pop,push} = {PUSH,1'b0,1'b0}; // TODO want HI/LO instead of 1/0
            INVERT:         {next,pop,push} = {POP1,1'b1,1'b0};
            default:        {next,pop,push} = {POP2,1'b1,1'b0};
          endcase
        POP2: {next,pop,push} = {POP1, 1'b1,1'b0};
        POP1: {next,pop,push} = {PUSH, 1'b0,1'b0};
        PUSH: {next,pop,push} = {FETCH,1'b0,1'b1};
      endcase
    end


  always_comb
    begin
      unique case (opcode)
        PUSH_IMMEDIATE: result = immediate;
        ADD:            result = op1 + op2;
        SUB:            result = op1 - op2;
        MUL:            result = op1 * op2;
        DIV:            result = op1 / op2;
        MOD:            result = op1 % op2;
        AND:            result = op1 & op2;
        OR:             result = op1 | op2;
        INVERT:         result =     ~ op2;
        default:        result = 1'bx; // needed to silence warning
      endcase
    end

assign {opcode,unused,immediate} = instruction;

endmodule: stackCPU
