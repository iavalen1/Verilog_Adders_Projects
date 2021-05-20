`timescale 1 ns / 1ns

module one_counter
#(parameter integer N = 0)
(x_in,reset,clk,RD,ST,one_count);

    //Variable Decleration
    input [N-1:0] x_in;
    input reset,clk,RD,ST;
    output integer one_count;

    //Signal Declecration
    reg [N-1:0] X;
    reg [3:0] state,next_state;

    //State Assignment
    parameter S0 = 4'b0000;
    parameter S1 = 4'b0001;
    parameter S2 = 4'b0010;
    parameter S3 = 4'b0011;
    parameter S4 = 4'b0100;
    parameter S5 = 4'b0101;
    parameter S6 = 4'b0110;
    parameter S7 = 4'b0111;
    parameter S8 = 4'b1000;
    parameter S9 = 4'b1001;
    parameter S10 = 4'b1010;

    //State Register
    always @(posedge clk, posedge reset) 
    begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    //Next State Logic
    always @(*)
    begin
        case (state)
            S0: next_state <= RD ? S1 : S0;
            S1: next_state <= ~ST ? S2 : S3;
                next_state <= S3;
            S2: next_state <= S1;
            S3: next_state <= S4;
            S4: next_state <= S5;
            S5: next_state <= (X !== 0) ? S6: S9;
            S6: next_state <= S7;
            S7: next_state <= S8;
            S8: next_state <= S5;
            S9: next_state <= S10;
            S10: next_state <= S0;
            default: next_state <= S0;
        endcase
    end

    //Ouput Logic
    always @(*)
    begin
        if (state == S3)
            X = x_in;
        if (state == S4)
            one_count = 0;
        if(state == S6)
            X = X & (X-1);
        if (state == S7)
            one_count = one_count + 1;
    end

endmodule

`ifdef tb

module one_counter_tb;

    //Variables
    parameter integer N = 4;
    reg [N-1:0] x_in;
    reg reset,clk,RD,ST;
    wire integer one_count;


    //Module Instantiation
    one_counter #(.N(N)) instance1 (.x_in(x_in), .reset(reset), .clk(clk), .RD(RD), .ST(ST), .one_count(one_count));

    //Initialize Variables
    initial
    begin
        reset = 0;
        clk = 0;
        RD = 1;
        ST = 0;
    end

    initial
    begin
        $dumpfile("one_counter_tb.vcd");
        $dumpvars;
    end

    //Clock
    always
        #1 clk = !clk;

    //Testbench Body
    initial
    begin
        ST <= 1;
        #5 ST <= 0;
        x_in <= 4'b1010;
        wait(one_count == 2);
        $finish;
    end


endmodule
`endif