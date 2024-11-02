/**
 * THIS iS THE STARTER CODE FOR YOUR 7-SEGMENT DISPLAY DECODER
 *
 * dig2SevenSeg.sv - translates a digit code to it's 7-segments
 *
 * @author 	<your name> (<your email address>)
 * @date 	<date your created this module>
 *
 * @brief
 * Performs the following translation:
 * 
 *	0 - 9	Characters 0 to 9
 *	10 – 15	Upper case characters A to F
 *	16 – 22	Single segments a to g
 *	23		Space (Blank)
 *	24		Upper case character H
 *	25		Upper case character L
 *	26		Upper case character R
 *	27		Lower case character L (l)
 *	28		Lower case character R ( r )
 *	29 – 31	Space (blank)
 *
 * @note:  This is an example of a ROM
 */
 
module dig2SevenSeg (
	input logic [4:0]	digit,
	output logic [6:0]	seg7out
);

// ADD YOUR CODE HERE
	
endmodule: dig2SevenSeg
