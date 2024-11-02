module d_reg (
  input  logic clk,
  input  logic [7:0] d,
  output logic [7:0] q
);

  timeunit 1ns; timeprecision 1ns;
  always_ff @(posedge clk)
    q <= d;

endmodule: d_reg
