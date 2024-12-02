/**
 * @file bin2bcd_8bits.sv
 * @brief uses Double-dabble algorithm to convert an unsigned 8-bit number to BCD
 *
 * @version 1.0.0
 * @author	ChatGPT w/ guidance by Roy Kravitz (roy.kravitz@pdx.edu)
 * @date	26-Nov-2024
 *
 * @details
 * Uses the double-dabble algorithm (https://en.wikipedia.org/wiki/Double_dabble) to convert
 * an unsigned 8-bit binary number to BCD.  Since it is not configurable and very specific
 * functionality it is simpler than binary2bcd.sv that I used for signed and unsigned numbers
 * with overflow protection.  I included it in the design so you can get a more straightforward
 * example of how the double-dabble algorithm works. 
 *
 * Revision History
 * ----------------
 * 1.0.0 (26-Nov-2024, RK)	Initial version crated by ChatGPT 4.0
 *
 */
module bin2bcd_8bits (
    input logic [7:0] binary,  // 8-bit unsigned binary input
    output logic [3:0] bcd_hundreds,  // BCD digit for hundreds
    output logic [3:0] bcd_tens,      // BCD digit for tens
    output logic [3:0] bcd_ones       // BCD digit for ones
);
    logic [19:0] shift_reg; // Temporary shift register (16 + 4 extra bits for BCD manipulation)
    int i;                 // Loop index

    always_comb begin
        // Initialize the shift register
        shift_reg = {12'b0, binary};

        // Perform the double-dabble algorithm (8 iterations for 8 bits of input)
        for (i = 0; i < 8; i++) begin
            // Check and adjust BCD digits if greater than 4
            if (shift_reg[19:16] >= 5) shift_reg[19:16] = shift_reg[19:16] + 3; // Hundreds
            if (shift_reg[15:12] >= 5) shift_reg[15:12] = shift_reg[15:12] + 3; // Tens
            if (shift_reg[11:8] >= 5) shift_reg[11:8] = shift_reg[11:8] + 3;   // Ones

            // Shift left by 1 bit
            shift_reg = shift_reg << 1;
        end

        // Extract BCD digits from the shift register
        bcd_hundreds = shift_reg[19:16];
        bcd_tens = shift_reg[15:12];
        bcd_ones = shift_reg[11:8];
    end
endmodule: bin2bcd_8bits 
