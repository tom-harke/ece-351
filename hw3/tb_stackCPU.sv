/**
 * @file tb_stackCPU.sv
 * @brief Testbench for stackCPU
 * 
 * @author	Roy Kravitz (roy.kravitz@pdx.edu)
 * @date	16-Nov-2024
 *
 * @detail
 * This is the source code for a testbench that instantiates a stack-based CPU that supports
 * the following instructions:
 * 
 * Opcode   Mnemonic  Operation
 * 00000	PUSH_IMMEDIATE	Push immediate value onto stack
 * 00001	ADD				Add top two values on stack
 * 00010	SUB				Subtract top two values on stack
 * 00011	MUL				Multiply top two values on stack
 * 00100	DIV				Divide top two values on stack
 * 00101	MOD				Modulus (remainder) of top two values on stack
 * 00110	AND				bitwise AND of top two values on stack
 * 00111	OR				bitwise OR of top two values on stack
 * 01000	INVERT			bitwise inversion of the top value on stack
 * 11111	HALT_CPU		Halt the CPU. Assert reset to restart the CPU 
 *
 * The instruction format is instruction[15:0] = {opcode[4:0], 1'b0, immediate[10:0]}. 
 * Arithmetic is 2's complement.
 *
 * The testbench reads an output file from the assembler that contains the instructions and
 * continues to run until the instruction is 'X (meaning we ran out of instructions) or we've run
 * out of instructions or if the CPU executed a HALT or ERROR condition
 *
 */
 
  // global definitions, parameters, etc.
import stackCPU_DEFS::*;

module tb_stackCPU;
	logic clk;
	logic reset;
	logic [DATA_WIDTH_DEF-1:0] program_memory [0:PGRM_MEM_DEPTH_DEF-1]; 
	logic [INSTR_WIDTH_DEF-1:0] instruction;
	logic [PC_WIDTH_DEF-1:0] pc;
	logic signed [DATA_WIDTH_DEF-1:0] result;
	logic error, halt, valid_result;

	// Instantiate the stack-based CPU
	stackCPU #(
		.DATA_WIDTH(DATA_WIDTH_DEF),
		.STACK_DEPTH(STACK_DEPTH_DEF),
		.INSTR_WIDTH(INSTR_WIDTH_DEF),
		.PC_WIDTH(PC_WIDTH_DEF)
	) DUT
	(
		.clk(clk),
		.reset(reset),	
		.instruction(instruction),
		.pc(pc),
		.result(result),
		.valid_result(valid_result),
		.error(error),
		.halt(halt)
	);   

	// clock generator
	initial begin: CLK_GEN
		clk = 0;
		forever #5 clk = ~clk; // 10ns clock period
	end: CLK_GEN
	
	assign instruction = program_memory[pc];

	// Testbench stimulus
	initial begin: STIMULUS
        reset = 1;

        // Load program memory from file while in reset
		// TODO:  Change the file name to your program
        $readmemb("program.mem", program_memory);

        repeat(2) @(posedge clk);	// wait 2 clock periods before starting CPU
        reset = 0;		
		$display("StackCPU is alive and executing instructions!!");		
	end: STIMULUS

	// Monitor results
	always @(posedge clk) begin: MONITOR
		if (error && !reset) begin
			$display("Error occurred during execution.");
			$stop;
		end else if (halt && !reset) begin
			$display("CPU was halted.");
			$stop;
		end else if (program_memory[DUT.pc] === 'X) begin
			$display("Reached end of program.");
			$stop;
		end else if (pc > PGRM_MEM_DEPTH_DEF) begin
			$display("Reached end of memory.");
			$stop;
		end else begin
			if (valid_result) begin
				if (result > 0)
					$display("Operation: %15s,\tResult: +%-10d", DUT.CP.my_op, result);
				else if (result == 0)
					$display("Operation: %15s,\tResult:  %-10d", DUT.CP.my_op, result);
				else
					$display("Operation: %15s,\tResult: %-10d", DUT.CP.my_op, result);
			end
		end
	end: MONITOR

endmodule: tb_stackCPU
