/**
 * @file nexysa7pga.sv
 * @brief Top level module for stackCPU
 *
 * @version 1.0.0
 * @author    Roy Kravitz (roy.kravitz@pdx.edu)
 * @date    20-November-2024
 *
/usr/bin/bash: line 1: kknjjjjjjjjjjjjjjjjjjkkkkkkkkkkkkkkkkkkkkk: command not found
 * debounces buttons and switches.  For this design the devices are used as follows:
 *    switches:    sw[15]=1 -> result displayed in Hex, sw[14]=1 -> PC displayed in Hex else decimal
 *    leds:        display the current stackCPU instruction
 *    buttons:     btnCpuReset is used to reset the CPU.  btnR is used to single step the CPU
 *    digits[7:3]  result from executed instruction.  32-bit signed crunched into 5 BCD digits.
 *                 Out of range result displays "99999"
 *    digits[2:0]  program counter of executed instruction. ERROR displays Err, HALT displays Hlt.
 *    dp[7]        decimal point bit-7 is lit if result is negative (< 0)
 *    dp[6]        decimal point bit-6 is lit if the result is > 99999 (overflow)
 *    dp[3]        separator between result and PC.  Always on
 *    dp[0]        toggles on every  valid_result
 */
`timescale 1 ns / 1 ns

// global definitions, parameters, etc.
import stackCPU_DEFS::*;

module nexysa7fpga
(
    input logic         clk,
    input logic [15:0]  sw,          // sw[15:14] used for display formatting
    input logic         btnU,        // not used in this project
    input logic         btnR,        // single step instruction on rising edge
    input logic         btnL,        // not used in this project
    input logic         btnD,        // not used in this project
    input logic         btnC,        // not used in this project
    input logic         btnCpuReset, // resets the stackCPU.  Asserted low
    output logic [15:0] led,         // displays the current instruction    
    output logic  [7:0] an,          // 7-seg[7:3]-> result, 7-seg[2:0]-> PC
    output logic  [6:0] seg,
    output logic        dp
);
    
// NexysA7 board interface
logic          db_btnU, db_btnR, db_btnL, db_btnD, db_btnC, db_btnCpuReset;    // debounced buttons
logic [15:0] db_sw;                                                            // debounced switches

logic  [4:0] dig73[5:0], dig20[2:0];                    // 7-seg display digits
logic  [4:0] dec_dig20[2:0], hex_dig20[2:0];            // PC display variants
logic  [7:0]    dp70;                                   // decimal points
logic  [4:0] disp_err[2:0] = '{5'd14, 5'd28, 5'd28};    // display digits for error
logic  [4:0] disp_hlt[2:0] = '{5'd24, 5'd27, 5'd23};    // display digits for halt

logic  [3:0] pc_bcd_hundreds, pc_bcd_tens, pc_bcd_ones; // BCD for 7-seg dig[2:0]
logic [19:0] bcd_hi;                                    // BCD for 7-set dig[7:3]
logic        new_result;                                // toggles on every new valid result
logic        resetn;                                    // global reset.  Asserted low for reset
logic        is_neg_result;                             // result is negative
logic        clk_8MHz;                                  // 8Mhz system clock
logic        step_d;                                    // used to generate single cycle pulse for stepping CPU
logic        single_step;

logic        reset; // Asserted high for reset
assign reset = ~resetn;

// stackCPU interface
logic valid_result, halt, error;
logic [PC_WIDTH_DEF-1:0] pc;
logic [INSTR_WIDTH_DEF-1:0] instruction;
logic signed [DATA_WIDTH_DEF-1:0] result;

// saved stackCPU state
logic [PC_WIDTH_DEF-1:0]            latched_pc;
logic [INSTR_WIDTH_DEF-1:0]            latched_instruction;
logic signed [DATA_WIDTH_DEF-1:0]     latched_result;

// btnCpuReset is asserted low.  
assign resetn = btnCpuReset;
//leds display the current instruction
assign led = latched_instruction;

// decimal points have status info
assign dp70 = {is_neg_result, (latched_result > 99999), 2'b0, 1'b1, 2'b0, new_result};

// generate a single clock pulse from db_BTNr for single stepping
always_ff @(posedge clk_8MHz or negedge resetn) begin: SSTEP_FF
    if (~resetn)
        step_d <= 1'b0;
    else
        step_d <= db_btnR;
end:  SSTEP_FF
assign single_step = db_btnR & ~step_d;


// instantiate the clock Generator
clk_wiz_0 CLKGEN (
        .clk_out1(clk_8MHz),
        .resetn(resetn),
        .clk_in1(clk)
);

// instantiate the debouncer
// not a good idea to used db_btnCpuReset in this design becuase it keeps
// the debouncer in reset mode so it will not debounce the button.
debounce #(
    .CLK_FREQUENCY_HZ(8000000),
    .RESET_POLARITY_LOW(1),
    .SIMULATE(0)
) DBOUNCER
(
    .clk(clk_8MHz),
    .pbtn_in({btnU, btnR, btnL, btnD, btnC, btnCpuReset}),
    .switch_in(sw),    
    .pbtn_db({db_btnU, db_btnR, db_btnL, db_btnD, db_btnC, db_btnCpuReset}),
    .swtch_db(db_sw)
);

// instantiate the 8-digit 7-segment display controller
seven_segment #(
    .CLK_FREQUENCY_HZ(8000000),
    .RESET_POLARITY_LOW(1),
    .SIMULATE(0),
    .SEGMENT_POLARITY_HIGH(0)
) SSEG
(
    .clk(clk_8MHz),
    .reset(resetn),
    .d0(dig20[0]),
    .d1(dig20[1]),
    .d2(dig20[2]),
    .d3(dig73[0]),
    .d4(dig73[1]),
    .d5(dig73[2]),
    .d6(dig73[3]),
    .d7(dig73[4]),
    .dp(dp70),
    .seg({dp,seg}), 
    .an(an)
);


// instantiate the binary to bcd converter for the result
binary_to_bcd #(
    .BIN_WIDTH(20),
    .BCD_DIGITS(5),
    .IS_SIGNED(1)
)BCD_RESULT
(
    .binary(latched_result[19:0]),
    .bcd(bcd_hi),
    .is_negative(is_neg_result)                // result is negative
);

// instantiate the binary to bcd converter for the program counter
bin2bcd_8bits BCD_PC
(
    .binary(latched_pc),
    .bcd_hundreds(pc_bcd_hundreds),
    .bcd_tens(pc_bcd_tens),
    .bcd_ones(pc_bcd_ones)
);

// instantiate program memory
// The memory is 16-bits wide x 256 deep and was generated using
// the Vivado Distributed Memory Generator (IP Catalog:  memory generator) and
// initialized with test_pgm3.coe.

// IMPORTANT: Be sure to include stackCPU_program_memory_stub.v in your Vivado
// projectso that the memory is synthesized
stackCPU_program_memory PRGM_MEMORY (
  .a(pc),           // input wire [7 : 0] a
  .spo(instruction) // output wire [15 : 0] spo
);

// instantiate the stackCPU
stackCPU
#(
    .RESET_POLARITY_LOW(1),
    .SSTEP_ENABLE_DEF(1)
) STACKCPU
(  
    .clk(clk_8MHz),
    .reset(reset),
    .instruction(instruction),
    .pc(pc),
    .single_step(single_step),
    .result(result),
    .valid_result(valid_result),
    .error(error),
    .halt(halt)
);


// latch the stackCPU outputs so that we have a consistent view
// of the stackCPU state.  new_result is used to toggle dp[0]
always_ff @(posedge clk_8MHz or negedge resetn) begin: STACK_CPU_STATE
    if (~resetn) begin
        latched_pc <= '0;
        latched_instruction <= '0;
        latched_result <= '0;
        new_result <= 1'b0;
    end
    else if (valid_result) begin
        latched_pc <= pc;
        latched_instruction <= instruction;
        latched_result <= result;    
        new_result <= ~new_result;     // toggle for new_result LED
    end
    else begin
        latched_pc <= latched_pc;
        latched_instruction <= latched_instruction;
        latched_result <= latched_result;        
        new_result <= new_result;
    end
end: STACK_CPU_STATE 
    
// mux for 7-segment display[2:0]- normally the PC
// sw[14] = 0  dig[2:0] = PC (decimal) or Hlt or Err
always_comb begin: PC_DISPLAY1
    if (halt) begin
        dec_dig20[2] = disp_hlt[2];
        dec_dig20[1] = disp_hlt[1];
        dec_dig20[0] = disp_hlt[0];
    end
    else if (error) begin
        dec_dig20[2] = disp_err[2];
        dec_dig20[1] = disp_err[1];
        dec_dig20[0] = disp_err[0];    
    end
    else begin
//    if (pc_bcd_hundreds == 4'b0)
//        dec_dig20[2] = 5'b11111; // blank the digit if PC < 100
//    else // only numbers 0-9
          dec_dig20[2] = {1'b0, pc_bcd_hundreds};
            
        dec_dig20[1] = {1'b0, pc_bcd_tens};
        dec_dig20[0] = {1'b0, pc_bcd_ones};
    end
end: PC_DISPLAY1

// mux for 7-segment display[2:0]- normally the PC
// sw[14] = 1 dig[2] = <blank>, dig[1:0] = PC in Hex or __H or __E
always_comb begin: PC_DISPLAY2
    if (halt) begin
        hex_dig20[2] = 5'b11111;           // blank
        hex_dig20[1] = 5'b11111;
        hex_dig20[0] = disp_hlt[2];        // just the H
    end
    else if (error) begin
        hex_dig20[2] = 5'b11111;           // blank
        hex_dig20[1] = 5'b11111;
        hex_dig20[0] = disp_err[2];        // just the E
    end
    else begin
        hex_dig20[2] = 5'b11111;
        hex_dig20[1] = {1'b0, latched_pc[7:4]}; // only PC in Hex
        hex_dig20[0] = {1'b0, latched_pc[3:0]};
    end
end: PC_DISPLAY2

// PC display mux
always_comb begin:  PC_DISPLAY_MUX
    if (db_sw[14]) begin
        dig20[2] = hex_dig20[2];
        dig20[1] = hex_dig20[1];
        dig20[0] = hex_dig20[0];
    end
    else begin
        dig20[2] = dec_dig20[2];
        dig20[1] = dec_dig20[1];
        dig20[0] = dec_dig20[0];    
    end
end: PC_DISPLAY_MUX


// 7-segment display digits [7:3] - normally the result
// when sw[15] is up (on) the result is in Hex.  When off, in signed decimal
always_comb begin: RESULT_DISPLAY
    dig73[4] = sw[15] ? latched_result[19:16] : {1'b0, bcd_hi[19:16]};
    dig73[3] = sw[15] ? latched_result[15:12] : {1'b0, bcd_hi[15:12]};
    dig73[2] = sw[15] ? latched_result[11:8]  : {1'b0, bcd_hi[11:8]};
    dig73[1] = sw[15] ? latched_result[7:4]   : {1'b0, bcd_hi[7:4]};
    dig73[0] = sw[15] ? latched_result[3:0]   : {1'b0, bcd_hi[3:0]};
end: RESULT_DISPLAY

endmodule: nexysa7fpga
