`timescale 1 ns / 1 ns

module one_bit_fa (a,b,c_in,sum,c_out,g,p);
    input a,b,c_in;
    output sum,c_out,g,p;

    wire w1;

    //g
    and #1 u1(g,a,b);

    //p
    xor #1 u2(p,a,b);

    //c_out
    and #1 u3(w1,p,c_in);
    or #1 u4(c_out,w1,g);

    //sum
    xor #1 u5(sum,p,c_in);

endmodule //one_bit_fa

module four_bit_cba (a,b,c_in_initial,c_out_final,sum,g,p);
    //Variables
    input [3:0] a,b;
    input c_in_initial;
    output [3:0] sum,g,p;
    output c_out_final;
    output reg c_out_final_reg;

    wire [3:0] c_in,c_out;
    wire select;

    //Instantiate 4 one_bit_fa
    one_bit_fa M[3:0] (.a(a), .b(b), .c_in(c_in), .sum(sum), .c_out(c_out), .g(g), .p(p));

    //Attach initial c_in input to the first modules c_in
    assign c_in[0] = c_in_initial;

    //Attaches each modules c_out to the next module c_in
    assign c_in[3:1] = c_out[2:0];

    //MUX
    and u6(select,p[0],p[1],p[2],p[3]);
    always @(c_in_initial == 1 or c_in_initial == 0 or c_out[3] == 1 or c_out[3] == 0) begin
        if (select == 1) begin
            #1 c_out_final_reg = c_in_initial;
        end else begin
            c_out_final_reg = c_out[3];
        end
    end

    assign c_out_final = c_out_final_reg;

endmodule //four_bit_cba

module n_bit_cba 
#(parameter integer WIDTH = 4)
(a,b,c_in_initial,c_out_final,sum,g,p);

    //Variables
    input [WIDTH - 1:0] a,b;
    input c_in_initial;
    output [WIDTH - 1:0] sum,g,p;
    output c_out_final;

    wire [WIDTH/4 - 1:0] c_in,c_out;

    //Instantiate Modules
    genvar i;
    generate
        for (i=0; i<(WIDTH/4); i=i+1) begin
            four_bit_cba Ni(.a(a[4*(i+1)-1:4*i]), .b(b[4*(i+1)-1:4*i]), .c_in_initial(c_in[(4*i)/4]), 
            .c_out_final(c_out[(4*i)/4]), .sum(sum[4*(i+1)-1:4*i]), .g(g[4*(i+1)-1:4*i]), .p(p[4*(i+1)-1:4*i]));
        end
    endgenerate

    //Attach initial c_in input to the first modules c_in
    assign c_in[0] = c_in_initial;

    //Attach final c_out output to final c_out module
    assign c_out_final = c_out[WIDTH/4-1];

    //Attaches each modules c_out to the next module c_in
    if (WIDTH !== 4) begin
        assign c_in[WIDTH/4 - 1:1] = c_out[WIDTH/4-2:0];
    end

endmodule //n_bit_cba

`ifdef tb

module n_bit_cba_tb;
    parameter integer WIDTH = 64;
    reg [WIDTH-1:0] a,b;
    reg c_in;
    wire c_out;
    wire [WIDTH-1:0] sum,g,p;

    n_bit_cba #(.WIDTH(WIDTH)) CBA1(.a(a), .b(b), .c_in_initial(c_in), .c_out_final(c_out), .sum(sum), .g(g), .p(p));

    integer i;

    initial begin
        $dumpfile("n_bit_cba_tb.vcd");
        $dumpvars;

        for (i = 0; i < 16; i = i + 1) begin
            a[31:0] = $urandom;
            a[63:32] = $urandom;
            b[31:0] = $urandom;
            b[63:32] = $urandom;
            c_in = $urandom;
            #(13 + (WIDTH)/4);
            if (a+b+c_in !== sum) begin
                $display("Incorrect sum!");
                $finish;
            end
        end
        $finish;
    end
endmodule//n_bit_cba_tb
`endif//`ifdef tb