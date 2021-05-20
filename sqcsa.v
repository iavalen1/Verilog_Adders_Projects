`timescale 1 ns / 1 ns

module one_bit_fa (a,b,c_in,sum,c_out);
    input a,b,c_in;
    output sum,c_out;

    wire w1,w2,w3;

    //c_out
    and #1 u1(w1,a,b);
    and #1 u2(w2,a,c_in);
    and #1 u3(w3,b,c_in);
    or #1 u4(c_out,w1,w2,w3);

    //sum
    xor #1 u5(sum,a,b,c_in);

endmodule//one_fit_fa

module one_bit_csa (a,b,c_in_initial,zero_c_in,one_c_in,sum,zero_c_out,one_c_out);
    input a,b,c_in_initial,zero_c_in,one_c_in;
    output reg sum;
    output zero_c_out,one_c_out;

    wire zero_sum,one_sum;

    one_bit_fa zero_fa(.a(a), .b(b), .c_in(zero_c_in), .sum(zero_sum), .c_out(zero_c_out));

    one_bit_fa one_fa(.a(a), .b(b), .c_in(one_c_in), .sum(one_sum), .c_out(one_c_out));

    //MUX
    always @(c_in_initial or zero_sum or one_sum) begin
        #1
        if (c_in_initial == 1) begin
            sum = one_sum;
        end else begin
            sum = zero_sum;
        end
    end

endmodule//one_bit_csa

module n_bit_csa 
#(parameter integer MWIDTH = 4)
(a,b,c_in_initial,sum,c_out_final);
    input [MWIDTH - 1:0] a,b;
    input c_in_initial;
    output [MWIDTH - 1:0] sum;
    output reg c_out_final;

    wire [MWIDTH - 1:0] zero_c_in,zero_c_out,one_c_in,one_c_out;

    //Instantiate Modules
    one_bit_csa N[MWIDTH-1:0] (.a(a), .b(b), .c_in_initial(c_in_initial), .zero_c_in(zero_c_in), .one_c_in(one_c_in),
                                .sum(sum), .zero_c_out(zero_c_out), .one_c_out(one_c_out));

    assign zero_c_in[0] = 1'b0;
    assign one_c_in[0] = 1'b1;

    assign zero_c_in[MWIDTH-1:1] = zero_c_out[MWIDTH-2:0];
    assign one_c_in[MWIDTH-1:1] = one_c_out[MWIDTH-2:0];

    //MUX
    always @(c_in_initial or zero_c_out[3] or one_c_out[3]) begin
        #1
        if (c_in_initial == 0)
            c_out_final = zero_c_out[3];
        if (c_in_initial == 1)
            c_out_final = one_c_out[3];
    end

endmodule//n_bit_csa

module n_bit_sqcsa
#(parameter integer NWIDTH = 4)
(a,b,c_in_initial,sum,c_out_final);
    input [NWIDTH-1:0] a,b;
    input c_in_initial;
    output [NWIDTH-1:0] sum;
    output c_out_final;

    wire [NWIDTH/4 - 1:0] c_in,c_out;

    genvar i;
    generate
        for (i=2;(i**2 + i)/2 - 1 <= NWIDTH;i=i+1) begin
            n_bit_csa N[(i**2 + i)/2 - 2:((i-1)**2 + (i-1))/2 + -1] 
                (.a((i**2 + i)/2 - 2:((i-1)**2 + (i-1))/2 + -1), .b((i**2 + i)/2 - 2:((i-1)**2 + (i-1))/2 + -1),
                .c_in_initial(c_in_initial), .sum((i**2 + i)/2 - 2:((i-1)**2 + (i-1))/2 + -1),
                .c_out_final(c_out_final));
        end
    endgenerate

endmodule//n_bit_sqcsa