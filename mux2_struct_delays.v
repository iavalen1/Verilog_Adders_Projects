`timescale 1 ns / 100 ps

module mux2_struct (
		    output out,
		    input select, d0, d1
		    );

   wire 		  s0, w0, w1;

   not #1 g1(s0, select);
   and #1 g2(w0,s0,d0);
   and #1 g3(w1, select, d1);
   or #1  g4(out,w0, w1);
endmodule // mux2_struct

`ifdef tb1

module mux2_struct_tb;
   reg a, b, s;
   wire f;
   reg 	expected;

   mux2_struct myMux2_v1(.select(s), .d0(a), .d1(b), .out(f));

   initial
     begin: initialBlock1
	$dumpfile("mux2_struct_delays_tb1.vcd");
	$dumpvars;
	
	s=0;
	a=0;
	b=1;
	expected = 0;
	#10 a = 1;
	b=0;
	expected = 1;
	#10 s = 1;
	a = 0;
	b = 1;
	expected = 1;
	#1 $finish;  // this closes any files opened for i/o
     end // initial begin

   initial
     begin: initialBlock2
	$display("Test of mux2 using tb1.");
	$monitor("time = %d [s, a, b] = %b %b %b, s0 = %b, w0 = %b, w1 = %b, out = %b expected = %b ",
		 $time,s,a,b, myMux2_v1.s0, myMux2_v1.w0, myMux2_v1.w1, f, expected);
     end
   
endmodule // mux2_struct_tb
`endif //  `ifdef tb1

// Test bench for 2-input multiplexor
// Test all input combinations using a loop

`ifdef tb2

module mux2_struct_tb2;
   reg [2:0] inp_vec;
   reg 	     expected;
   wire      f;

   mux2_struct myMux2_v2(.select(inp_vec[2]), .d1(inp_vec[1]), .d0(inp_vec[0]), .out(f));

   initial
     begin
	$dumpfile("mux2_struct_delays_tb2.vcd");
	$dumpvars;
	
	inp_vec = 3'b000;
	expected = 1'b0;
	repeat(7)
	  begin
	     #10 inp_vec = inp_vec + 3'b001;
	     if (inp_vec[2])
	       expected = inp_vec[1];
	     else
	       expected = inp_vec[0];
	  end
	#1 $finish;  // close files opened for i/o
     end // initial begin

   initial
     begin
	$display("Test of mux2 using tb2.");
	$monitor("[select in1 in0] = %b s0 = %b, w0 = %b, w1 = %b, out = %b expected = %b ",
		 inp_vec, myMux2_v2.s0, myMux2_v2.w0, myMux2_v2.w1, f, expected);
     end
endmodule // mux2_struct_tb2
`endif //  `ifdef tb2

