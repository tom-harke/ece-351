/**
 * dig2SevenSeg.sv - translates a digit code to it's 7-segments
 *
 * @author Tom Harke (harke@pdx.edu)
 * @date   2024 Nov 2
 *
 * @brief
 * Performs the following translation:
 * 
 *     0- 9  Characters '0' to '9'
 *    10-15  Upper case characters 'A' to 'F'
 *    16-22  Single segments a to g
 *    23     Space (Blank)
 *    24     Upper case character 'H'
 *    25     Upper case character 'L'
 *    26     Upper case character 'R'
 *    27     Lower case character 'l'
 *    28     Lower case character 'r'
 *    29-31  Space (blank)
 *
 * @note:  This is an example of a ROM
 */
 
module dig2SevenSeg (
    input  logic [4:0] digit,
    output logic [6:0] seg7out
);

assign output =
  unique case (input)
    // hexadecimal characters
    5'b00000: 7'b1111110; // char '0'
    5'b00001: 7'b0000110; // char '1'
    5'b00010: 7'b1101101; // char '2'
    5'b00011: 7'b1111001; // char '3'
    5'b00100: 7'b0110011; // char '4'
    5'b00101: 7'b1011011; // char '5'
    5'b00110: 7'b1011111; // char '6'
    5'b00111: 7'b1110000; // char '7'
    5'b01000: 7'b1111111; // char '8'
    5'b01001: 7'b1111011; // char '9'
    5'b01010: 7'b1110111; // char 'A'
    5'b01011: 7'b0011111; // char 'B'
    5'b01100: 7'b1001110; // char 'C'
    5'b01101: 7'b0111101; // char 'D'
    5'b01110: 7'b1001111; // char 'E'
    5'b01111: 7'b1000111; // char 'F'

    // single segments
    5'b10000: 7'b1000000; // Segment a
    5'b00001: 7'b0100000; // Segment b
    5'b10010: 7'b0010000; // Segment c
    5'b10011: 7'b0001000; // Segment d
    5'b10100: 7'b0000100; // Segment e
    5'b10101: 7'b0000010; // Segment f
    5'b10110: 7'b0000001; // Segment g

    // 5'b10111 via default

    // misc letters
    5'b11000: 7'b0110111; // char 'H'
    5'b11001: 7'b0001110; // char 'L'
    5'b11010: 7'b1110111; // char 'R'
    5'b11011: 7'b0000110; // char 'l'
    5'b11100: 7'b0000101; // char 'r'

    // blank
    default:  7'b0000000; // BLANK
  endcase;

endmodule: dig2SevenSeg
