/**
 * tb_pmodSSD.sv - testbench for the PmodSSD homework problem
 *
 * @author:	Roy Kravitz (roy.kravitz@pdx.edu) 
 * @date:	27-Oct-2024
 *
 * @brief
 * Implements a test bench for the PmodSSD homework problem.  Connects the
 * student's PmodSSD  with the PmodSSD display simulator.  
 * Tries combinations of digits. You can check the ASCII character codes to see
 * that your PmodSSD Interface is working correctly.
 *
 * @note original version by Roy Kravitz, circa 2012.  Updated to SystemVerilog in 2021.
 * Minor changes in 2024 to bring in line w/ the way I've evolved my SystemVerilog coding style
 */
module tb_pmodSSD;

timeunit 1ns/1ns;

// define stimulus interval
localparam IVL = 100;

// internal signals
logic			clk, reset;			// system clock and reset
logic	[4:0]	ccd1, ccd0;					// character codes for digit 1 and digit 0
logic			segg, segf, sege, segd,		// segments signals for PmodSSD
				segc, segb, sega;
logic			dig_enable, dig_enable_n;	// digit enable cathode signal to display
logic	[6:0]	dig1_segs, dig0_segs;		// digit 1 and digit 0 segment drivers
logic	[15:0]	disply;						// ASCII version of display digits

// make use of the SystemVerilog C programming interface
// https://stackoverflow.com/questions/33394999/how-can-i-know-my-current-path-in-system-verilog
import "DPI-C" function string getenv(input string env_name);  

// instantiate your PmodSSD interface
pmodSSD
#(
	.SIMULATE(1)
) PMODSSD
(
	.clk(clk),
	.reset(reset),	
	.digit1(ccd1),
	.digit0(ccd0),
	.SSD_AG(segg),
	.SSD_AF(segf),
	.SSD_AE(sege),
	.SSD_AD(segd),
	.SSD_AC(segc),
	.SSD_AB(segb),
	.SSD_AA(sega),
	.SSD_C(dig_enable)
);


// instantiate the PmodSSD emulator
pmodSSD_emu PMODSSDEMU
(
	.AG(segg),
	.AF(segf),
	.AE(sege),
	.AD(segd),
	.AC(segc),
	.AB(segb),
	.AA(sega),
	.CAT(dig_enable),
	.dig1_segs(dig1_segs),
	.dig0_segs(dig0_segs),	
	.dsply_digits(disply)
);

// generate the system clock
// yet another way to create a clock
initial clk = 1'b0;
always #5 clk = ~clk;


// Monitor the outputs 
initial begin
	$monitor($time, "\tdig1 cc=%h\tdig0 cc=%x\tdig enable=%b\tdisplay=%s\t\tdig1 segs=%b\tdig0 segs=%b\t\t[%s]", ccd1, ccd0, dig_enable, disply, dig1_segs, dig0_segs, disply);
end

// test vectors
logic [4:0]	cc;		// character code

// generate display enable for digit 0 (used in waveform)
assign dig_enable_n = ~dig_enable;

// Apply the test vectors
initial begin: stimulus
	// display greeting and working directory
    $display("ECE 351 Fall 2024: PmodSSD Testbench - Submitted by Tom Harke (harke@pdx.edu)");
    $display("Sources: %s\n", getenv("PWD")); 
	
	$display("Reset the system ");
			reset = 1'b0;
	#10		reset = 1'b1;
	#10		reset = 1'b0;
	$display("Test digits by walking digit0 up and digit 1 down");
	$display("Digit 1 (leftmost) should only change when dig_enable is asserted high (not the edge, the level)");
	$display("Digit 0 (rightmost) should only change when dig_enable is asserted low (not the edge, the level");
	$display("This is because the display is multiplexed.  On live hardware you would");
	$display("not notice this because the display would be updating @ 60Hz and your");
	$display("brain would average the results");
	cc = 5'd0;
	repeat(32) begin
		#IVL	ccd0 = cc;  ccd1 = 5'h1F - cc;
				cc = cc + 1;
	end
	#IVL	$stop;
end: stimulus

endmodule: tb_pmodSSD


