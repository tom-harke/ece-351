/**
 * @file stack_signed.sv
 * @brief  Parameterized stack module
 *
 * @version 1.0.0
 * @author	Roy Kravitz (roy.kravitz@pdx.edu)
 * @date	16-Nov-2024
 *
 * @detail
 * Implements a parameterized stack.  Prototype created by ChatGPT.  Modified
 * by Roy for the stackCPU implementation
 *
 * Revision History
 * ----------------
 * 1.0.0	(16-Nov-2024)	Initial version
 *
 */
module Stack #(
    parameter int DATA_WIDTH = 32,		// Width of each data element
    parameter int DEPTH = 16 			// Number of stack entries
)(
    input  logic                  clk,
    input  logic                  reset,          	// Active-high reset
    input  logic                  push,         	// Push control signal
    input  logic                  pop,          	// Pop control signal
    input  logic signed [DATA_WIDTH-1:0] data_in,	// Signed data to push onto the stack
    output logic signed [DATA_WIDTH-1:0] data_out,	// Signed data at the top of the stack
    output logic                  full,				// Stack full flag
    output logic                  empty,			// Stack empty flag
    output logic                  one_or_more,		// At least one entry in the stack
    output logic                  two_or_more		// At least two entries in the stack
);

    // Internal stack memory (signed)
    logic signed [DATA_WIDTH-1:0] stack_mem [0:DEPTH-1];
    logic [$clog2(DEPTH):0] sp;	// Stack pointer (extra bit to handle overflow)

    // Continuous assignment for data_out (top of the stack)
    assign data_out = (sp > 0) ? stack_mem[sp - 1] : {DATA_WIDTH{1'b0}};

    // Combinational logic for flags
    always_comb begin
        empty = (sp == 0);
        full = (sp == DEPTH);
        one_or_more = (sp >= 1);
        two_or_more = (sp >= 2);
    end

    // Sequential logic for stack operations
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            sp <= 0;
        end else begin
            if (push && !full) begin
                stack_mem[sp] <= data_in;
                sp <= sp + 1;
            end else if (pop && !empty) begin
                sp <= sp - 1;
            end
        end
    end

endmodule: Stack
