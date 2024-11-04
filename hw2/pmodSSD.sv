/**
 * THIS IS THE STARTER CODE FOR YOUR PmodSSD
 *
 * PmodSSD.sv - Implements a Digilent PmodSSD - a 2 digit 7-segment display
 *
 * @author: Tom Harke (harke@pdx.edu) 
 * @date:   2024 Nov 2
 *
 * @brief
 * Implements Digilent PmodSSD Peripheral Module.  The PmodSSD contains
 * two 7-segment LED digits connected in a common cathode configuration.  Each of the two
 * digits is composed of seven high-bright LED segments arranged in a figure-8 pattern.
 * Each of the the segments can be individually illuminated presenting 128 possible characters.
 * The most useful combinations are the patterns comprising the 16 hexadecimal digits,
 * those that light a single segment at a time, and the pattern with all segments dark
 *(digit looks off).  Each of the digits also includes an 8th segment - a decimal point
 * but that decimal point is not driven in the PmodSSD.
 *
 * In a common cathode configuration such as the one used in the PmodSSD the cathodes 
 * of the seven LEDs forming each digit are connected together to form a "digit enable" signal.
 * The anodes of similar segments on both digits are connected into seven circuit nodes 
 * available on the PmodSSD connector.  The two "digit enables" are connected to a single
 * PmodSSD pin with one digit enabled when the signal is asserted high and the other 
 * digit enabled when the signal is asserted low.  This signal connection scheme creates a 
 * multiplexed display where the anode signals are common to both digits but they can only
 * illuminate the segments of the digit whose correspond "digit enable" (cathode)
 * signal is asserted low.
 *
 * The code in this module implements a scanning display controller circuit that drives the anode
 * signals and the corresponding cathode patterns on each of the digits in a repeating, 
 * continuous succession, at an update rate faster than the human eye can respond 
 * (i.e. >= 60 Hz).
 *  
 * For more information on the PmodSSD refer to the Digilent PmodSSD Peripheral Module
 * Board Reference Manual and 500-126, the Digilent PmodSSD schematic (www.digilentinc.com)
 *
 * @note original version by Roy Kravitz, circa 2012.  Updated to SystemVerilog in 2021.
 * Minor changes in 2024 to bring in line w/ the way I've evolved my SystemVerilog coding style
 */

module pmodSSD
#(
  parameter SIMULATE = 1 // speeds up the clock divider to save millions of
                         // simulation cycles
)
(
  input       clk, reset,     // clock and reset signals.  reset
                              // is asserted high
  input [4:0] digit1, digit0, // digit character codes.  Each digit
                              // is a code for one of 32 valid
                              // patterns
  
  output  SSD_AG, SSD_AF, SSD_AE, // anode segment drivers
          SSD_AD, SSD_AC, SSD_AB,
          SSD_AA,
  output  SSD_C              // common cathode "digit enable"
);

timeunit 1ns/1ns;

// ADD YOUR INTERNAL VARIABLES HERE
// internal variables
logic      tick_120Hz;    // 120Hz clock tick from clock divider
logic      tick_60Hz;    // 60Hz square wave to multiplex digits and drive PmodSSD_c
logic [6:0]    an1, an0;    // anodes for each decoded digits


logic      foo;    // TODO
logic [6:0] bar;   // TODO

// instantiate the clock divider for multiplexing the digits
clk_divider  #(
  .CLK_INPUT_FREQ_HZ(100_000_000),  // 100MHz input frequency
  .TICK_OUT_FREQ_HZ(120),        // digits are multiplexed at 60Hz
                    // so set the tick-out to 120Hz to produce
                    // a 60Hz square wave
  .SIMULATE(SIMULATE)          // to simulate or not to simulate...that is the
                    // question.
)  CDIV_PMODSSDIF
(
  .clk(clk),
  .reset(reset),
  .tick_out(tick_120Hz)
);

// square up the clock signal to drive the digit enable
// This will give you a 50% duty cycle clock at 1/2 the frequency
always_ff @(posedge clk or posedge reset) begin
  if (reset)
    tick_60Hz <= 1'b0;
  else if (tick_120Hz)
    tick_60Hz <= ~tick_60Hz;
  else
    tick_60Hz <= tick_60Hz;
end // generate 60Hz square wave


// instantiate your digit to 7 segment decoders
dig2SevenSeg DIGIT1DEC (
  .digit(digit1),
  .seg7out(an1)
);

dig2SevenSeg DIGIT0DEC (
  .digit(digit0),
  .seg7out(an0)
);

  
// ADD YOUR CODE TO PRODUCE AND MULTIPLEX THE TWO DIGITS AND MAP THEM TO THE SSD_ OUTPUTS


assign SSD_C = tick_60Hz;
assign {
  SSD_AA,
  SSD_AB,
  SSD_AC,
  SSD_AD,
  SSD_AE,
  SSD_AF,
  SSD_AG
} = SSD_C ? an1 : an0;

endmodule: pmodSSD
