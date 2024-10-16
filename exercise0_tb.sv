
module exercise0_tb;
timeunit 1ns/1ns;
logic	[7:0]	ain, bin, sum;			// sum output from adder
logic			cin, cout;			// carry out from the adder	
logic   [8:0]   actual, expected;
int i, j;						// loop indices
dut DUT (.*);
initial begin : stimulus
	$display("Test some cases with carry in = 0");
	for (i = 0; i < 16; i++) begin : carry_in_0
		for (j = 16; j < 32; j++) begin
			cin = 'x; bin = 'x; ain = 'x; #20;
			ain = i;  bin = j;  cin = 0;  #80;
			expected = ain + bin + cin;
			actual = {cout,sum}; $display($time, "\t\tA:%d\tB:%d\tCin:%b", ain, bin, cin);
            if (actual !== expected) {
	        	$display($time, "\t\tA:%d\tB:%d\tCin:%b\t\t\Sum:%d\tCout:%b\tTotal:%d\tExp:%d", ain, bin, cin, sum, cout,actual,expected);
			}
		end
	end : carry_in_0
		
	$display("Test some cases with carry in = 1");
	for (int i = 80; i < 96; i++) begin : carry_in_1
		for (int j = 160; j < 176; j++) begin
			cin = 'x; bin = 'x; ain = 'x; #20;
			ain = i;  bin = j;  cin = 1;  #80;
			expected = ain + bin + cin;
			actual = {cout,sum};
            if (actual !== expected) {
	        	$display($time, "\t\tA:%d\tB:%d\tCin:%b\t\t\Sum:%d\tCout:%b\tTotal:%d\tExp:%d", ain, bin, cin, sum, cout,actual,expected);
			}
		end
	end : carry_in_1
	#5;
	$stop;
end : stimulus

endmodule : exercise0_tb

