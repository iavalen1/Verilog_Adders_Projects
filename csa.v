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

module four_bit_csa (a,b,c_in_initial,sum,c_out_final);
    input [3:0] a,b;
    input c_in_initial;
    output [3:0] sum;
    output reg c_out_final;

    wire [3:0] zero_c_in,zero_c_out,one_c_in,one_c_out;

    one_bit_csa M[3:0] (.a(a), .b(b), .c_in_initial(c_in_initial), 
                        .zero_c_in(zero_c_in),.one_c_in(one_c_in), 
                        .sum(sum), .zero_c_out(zero_c_out), .one_c_out(one_c_out));
    
    assign zero_c_in[0] = 1'b0;
    assign one_c_in[0] = 1'b1;

    assign zero_c_in[3:1] = zero_c_out[2:0];
    assign one_c_in[3:1] = one_c_out[2:0];

    //MUX
    always @(c_in_initial or zero_c_out[3] or one_c_out[3]) begin
        #1
        if (c_in_initial == 0)
            c_out_final = zero_c_out[3];
        if (c_in_initial == 1)
            c_out_final = one_c_out[3];
    end

endmodule//four_bit_csa

module n_bit_csa 
#(parameter integer WIDTH = 4)
(a,b,c_in_initial,sum,c_out_final);
    input [WIDTH - 1:0] a,b;
    input c_in_initial;
    output [WIDTH - 1:0] sum;
    output c_out_final;

    wire [WIDTH/4 - 1:0] c_in,c_out;

    //Instantiate Modules
    genvar i;
    generate
        for (i=0; i<(WIDTH/4); i=i+1) begin
            four_bit_csa Ni(.a(a[4*(i+1)-1:4*i]), .b(b[4*(i+1)-1:4*i]), .c_in_initial(c_in[(4*i)/4]),
                            .sum(sum[4*(i+1)-1:4*i]), .c_out_final(c_out[(4*i)/4]));
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

endmodule//n_bit_csa

`ifdef tb

module n_bit_csa_tb;
    parameter integer WIDTH = 64;
    reg [WIDTH-1:0] a,b;
    reg c_in;
    wire c_out;
    wire [WIDTH-1:0] sum;

    n_bit_csa #(.WIDTH(WIDTH)) CSA1(.a(a), .b(b), .c_in_initial(c_in), .sum(sum), .c_out_final(c_out));

    integer i;

    initial begin
        $dumpfile("n_bit_csa_tb.vcd");
        $dumpvars;

        for (i = 0; i < 16; i = i + 1) begin
            a[31:0] = $urandom;
            a[63:32] = $urandom;
            b[31:0] = $urandom;
            b[63:32] = $urandom;
            c_in = $urandom;
            #(8 + (WIDTH/4));
            if (a+b+c_in !== sum) begin
                $display("Incorrect sum!");
                $finish;
            end
        end
        $finish;
    end
endmodule//n_bit_cba_tb
`endif//`ifdef tb