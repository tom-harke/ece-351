/////////////////////////////////////////////////////////////
// tb_rca_8bits.sv - test bench for 8-bit Ripple Carry Adder
//
// Author:  Roy Kravitz (roy.kravitz@pdx.edu)
//
// Implements a test bench for an 8-bit
// Ripple Carry Adder.  Does not check all of the cases (would be 65K).
// Implements input timing delay specified for the problem
////////////////////////////////////////////////////////////
module tb_rca_8bits;

timeunit 1ns/1ns;

// stimulus/result for RCA
logic	[7:0]	ain, bin;		// A and B inputs to adder
logic			cin;			// carry in to adder
logic	[7:0]	sum;			// sum output from adder
logic			cout;			// carry out from the adder	

int i, j;						// loop indices

// instantiate the DUT
dut DUT (.*);

// set up monitor
initial begin : set_up_monitor
	$monitor($time, "\t\tA:%d\tB:%d\tCin:%b\t\t\Sum:%d\tCout:%b", ain, bin, cin, sum, cout);
end : set_up_monitor

// generate the stimulus/results
initial begin : stimulus
//	$monitoroff;
	
	// do testing w/ carry in = 0
	$display("Test some cases with carry in = 0");
	for (i = 0; i < 16; i++) begin : carry_in_0
		ain = 'x;
		for (j = 16; j < 32; j++) begin
			cin = 'x;
			bin = 'x;
			ain = i;
			#1;
			bin = j;
			cin = 0;
			#100;
//			$display($time, "\t\tA:%d\tB:%d\tCin:%b\t\t\Sum:%d\tCout:%b", 
//				ain, bin, cin, sum, cout);
		end
	end : carry_in_0
		
	// do testing w/ carry in = 1
	$display("Test some cases with carry in = 1");
	for (int i = 80; i < 96; i++) begin : carry_in_1
		ain = 'x;
		for (int j = 160; j < 176; j++) begin
			cin = 'x;
			bin = 'x;
			ain = i;
			#1;
			bin =  j;
			cin = 1;
			#100;
//			$display($time, "\t\tA:%d\tB:%d\tCin:%b\t\t\Sum:%d\tCout:%b", 
//				ain, bin, cin, sum, cout);
		end
	end : carry_in_1
	#5;
	$stop;
end : stimulus

endmodule : tb_rca_8bits


