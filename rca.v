`timescale 1 ns / 1 ns

module one_bit_fa (s,c_out,a,b,c_in);
    input a,b,c_in;
    output s,c_out;

    wire w1,w2,w3;

    //sum
    xor #1 g1(s,a,b,c_in);

    //c_out
    and #1 g3(w1,a,b);
    and #1 g4(w2,a,c_in);
    and #1 g5(w3,b,c_in);
    or #1 g6(c_out,w1,w2,w3);

endmodule //rca

module n_bit_rca 
    #(parameter integer WIDTH = 2)
    (c_out_final,s,a,b,c_in_initial);
    input [WIDTH-1:0] a,b;
    input c_in_initial;
    output [WIDTH-1:0] s;
    output c_out_final;

    wire [WIDTH-1:0] c_in,c_out;

    //Instantiate WIDTH number of one bit full adders
    one_bit_fa M[WIDTH-1:0] (.a(a), .b(b), .c_in(c_in), .c_out(c_out), .s(s));

    //Attaches initial c_in input to the first modules c_in
    assign c_in[0] = c_in_initial;

    //Attaches final c_out output to final c_out module
    assign c_out_final = c_out[WIDTH-1];

    //Avoids index out of range issue
    if (WIDTH > 1) begin
        //Attaches each modules c_out to the next modules c_in
        assign c_in[WIDTH-1:1] = c_out[WIDTH-2:0];
    end

endmodule //n_bit_rca

`ifdef tb

module n_bit_rca_tb;
    parameter integer WIDTH = 4;    //This changes the number of full adders
    reg [WIDTH-1:0] a,b;
    reg c_in;
    wire c_out;
    wire [WIDTH-1:0] sum;

    //Instantiates a WIDTH bit ripple carry adder
    n_bit_rca #(.WIDTH(WIDTH)) RCA1(.a(a), .b(b), .c_in_initial(c_in), .c_out_final(c_out), .s(sum));

    //for loop variables
    integer i;
    integer j;
    
    initial
        begin
            $dumpfile("n_bit_rca_tb.vcd");
            $dumpvars;

            c_in = 0;   // Initialize c_in
            repeat(2) begin     //2 loops for c_in = 0 and c_in = 1
                for (i = 0;i<(2**(WIDTH));i = i+1) begin    //Increments a
                    a = i;
                    for (j = 0;j<(2**(WIDTH)) ;j = j+1 ) begin  //Increments b
                        b = j;
                        #(2*WIDTH)      //Wait time for rca is 2n
                        if (a+b+c_in !== sum) begin     //checks if output is correct
                            $display("Incorrect!");
                            $finish;
                        end
                    end
                end
                c_in = 1;   //Increment c_in
            end
            $display("All input combinations verified!");
        end
endmodule//n_bit_rca_tb
`endif //`ifdef tb