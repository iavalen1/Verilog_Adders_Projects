`timescale 1 ns / 1 ns

module one_bit_fa (a,b,c_in,sum);
    input a,b,c_in;
    output sum;

    //sum
    xor #1 u1(sum,a,b,c_in);

endmodule //one_bit_fa

module gp_generate (a,b,g,p);
    input a,b;
    output g,p;

    //g
    and #1 u2(g,a,b);

    //p
    xor #1 u3(p,a,b);

endmodule

module grp_crry_la (g,p,c_in,c1,c2,c3,G,P);
    input [3:0] g,p;
    input c_in;
    output c1,c2,c3,G,P;

    wire w1,w2,w3,w4,w5,w6,w7,w8,w9;

    //c1
    and #1 u4(w1,p[0],c_in_initial);
    or #1 u5(c1,g[0],w1);

    //c2
    and #1 u6(w2,p[1],p[0],c_in_initial);
    and #1 u7(w3,p[1],g[0]);
    or #1 u8(c2,g[1],w2,w3);

    //c3
    and #1 u9(w4,p[2],p[1],p[0],c_in_initial);
    and #1 u10(w5,p[2],p[1],g[0]);
    and #1 u11(w6,p[2],g[1]);
    or #1 u12(c3,g[2],w4,w5,w6);

    //G
    and #1 u13(w11,p[3],p[2],p[1],g[0]);
    and #1 u14(w12,p[3],p[2],g[1]);
    and #1 u15(w13,p[3],g[2]);
    or #1 u16(G,g[3],w11,w12,w13);

    //P
    and #1 u17(P,p[3],p[2],p[1],p[0]);

endmodule

module four_bit_cla (a,b,c_in,sum,G,P);
    input [3:0] a,b;
    input c_in;
    output [3:0] sum;
    output G,P;

    wire [3:0] c,g,p;

    //instantiate one_bit_fa's
    one_bit_fa one_bit_fa_instance [3:0] (.a(a), .b(b), .c_in(c), .sum(sum));

    //instantiate gp_generate's
    gp_generate gp_generate_instace [3:0] (.a(a), .b(b), .g(g), .p(p));
    
    //instantiate grp_crry_la's
    grp_crry_la grp_crry_la_instance (.g(g), .p(p), .c_in(c[0]), .c1(c[1]), .c2(c[2]), .c3(c[3]), .G(G), .P(P));

    assign c[0] = c_in;

endmodule

module n_bit_cla
#(parameter integer WIDTH = 4)
(a,b,c_in_initial,sum,c_out_final);

    input [WIDTH-1:0] a,b;
    input c_in_initial;
    output [WIDTH-1:0] sum;
    output c_out_final;

    wire [WIDTH/4:0] c;
    wire [(((1-4**((($clog2(WIDTH))/2)+1))/(1-4))-1)/4 - 1:0] G,P;

    //instantiate four_bit_cla's
    genvar i;
    generate
        for (i=0;i<WIDTH/4;i=i+1) begin
            four_bit_cla four_bit_cla_instance (
                .a(a[4*(i+1)-1:4*i]), .b(b[4*(i+1)-1:4*i]),
                .c_in(c[i]), .sum(sum[4*(i+1)-1:4*i]), .G(G[i]), .P(P[i])
            );
        end
    endgenerate

    //instantiate grp_crry_la's
    generate j,k;
    generate
        for (j=2;j <= WIDTH/4**j+1; ) begin
            for (k=0;k < WIDTH/4**j;j=j+1) begin
                grp_crry_la grp_crry_la_instance (
                    .g(G[k]), .p(P[k]), .c_in(c[4*k]), .c1(c[4*k+1]), .c2(c[4*k+2]), .c3(c[4*k+3]), .G(G[WIDTH/4+k]), .P(P[WIDTH/4+k])
                );
            end
        end
    endgenerate

    //instantiate top-most grp_crry_la
    grp_crry_la grp_crry_la_final (.g(G[(((1-4**((($clog2(WIDTH))/2)+1))/(1-4))-1)/4 - 2:(((1-4**((($clog2(WIDTH))/2)+1))/(1-4))-1)/4 - 5]),
                                    .p(P[(((1-4**((($clog2(WIDTH))/2)+1))/(1-4))-1)/4 - 2:(((1-4**((($clog2(WIDTH))/2)+1))/(1-4))-1)/4 - 5]),
                                    .c_in(c[0]), .c1(c[]), .c2(), .c3(),
                                    .G(G[(((1-4**((($clog2(WIDTH))/2)+1))/(1-4))-1)/4 - 1]), 
                                    .P(P[(((1-4**((($clog2(WIDTH))/2)+1))/(1-4))-1)/4 - 1])
                                );

    //wiring



endmodule

`ifdef tb

module n_bit_cla_tb;
    parameter integer WIDTH = 16;
    reg [WIDTH-1:0] a,b;
    reg c_in;
    wire c_out;
    wire [WIDTH-1:0] sum;

    n_bit_cla #(.WIDTH(WIDTH)) CLA1 (.a(a), .b(b), .c_in_initial(c_in), .sum(sum), .c_out_final(c_out));

    integer i;

    initial begin
        $dumpfile("n_bit_cla_tb.vcd");
        $dumpvars;

        for (i = 0; i < 16; i = i + 1) begin
            a[31:0] = $urandom;
            a[63:32] = $urandom;
            b[31:0] = $urandom;
            b[63:32] = $urandom;
            c_in = $urandom;
            #100
            if (a+b+c_in !== sum) begin
                $display("Incorrect sum!");
                $finish;
            end
        end
        $finish;
    end
endmodule//n_bit_cba_tb
`endif//`ifdef tb