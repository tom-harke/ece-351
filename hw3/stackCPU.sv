/**
 * stackCPU.sv - stack-based CPU
 *
 * @author Tom Harke (harke@pdx.edu)
 * @date   2024 Dec 05
 *
 * @brief
 * TODO
 * 
 *
 * @note:  TODO
 */
 // global definitions, parameters, etc.
import stackCPU_DEFS::*;

module stackCPU
#(
  parameter logic SSTEP_ENABLE   = 0,
  parameter DATA_WIDTH  = 32,
  parameter STACK_DEPTH = 16,
  parameter INSTR_WIDTH = 10,
  parameter PC_WIDTH    = 10
)
(
  input  logic clk, reset,
  input  logic [INSTR_WIDTH-1:0] instruction,
  output logic [PC_WIDTH-1:0] pc,

  // interface to nexysA7
  input logic                             single_step,    // step on instruction on rising edge
  output logic signed [DATA_WIDTH-1:0]    result,         // ALU result
  output logic                            valid_result,   // asserted high when ALU result is valid
  output logic                            error,          // error if asserted high
  output logic                            halt            // CPU is halted
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


  // HW4 changes:
  //   - declutter by moving pop=0 and push=0 to top
  //   - add PAUSE state
  always_comb // Next State & push/pop control signals
    begin
      pop  = 1'b0;
      push = 1'b0;
      case (current)
        FETCH: next = DECODE;
        DECODE:
          begin
            case (opcode)
              PUSH_IMMEDIATE:  next      = PUSH;
              INVERT:         {next,pop} = {POP1,1'b1};
              default:        {next,pop} = {POP2,1'b1};
            endcase
            if (opcode==DIV && top==0)
              next = ERROR;
          end
        POP2:  {next,pop}  = {POP1, 1'b1};
        POP1:   next       =  PUSH;
        PUSH:  {next,push} = {PAUSE,1'b1};
        PAUSE:  next = (SSTEP_ENABLE && ~single_step)
                     ? PAUSE
                     : FETCH
                     ;
        ERROR:  next       =  ERROR;
      endcase
      if (push && full) next = ERROR;
      if (pop && empty) next = ERROR;
    end


  // HW4 changes:
  //   - put result in register
  //   - add conditional so that it doesn't latch too late
  always_ff @(posedge clk)
   if (current < PAUSE)
    begin
      unique case (opcode)
        PUSH_IMMEDIATE: result <= immediate;
        ADD:            result <= op1 + op2;
        SUB:            result <= op1 - op2;
        MUL:            result <= op1 * op2;
        DIV:            result <= op1 / op2;
        MOD:            result <= op1 % op2;
        AND:            result <= op1 & op2;
        OR:             result <= op1 | op2;
        INVERT:         result <=     ~ op2;
      endcase
    end

assign error        = current == ERROR ? 1'b1 : 1'b0;
assign halt         = current == ERROR ? 1'b1 : 1'b0; // current == HALT  ? 1'b1 : 1'b0; // TODO
assign valid_result = current == PUSH  ? 1'b1 : 1'b0; // TODO
assign {opcode,unused,immediate} = instruction;

endmodule: stackCPU
