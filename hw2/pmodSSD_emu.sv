/**
 * pmodSSD_emu.sv - emulates the operation of the Digilent PmodSSD
 *
 * Author:	Roy Kravitz (roy.kravitz@pdx.edu) 
 * Date:	27-Oct-2024
 *
 * @brief
 * Simulates the operation of the Digilent PmodSSD which is a two digit, common anode 7-segment 
 * display.  This is a clockless circuit using latches and matches the pinout of the PmodSSD.
 * The emulator is meant to be connected to, and simulated with, the PmodSSD_Interface being
 * built for ECE 351 homework #3.  Because it is a simulation intended to be used for
 * the problem the model outputs the 7 segment values for each digit and also a 2 byte
 * ASCII output showing the characters that would be displayed on the the digits.
 *
 * @note: that not all 128 segment possibilities are implemented because the majority
 * of the combinations do not have an ASCII equivalent.  Those non-display
 * combinations will show x on the digit (which, of course, is not possible with
 * a 7-segment display).  The combinations that only turn on a single digit will be
 * represented as lower case segments (a...g).  The Hex digits and special characters
 * will display as expected.
 *
 * For more information on the PmodSSD refer to the Digilent PmodSSD Peripheral Module
 * Board Reference Manual and 500-126, the Digilent PmodSSD schematic (www.digilentinc.com)
 *
 * @note original version by Roy Kravitz, circa 2012.  Updated to SystemVerilog in 2021.
 * Minor changes in 2024 to bring in line w/ the way I've evolved my SystemVerilog coding style
 */
module pmodSSD_emu (
	input logic			AG, AF, AE, AD,	// anode signals.  connected to the same segment of both
						AC, AB, AA,		// digits.  Asserted high to turn on the segment
	input logic			CAT,			// cathode signal.  One per digit.
	output logic [6:0]	dig1_segs,		// segments for digit 1 (rightmost). Listed abcdefg
						dig0_segs,		// segments for digit 1 (rightmost). Listed abcdefg	
	output 		[15:0]	dsply_digits	// 2-byte ASCII of what would appear on display
);

timeunit 1ns/1ns;

// internal variables
logic [6:0]		anodes_in;				// anode inputs (combines the individual anodes
logic [6:0]		DISP1_AA, DISP1_AB;		// individual anodes for each of the display digits
logic			DISP1_CAT1, DISP1_CAT2;	// individual cathodes for each of the display digits

/***** IMPORTANT:  This is not the decoder function you are looking for      *****/
/***** This decoder is used to make the characters readable in simulation    *****/
/***** Your decoder is kind of the opposite of this - you start with a digit *****/
/***** and produce the 7-segments needed to put the character on the display *****/

// define a function to convert 7-segments of a single digit 
// to their ASCII equivalent (segments are: abcdefg)
function logic [7:0] SegsToASCII( input logic [6:0] segs ) ;
	case(segs)  
		// hex digits 0-9
		7'b1111110:	SegsToASCII = 8'h30;
		7'b0000110:	SegsToASCII = 8'h31;	
		7'b1101101:	SegsToASCII = 8'h32;
		7'b1111001:	SegsToASCII = 8'h33;
		7'b0110011:	SegsToASCII = 8'h34;
		7'b1011011:	SegsToASCII = 8'h35;
		7'b1011111:	SegsToASCII = 8'h36;
		7'b1110000:	SegsToASCII = 8'h37;
		7'b1111111:	SegsToASCII = 8'h38;
		7'b1111011:	SegsToASCII = 8'h39;
			
		// hex digits A - F
		7'b1110111:	SegsToASCII = 8'h41;
		7'b0011111:	SegsToASCII = 8'h42;
		7'b1001110:	SegsToASCII = 8'h43;
		7'b0111101:	SegsToASCII = 8'h44;
		7'b1001111:	SegsToASCII = 8'h45;
		7'b1000111:	SegsToASCII = 8'h46;
			
		// individual segments       
		7'b1000000:	SegsToASCII = 8'h61;	// segment a
		7'b0100000:	SegsToASCII = 8'h62;	// segment b
		7'b0010000:	SegsToASCII = 8'h63;	// segment c
		7'b0001000:	SegsToASCII = 8'h64;	// segment d
		7'b0000100:	SegsToASCII = 8'h65;	// segment e
		7'b0000010:	SegsToASCII = 8'h66;	// segment f
		7'b0000001:	SegsToASCII = 8'h67;	// segment g
			
		// blank (all digits off) - implemented as a caret so that it consumes a position
		7'b0000000:	SegsToASCII = 8'h5E;
			
		// Special characters         
		7'b0110111:	SegsToASCII = 8'h48; 	// upper case H
		7'b0001110:	SegsToASCII = 8'h4C; 	// upper case L       
		7'b1110111:	SegsToASCII = 8'h52;	// upper case R (same as Upper Case A)
		7'b0000110:	SegsToASCII = 8'h6C;	// lower case L (l)
		7'b0000101:	SegsToASCII = 8'h72; 	// lower case R (r)
			
		// All other combinations are unrecognized so display "x"
		default:	SegsToASCII = 8'h78;
	endcase
endfunction  // SegsToASCII

// create the anode, CAT1 and CAT2 driver signals
assign anodes_in = {AA, AB, AC, AD, AE, AF, AG};

// inverting buffers - see schematic
not U1(DISP1_CAT1, CAT);
not U2(DISP1_CAT2, DISP1_CAT1);

// create the display digits and 7-segment outputs
assign dsply_digits = {SegsToASCII(DISP1_AA), SegsToASCII(DISP1_AB)};
assign dig1_segs = DISP1_AA;
assign dig0_segs = DISP1_AB;

// In a common anode display like this one the segments are only
// enabled when the CAT input is low. This creates a path between the segment
// input and GND (via the CAT signal).  See the PmoddSSD reference manual for
// a more complete explanation.
always_latch begin
	if (!DISP1_CAT1)
		DISP1_AA = anodes_in;
end

always_latch begin
	if (!DISP1_CAT2)
		DISP1_AB = anodes_in;
end

endmodule: pmodSSD_emu




