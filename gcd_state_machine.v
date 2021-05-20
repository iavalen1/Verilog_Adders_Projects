`timescale 1 ns / 1 ns

module gcd_DP
#(parameter integer WIDTH = 4)
(clk,reset,x_sel,y_sel,x_ld,y_ld,d_ld,X,Y,x_neq_y,x_lt_y,d_o);

    //Variables
    input clk,reset,x_sel,y_sel,x_ld,y_ld,d_ld;
    input [WIDTH-1:0] X,Y;
    output x_neq_y,x_lt_y;
    output reg [WIDTH-1:0] d_o;

    reg [WIDTH-1:0] next_X,next_Y,QX,QY;
    wire [WIDTH-1:0] XminusY,YminusX;

    always @(posedge clk, posedge reset)
    begin
        if (reset)
            QX <= {(WIDTH){1'b0}};
        else
            QX <= x_ld ? next_X : QX;
    end

    always @(posedge clk, posedge reset)
    begin
        if (reset)
            QY <= {(WIDTH){1'b0}};
        else
            QY <= y_ld ? next_Y : QY;
    end

    assign x_neq_y = QX != QY;
    assign x_lt_y = QX < QY;
    assign XminusY = QX - QY;
    assign YminusX = QY - QX;

    always @(*)
    begin
        next_X = x_sel ? XminusY: X;
        next_Y = y_sel ? YminusX: Y;
    end

    always @(posedge clk)
        d_o <= d_ld ? QX : d_o;

endmodule

module gcd_ctrl
(clk,reset,go_i,x_neq_y,x_lt_y,x_sel,y_sel,x_ld,y_ld,d_ld);

    //Variables
    input clk,reset,go_i,x_neq_y,x_lt_y;
    output reg x_sel,y_sel,x_ld,y_ld,d_ld;

    reg [3:0] state,next_state;

    //state assignment
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
    parameter S11 = 4'b1011;
    parameter S12 = 4'b1100;

    //state register

    always @(posedge clk, posedge reset)
    begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    always@(*)
    begin
        case (state)
            S0: next_state = S1;
            S1: next_state = ~go_i ? S2 : S3;
            S2: next_state = S1;
            S3: next_state = S4;
            S4: next_state = S5;
            S5: next_state = x_neq_y ? S6 : S11;
            S6: next_state = x_lt_y ? S7 : S8;
            S7: next_state = S9;
            S8: next_state = S9;
            S9: next_state = S10;
            S10: next_state = S5;
            S11: next_state = S12;
            S12: next_state = S0;
            default: next_state = S0;
        endcase // case (state)
    end // always @(*)

    //define the controller's outputs

    always @(*)
    begin
        x_sel = (state == S8) ? 1'b1 : 1'b0;
        y_sel = (state == S7) ? 1'b1 : 1'b0;
        x_ld = (state == S3 | state == S8) ? 1'b1 : 1'b0;
        y_ld = (state == S4 | state == S7) ? 1'b1 : 1'b0;
        d_ld = (state == S11) ? 1'b1 : 1'b0;
    end

endmodule // gcd_ctrl

`ifdef tb

module gcd_tb;

    //Variables
    parameter integer WIDTH = 8;
    reg [WIDTH-1:0] X,Y;
    reg clk,reset,go_i;
    wire x_neq_y,x_lt_y,x_sel,y_sel,x_ld,y_ld,d_ld;
    wire [WIDTH-1:0] d_o;

    integer i;

    //Instantiating Data Path and Control Unit
    gcd_DP #(.WIDTH(WIDTH)) M(.clk(clk), .reset(reset), .x_sel(x_sel), .y_sel(y_sel),
                                .x_ld(x_ld), .y_ld(y_ld), .d_ld(d_ld), .X(X), .Y(Y),
                                .x_neq_y(x_neq_y), .x_lt_y(x_lt_y), .d_o(d_o));
    gcd_ctrl N(.clk(clk), .reset(reset), .go_i(go_i), .x_neq_y(x_neq_y),
                .x_lt_y(x_lt_y), .x_sel(x_sel), .y_sel(y_sel), .x_ld(x_ld),
                .y_ld(y_ld), .d_ld(d_ld));

    //Initialize Variables
    initial begin
        reset = 0;
        clk = 0;
        go_i = 1;
    end

    //Stuff that I don't know the reason for doing but I know I have to do it or nothing will work
    initial begin
        $dumpfile("gcd_tb.vcd");
        $dumpvars;
    end

    //Clock
    always
        #1 clk = ! clk;

    //Testbench Body
    initial begin
        for (i=0; i<4; i=i+1) begin
            X = $urandom;
            Y = $urandom;
            #1000;
        end
        $finish;
    end

endmodule
`endif