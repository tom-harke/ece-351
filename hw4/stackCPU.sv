/**
 * @file stackCPU.sv
 * @brief  Top level for the stack CPU
 *
 * @author Tom Harke (harke@pdx.edu)
 * @date   2024 Dec TODO
 *
 * @detail
 * Implements the top level module for the stack CPU.  The stack CPU is
 * implemented as an FSM-D with stackCPU_CTL doing the control for the
 * stackCPU_DP datapath
 *
 * Revision History
 * ----------------
 * 1.1.0    (21-Nov-2024 by RK) Added configurable reset polarity.  Support single-stepping
 * 1.0.0    (16-Nov-2024 by RK)    Initial version
 *
 */
 // global definitions, parameters, etc.
import stackCPU_DEFS::*;

module stackCPU
#(
  parameter int DATA_WIDTH  = 32,
  parameter int STACK_DEPTH = 16,
  parameter int INSTR_WIDTH = 10,
  parameter int PC_WIDTH    = 10
)
(
  input  logic clk, reset,
  input  logic [INSTR_WIDTH-1:0] instruction,
  output logic [PC_WIDTH-1:0] pc,
  output logic signed [DATA_WIDTH-1:0] result,
  output logic error, halt
);

  opcode_t opcode;
  state_t current, next;
  logic unused;
  logic pop, push;
  logic signed [9:0] immediate;
  logic signed [DATA_WIDTH-1:0] top, op1, op2;
  logic full, empty;

  logic HI, LO; // TODO: these could make the code more readable
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

    .full(full),
    .empty(empty),
    .one_or_more(),  // UNUSED
    .two_or_more()   // UNUSED
  );


  always_ff @(posedge clk or posedge reset)
    if (reset)
      begin
        pc <= 0;
        current <= FETCH;
      end
    else
      begin
        current <= next;
        if (next==FETCH)
          begin
            pc <= pc+1;
          end
        if (next==ERROR)
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
          begin
            case (opcode)
              PUSH_IMMEDIATE: {next,pop,push} = {PUSH,1'b0,1'b0}; // TODO want HI/LO instead of 1/0
              INVERT:         {next,pop,push} = {POP1,1'b1,1'b0};
              default:        {next,pop,push} = {POP2,1'b1,1'b0};
            endcase
            if (opcode==DIV && top==0)
              next = ERROR;
          end
        POP2: {next,pop,push} = {POP1, 1'b1,1'b0};
        POP1: {next,pop,push} = {PUSH, 1'b0,1'b0};
        PUSH: {next,pop,push} = {FETCH,1'b0,1'b1};
      endcase
      if (push && full) next = ERROR;
      if (pop && empty) next = ERROR;
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
