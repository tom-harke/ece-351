
module
 - a template
 - convention: 1 module per .sv file
    - possible to put several
 - order doesn't matter

port
 - types
    - input
    - output
    - inout
 - if omitted at top level, will map to arbitrary pins on ASIC/FPGA
```
module addbit

  // Parameters, with defaults
  #(
    parameter N=8
  )

  // Ports
  (
    input  logic [N-1:0] a, b,
    input  logic         ci,
    output logic [N-1:0] sum,
    output logic         co,
  );

  // Internal signals
  logic n1, n2;

  // functionality
  ...
endmodule: addbit
```
