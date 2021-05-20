`timescale 1 ns / 1 ns

module two_comp_subadder
#(parameter integer LENGTH = 4)
(x,y,c_in,sum);

    //Variables
    input [LENGTH-1:0] x,y;
    input c_in;
    output [LENGTH-1:0] sum;

    wire [LENGTH-1:0] final_x;

    assign final_x = x ^ {(LENGTH){c_in}};

    assign sum = final_x + y + c_in;

endmodule

module stage
#(parameter integer N=4,K=4)
(x,y,win,wout);

    //Variables
    input x;
    input [N-1:0] y;
    input [2*N-1:0] win;
    output [2*N-1:0] wout;

    wire co;

    assign wout[2*N-1:K] = {{(N-K) {y[N-1] & x}}, y & {(N){x}}} + win[2*N-1:K];
    assign wout [K-1:0] = win[K-1:0];
endmodule

module arrayMultiplier
#(parameter integer N=4)
(x,y,z);

    //Variables
    input [N-1:0] x,y;
    output [2*N-1:0] z;

    wire [2*N-1:0] wout [N-1:0];
    wire sc,co;
    wire [N-1:0] p,q;

    and u0[N-1:0] (wout[0][N-1:0],{(N){x[0]}},y);
    assign wout[0][2*N-1:N] = {(N){wout[0][N-1]}};

    genvar K;
    generate
        for (K=1;K<N;K=K+1) begin
            stage #(.N(N), .K(K)) stageK(.x(x[K]), .y(y), .win(wout[K-1][2*N-1:0]), .wout(wout[K][2*N-1:0]));
        end
    endgenerate

    assign p = {(N){x[N-1]}} & y;

    two_comp_subadder #(.LENGTH(N)) M(.x(p), .y(wout[N-1][2*N-1:N]), .c_in(x[N-1]), .sum(q));

    assign z = {q,wout[N-1][N-1:0]};

endmodule

`ifdef tb

module arrayMultiplier_tb;
    parameter integer WIDTH = 6;
    reg [WIDTH-1:0] x,y;
    wire [2*WIDTH-1:0] z;

    arrayMultiplier #(.N(WIDTH)) Q(.x(x), .y(y), .z(z));

    integer i;

    initial begin
        $dumpfile("arrayMultiplier.vcd");
        $dumpvars;

        y = 6'b000100;
        x = 6'b000010;
        #1;
        y = 6'b101010;
        x = 6'b000010;
        #1;
        y = 6'b000101;
        x = 6'b101010;
        #1;
        y = 6'b101010;
        x = 6'b101001;
        #1;
        $finish;
    end
endmodule
`endif