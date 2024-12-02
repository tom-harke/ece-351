/**
 * @file binary2bcd.sv
 * @brief uses Double-dabble algorithm to convert signed and unsigned integers to BCD
 *
 * @version 1.0.0
 * @author	ChatGPT w/ guidance by Roy Kravitz (roy.kravitz@pdx.edu)
 * @date	19-November-2024
 *
 * @details
 * Uses the double-dabble algorithm (https://en.wikipedia.org/wiki/Double_dabble) to convert
 * signed (2's complement) and unsigned integers to BCD.  You should check the range to see
 * the largest number that can fit into the number of BCD digits.  For example, a 20-bit 2'see
 * complement integer has a range of −524288 to 524287 which would take 6 BCD digits plus a Sign 
 * indicator.  Constraining the number of BCD digits to 5 reduces the maximum range for a multiply
 * (which can result in 2x the number of bits) would limit the range on a multiply to 511 x 195
 * (or there abouts).  It's a tradeoff.  The module checks for overflow (number > number of BCD
 * digits and if true returns the maximum integer value (ex: 99999 for 5 digits)
 *
 * Revision History
 * ----------------
 * 1.0.0 (18-Nov-2024, RK)	Initial version
 *
 */
module binary_to_bcd #(
    parameter BIN_WIDTH = 20,         // Input binary width
    parameter BCD_DIGITS = 5,         // Number of BCD digits
    parameter IS_SIGNED = 1           // 1 = signed (two's complement), 0 = unsigned
) (
    input logic signed [BIN_WIDTH-1:0] 	binary, 	// Binary input
    output logic [BCD_DIGITS*4-1:0] 	bcd,		// BCD output
	output logic						is_negative	// 1 if the number is negative
);

	// Compute the max and min values representable by the given number of BCD digits
    localparam signed [BIN_WIDTH-1:0] MAX_BCD = (10 ** BCD_DIGITS) - 1; // e.g., 99999 for 5 digits
    localparam signed [BIN_WIDTH-1:0] MIN_BCD = -(10 ** BCD_DIGITS) + 1; // e.g., -99999 for 5 digits

    logic [BIN_WIDTH-1:0] abs_value;   // Absolute value of binary input
    logic [BCD_DIGITS*4+BIN_WIDTH-1:0] extended_bcd; // Extended BCD for Double-Dabble
	logic exceeds_range;				// determines whether the abs value of a number fits within
										// the number or BCD digits
    integer i, j;

    // Main conversion logic
    always_comb begin
        is_negative = IS_SIGNED ? binary[BIN_WIDTH-1] : 1'b0; // Check sign bit if signed
        abs_value = IS_SIGNED && is_negative ? ~binary + 1 : binary; // absolute value for signed input

		// do a range check for the number of BCD digits
		exceeds_range = (binary > MAX_BCD) || (binary < MIN_BCD);
        if (exceeds_range) begin
            // Overflow: Return max BCD value
			bcd = IS_SIGNED && is_negative ? {BCD_DIGITS{4'h9}} : {BCD_DIGITS{4'h9}};
        end
		else begin
        // Initialize the extended BCD with the absolute binary value
        extended_bcd = {BCD_DIGITS*4'b0, abs_value};

        // Perform the Double-Dabble algorithm
			for (i = 0; i < BIN_WIDTH; i++) begin
				for (j = BCD_DIGITS*4 + BIN_WIDTH - 1; j >= BIN_WIDTH; j -= 4) begin
					if (extended_bcd[j -: 4] >= 5)
						extended_bcd[j -: 4] += 4'd3;
				end
				extended_bcd = extended_bcd << 1; // Shift left
			end

			// Extract the BCD portion
			bcd = extended_bcd[BCD_DIGITS*4 + BIN_WIDTH - 1 : BIN_WIDTH];
		end
	end
endmodule: binary_to_bcd
