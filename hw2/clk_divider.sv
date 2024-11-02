/**
 * clk_divider.sv - parameterized clock divider
 *
 * @author:	Roy Kravitz (roy.kravitz@pdx.edu) 
 * @date:	27-Oct-2024
 *
 * @brief
 * Implements a clock divider that can be used to generate a slow(er) clock from 
 * the system clock. This module can be used, for example, in FPGA projects that
 * that must slow down the system clock to "human interface" speeds.
 *
 * @note original version by Roy Kravitz, circa 2012.  Updated to SystemVerilog in 2021.
 * Minor changes in 2024 to bring in line w/ the way I've evolved my SystemVerilog coding style
 */
module clk_divider
#(
	parameter CLK_INPUT_FREQ_HZ = 100_000_000,		// input clock frequency (default: 100MHz)
	parameter TICK_OUT_FREQ_HZ = 100_000,			// output frequency (default: 1KHz)
	parameter SIMULATE = 1							// simulation mode
)
(
	input logic			clk, reset,			// clock and reset.  resets counters when high
	output logic		tick_out			// asserted high for one clock cycle
);

timeunit 1ns/1ns;

// Top count for divider - adjusted down for simulation
localparam CLK_COUNTS = CLK_INPUT_FREQ_HZ / TICK_OUT_FREQ_HZ;
localparam CLK_TOP_COUNT = SIMULATE ? 5 : (CLK_COUNTS - 1);	

// internal variables
logic [31:0]		clk_div_counter;	// clock divider

// implement the clock divider
always_ff @(posedge clk or posedge reset) begin : clk_div
	if (reset)  begin
		clk_div_counter <= '0;
		tick_out <= 1'b0;
	end 
	else if (clk_div_counter == CLK_TOP_COUNT) begin
		clk_div_counter <= '0;
		tick_out <= 1'b1;
	end 
	else begin
		clk_div_counter <= clk_div_counter + 1'b1;
		tick_out <= 1'b0;
	end // increment clock divider count
end: clk_div

endmodule: clk_divider
