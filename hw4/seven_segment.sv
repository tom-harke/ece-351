/**
 * @file sevensegment.v
 * @brief 4 digit 7-segment display controller
 *
 * @version	1.0.0
 * @author	Roy Kravitz (roy.kravitz@pdx.edu)
 * @date	19-November-2024	
 * 
 * @details
 * Implements a configurable 8-digit 7-segment display controller.  There are parameters
 * to set the polarity of the reset signal, polarity of the outputs, sampling frequency, etc.
 * The design is based on the 7-segment display controller in the Nexys4IO peripheral which has
 * been in use since around 2014. The eight digits can be displayed as hex digits or as special 
 * characters for blanking the digit or displaying a single segment.  The decimal points (dots)
 * between each digit are also controlled.  Each digit is displayed according to the following code.	
 *   Value			Displays
 *  --------    --------------------
 *  0 - 9		Characters 0 to 9
 *  10 - 15     Characters A to F
 *  16 - 22     Single segments a - g
 *  23 			Lower case t
 *  24 - 28		Uppercase H, R, L and lower case r, l
 *  29 - 31     Blank (Off)
 *
 *	The decimal points are on or off for each digit according to input dp
 * 
 * Revision History:
 * -----------------
 * 1.0.0	(24-Nov-2024 by RK)	Initial version
 */
module seven_segment
#(
	parameter integer	CLK_FREQUENCY_HZ		= 100000000, 
	parameter integer	REFRESH_FREQUENCY_HZ	= 500,
	parameter integer	RESET_POLARITY_LOW		= 1,
	parameter integer	SEGMENT_POLARITY_HIGH	= 0,
	parameter integer 	CNTR_WIDTH 				= 32,
	
	parameter integer	SIMULATE				= 0,
	parameter integer	SIMULATE_FREQUENCY_CNT	= 5
)
(
	input logic				clk,				// system clock
	input logic				reset,				// system reset signal
	input logic		[4:0]	d0, d1, d2, d3,		// digits to be displayed
	input logic		[4:0]	d4, d5, d6, d7,
	input logic		[7:0]	dp,					// decimal points to be displayed
	output logic	[7:0]	seg,				// segment outputs to a display digit

	output logic	[7:0]	an					// display cathodes
);

	// internal variables
	logic 						reset_in = RESET_POLARITY_LOW ? ~reset : reset; 
	logic	[CNTR_WIDTH-1:0] 	clk_cnt;
	logic	[CNTR_WIDTH-1:0]	top_cnt = SIMULATE ? SIMULATE_FREQUENCY_CNT :
									((CLK_FREQUENCY_HZ / REFRESH_FREQUENCY_HZ) - 1);				
	logic	[7:0]				dig0, dig1, dig2, dig3;	
	logic   [7:0]				dig4, dig5, dig6, dig7;
	
	// anode outputs for each digit
	localparam digit1 = 8'b11111110;
	localparam digit2 = 8'b11111101;
	localparam digit3 = 8'b11111011;
	localparam digit4 = 8'b11110111;
	localparam digit5 = 8'b11101111;
	localparam digit6 = 8'b11011111;
	localparam digit7 = 8'b10111111;
	localparam digit8 = 8'b01111111;
	
	 // clock divider counter
	always_ff @(posedge clk) begin: CLOCK_DIVIDER
		if (reset_in)
			clk_cnt <= 0;
		else if(clk_cnt == top_cnt)
			clk_cnt <= 1'b0;
		else
			clk_cnt <= clk_cnt + 1'b1;
	end: CLOCK_DIVIDER

	always @ (posedge clk) begin: ANODE_CONTROL
		if (reset_in) begin
			an <= digit1;
		end
		else if (clk_cnt == top_cnt) begin
			unique case (an)
				digit1: an <= digit2;
				digit2: an <= digit3;
				digit3: an <= digit4;
				digit4: an <= digit5;
				digit5: an <= digit6;
				digit6: an <= digit7;
				digit7: an <= digit8;
				digit8: an <= digit1;
			endcase
		end
		else begin
			an <= an;
		end
	end: ANODE_CONTROL

	always @ (posedge clk) begin: CATHODE_CONTROL
		unique case (an) 
			digit1: seg <= dig0;
			digit2: seg <= dig1;
			digit3: seg <= dig2;
			digit4: seg <= dig3;
			
			digit5: seg <= dig4;
			digit6: seg <= dig5;
			digit7: seg <= dig6;
			digit8: seg <= dig7;			
		endcase
	end: CATHODE_CONTROL

// Instantiate the 7-segment decoder for each digit	
Digit #(
	.SEGMENT_POLARITY_HIGH_DEF(SEGMENT_POLARITY_HIGH)
) DIGIT0
(
	.clk(clk),
	.d(d0),
	.dp(dp[0]),
	.seg(dig0)
);


Digit #(
	.SEGMENT_POLARITY_HIGH_DEF(SEGMENT_POLARITY_HIGH)
) DIGIT1
(
	.clk(clk),
	.d(d1),
	.dp(dp[1]),
	.seg(dig1)
);


Digit #(
	.SEGMENT_POLARITY_HIGH_DEF(SEGMENT_POLARITY_HIGH)
) DIGIT2
(
	.clk(clk),
	.d(d2),
	.dp(dp[2]),
	.seg(dig2)
);


Digit #(
	.SEGMENT_POLARITY_HIGH_DEF(SEGMENT_POLARITY_HIGH)
) DIGIT3
(
	.clk(clk),
	.d(d3),
	.dp(dp[3]),
	.seg(dig3)
);

Digit #(
	.SEGMENT_POLARITY_HIGH_DEF(SEGMENT_POLARITY_HIGH)
) DIGIT4
(
	.clk(clk),
	.d(d4),
	.dp(dp[4]),
	.seg(dig4)
);

Digit #(
	.SEGMENT_POLARITY_HIGH_DEF(SEGMENT_POLARITY_HIGH)
) DIGIT5
(
	.clk(clk),
	.d(d5),
	.dp(dp[5]),
	.seg(dig5)
);

Digit #(
	.SEGMENT_POLARITY_HIGH_DEF(SEGMENT_POLARITY_HIGH)
) DIGIT6
(
	.clk(clk),
	.d(d6),
	.dp(dp[6]),
	.seg(dig6)
);

Digit #(
	.SEGMENT_POLARITY_HIGH_DEF(SEGMENT_POLARITY_HIGH)
) DIGIT7
(
	.clk(clk),
	.d(d7),
	.dp(dp[7]),
	.seg(dig7)
);

endmodule: seven_segment


// 7-segment decoder
module Digit
#(
	parameter integer	SEGMENT_POLARITY_HIGH_DEF = 0
)
(
	input logic				clk,
	input logic		[4:0]	d,			 // digit code to be displayed
	input logic				dp,			 // decimal point to be displayed
	output logic	[7:0]	seg 		 // output to seven segment display cathode
);

// digit to 7-segment decoder parameters.  Assumption is 0 = ON, 1 = Off
// but can be changed with the SEGMENT_POLARITY_HIGH parameter

// NOTE:  Probably should do this in an enum but I dont' think the
// code would be much more readable
localparam zero		= 7'b1000000;
localparam one		= 7'b1111001;
localparam two		= 7'b0100100;
localparam three	= 7'b0110000;
localparam four	 	= 7'b0011001;
localparam five		= 7'b0010010;
localparam six 		= 7'b0000010;
localparam seven	= 7'b1111000;
localparam eight 	= 7'b0000000;
localparam nine 	= 7'b0010000;
localparam A 		= 7'b0001000;
localparam B 		= 7'b0000011;
localparam C 		= 7'b1000110;
localparam D 		= 7'b0100001;
localparam E 		= 7'b0000110;
localparam F 		= 7'b0001110;
localparam seg_a	= 7'b1111110;
localparam seg_b 	= 7'b1111101;
localparam seg_c 	= 7'b1111011;
localparam seg_d	= 7'b1110111;
localparam seg_e	= 7'b1101111;
localparam seg_f	= 7'b1011111;
localparam seg_g	= 7'b0111111;
localparam lct		= 7'b0000111;

localparam ucH 		= 7'b0001001;
localparam ucL 		= 7'b1000111;
localparam ucR 		= 7'b0001000;
localparam lcl 		= 7'b1001111;
localparam lcr		= 7'b0101111;
localparam lcy 		= 7'b0010001;

localparam blank 	= 7'b1111111;

// reverse segs polarity of required
logic [7:0] seg_int;
assign seg = SEGMENT_POLARITY_HIGH_DEF ? ~seg_int : seg_int;

always_ff @ (posedge clk) begin: SEGS_MUX
	unique case (d)
		5'd00: seg_int <= {~dp,zero};
		5'd01: seg_int <= {~dp,one};
		5'd02: seg_int <= {~dp,two};
		5'd03: seg_int <= {~dp,three};
		5'd04: seg_int <= {~dp,four};
		5'd05: seg_int <= {~dp,five};
		5'd06: seg_int <= {~dp,six};
		5'd07: seg_int <= {~dp,seven};
		5'd08: seg_int <= {~dp,eight};
		5'd09: seg_int <= {~dp,nine};
		5'd10: seg_int <= {~dp,A};
		5'd11: seg_int <= {~dp,B};
		5'd12: seg_int <= {~dp,C};
		5'd13: seg_int <= {~dp,D};
		5'd14: seg_int <= {~dp,E};
		5'd15: seg_int <= {~dp,F};
		5'd16: seg_int <= {~dp,seg_a};
		5'd17: seg_int <= {~dp,seg_b};
		5'd18: seg_int <= {~dp,seg_c};
		5'd19: seg_int <= {~dp,seg_d};
		5'd20: seg_int <= {~dp,seg_e};
		5'd21: seg_int <= {~dp,seg_f};
		5'd22: seg_int <= {~dp,seg_g};
		5'd23: seg_int <= {~dp,lct};
		5'd24: seg_int <= {~dp,ucH};
		5'd25: seg_int <= {~dp,ucL};
		5'd26: seg_int <= {~dp,ucR};
		5'd27: seg_int <= {~dp,lcl};
		5'd28: seg_int <= {~dp,lcr};
		5'd29: seg_int <= {~dp,lcy};
		5'd30: seg_int <= {~dp,blank};
		5'd31: seg_int <= {~dp,blank};
	endcase
end: SEGS_MUX

endmodule: Digit
	
