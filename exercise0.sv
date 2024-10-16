// This is a single file with almost no whitespace since I haven't found a
// simulator yet that works for me, and am stuck repeated copying and pasting
// into a web GUI :-/

// fa - Single bit full adder // From: Roy Kravitz

module fa (
    input logic A, B, Cin,  // a, b, and carry_in inputs
    output logic S, Cout    // sum and carry out outputs 
);
  timeunit 1ns/1ns;
  logic xor1out,and1out, and2out;
  xor #4 xor1(xor1out, A, B), xor2(S, xor1out,Cin);
  and #3 and1(and1out, Cin, xor1out), and2(and2out, A, B);
  or  #3 or1(Cout, and1out, and2out);
endmodule: fa

// adder_4bits - 4-bit full adder // Adapted from eg of Roy Kravitz

module adder_4bits (
    input  logic [3:0] A, B, input  logic C0,
    output logic [3:0] S,    output logic C4
);
  timeunit 1ns/1ns;
  wire C1, C2, C3;
  fa BIT3( .A(A[3]), .B(B[3]), .Cin(C3), .S(S[3]), .Cout(C4) );
  fa BIT2( .A(A[2]), .B(B[2]), .Cin(C2), .S(S[2]), .Cout(C3) );
  fa BIT1( .A(A[1]), .B(B[1]), .Cin(C1), .S(S[1]), .Cout(C2) );
  fa BIT0( .A(A[0]), .B(B[0]), .Cin(C0), .S(S[0]), .Cout(C1) );
endmodule: adder_4bits

// dut - 8-bit full adder // Author: tom.harke@gmail.com

module dut (
    input logic [7:0] ain, bin,
    input logic cin,
    output logic [7:0] sum,
    output logic cout
);
  timeunit 1ns/1ns;
  wire cmid;
  adder_4bits MSB(.A(ain[7:4]), .B(bin[7:4]), .C0(cmid), .S(sum[7:4]), .C4(cout));
  adder_4bits LSB(.A(ain[3:0]), .B(bin[3:0]), .C0(cin),  .S(sum[3:0]), .C4(cmid));
endmodule: dut


