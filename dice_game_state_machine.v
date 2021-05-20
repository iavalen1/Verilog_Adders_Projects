`timescale 1 ns / 1 ns

module counter
(clk,reset,roll_counter);

    //Variables
    input clk,reset;
    output reg [2:0] roll_counter;

    reg state,next_state;

    //State Assignment
    parameter S0 = 3'b000;
    parameter S1 = 3'b001;
    parameter S2 = 3'b010;
    parameter S3 = 3'b011;
    parameter S4 = 3'b100;
    parameter S5 = 3'b101;

    //State Register
    always @(posedge clk, posedge reset)
    begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    //Next State
    always @(*)
    begin
        case (state)
            S0: next_state = S1;
            S1: next_state = S2;
            S2: next_state = (roll_counter < 6) ? S3 : S5;
            S3: next_state = S4;
            S4: next_state = S2;
            S5: next_state = S0;
            default: next_state = S0;
        endcase
    end

    //Output
    always @(*)
    begin
        if(state == S1)
            roll_counter = 0;
        if(state == S3)
            roll_counter = roll_counter + 1;
    end

endmodule//counter

module dice_game_ctrl
(roll_button1,roll_button2,roll_counter1,roll_counter2,reset,clk,diceout1,diceout2,result,roll);
    
    //Variables
    input roll_button1,roll_button2,reset,clk;
    input [2:0] roll_counter1,roll_counter2;
    output reg [2:0] diceout1,diceout2;
    output reg roll,result;

    reg [3:0] sum;
    integer chances;
    reg [4:0] state,next_state;

    //State Assignment
    parameter S0 = 5'b00000;
    parameter S1 = 5'b00001;
    parameter S2 = 5'b00010;
    parameter S3 = 5'b00011;
    parameter S4 = 5'b00100;
    parameter S5 = 5'b00101;
    parameter S6 = 5'b00110;
    parameter S7 = 5'b00111;
    parameter S8 = 5'b01000;
    parameter S9 = 5'b01001;
    parameter S10 = 5'b01010;
    parameter S11 = 5'b01011;
    parameter S12 = 5'b01100;
    parameter S13 = 5'b01101;
    parameter S14 = 5'b01110;
    parameter S15 = 5'b01111;
    parameter S16 = 5'b10000;
    parameter S17 = 5'b10001;
    parameter S18 = 5'b10010;
    parameter S19 = 5'b10011;
    parameter S20 = 5'b10100;
    parameter S21 = 5'b10101;
    parameter S22 = 5'b10110;
    parameter S23 = 5'b10111;
    parameter S24 = 5'b11000;
    parameter S25 = 5'b11001;

    //State Register
    always @(posedge clk, posedge reset)
    begin
        if (reset)
            state <= S0;
        else
            state <= next_state;
    end

    //Next State
    always @(*)
    begin
        case (state)
            S0: next_state = S1;
            S1: next_state = S2;
            S2: next_state = S3;
            S3: next_state = (chances > 0) ? S4 : S23;
            S4: next_state = (roll_button1 == 0 || roll_button2 == 0) ? S5 : S6;
            S5: next_state = S4;
            S6: next_state = S7;
            S7: next_state = S8;
            S8: next_state = S9;
            S9: next_state = (sum == 2 || sum == 3 || sum == 12) ? S10 : S13;
            S10: next_state = S11;
            S11: next_state = S12;
            S12: next_state = S21;
            S13: next_state = (sum == 7 || sum == 11) ? S14 : S17;
            S14: next_state = S15;
            S15: next_state = S16;
            S16: next_state = S21;
            S17: next_state = (chances == 1 && (sum != 7 || sum != 11)) ? S18 : S20;
            S18: next_state = S19;
            S19: next_state = S21;
            S20: next_state = S21;
            S21: next_state = S22;
            S22: next_state = S3;
            S23: next_state = S0;
            default: next_state = S0;
        endcase
    end

    //Output
    always @(*)
    begin
        if(state == S1)
            chances = 3;
        if(state == S2)
            roll = 1;
        if(state == S6)
            diceout1 = roll_counter1;
        if(state == S7)
            diceout2 = roll_counter2;
        if(state == S8)
            sum = diceout1 + diceout2;
        if(state == S10)
            result = 0;
        if(state == S11)
            roll = 0;
        if(state == S12)
            chances = 0;
        if(state == S14)
            result = 1;
        if(state == S15)
            roll = 0;
        if(state == S16)
            chances = 0;
        if(state == S18)
            result = 0;
        if(state == S19)
            roll = 0;
        if(state == S20)
            chances = chances - 1;
    end

endmodule//dice_game_ctrl

`ifdef tb

module dice_game_ctrl_tb;

    //Variables
    reg roll_button1,roll_button2,clk,reset;
    reg [2:0] roll_counter1,roll_counter2;
    wire [2:0] diceout1,diceout2;
    wire result,roll;

    //Instantiate module
    counter counter1 (.clk(clk), .reset(reset), .roll_counter(roll_counter1));
    counter counter2 (.clk(clk), .reset(reset), .roll_counter(roll_counter2));
    
    dice_game_ctrl game1 (.roll_button1(roll_button1), .roll_button2(roll_button2),
                      .roll_counter1(roll_counter1), .roll_counter2(roll_counter2), 
                      .reset(reset), .clk(clk), .diceout1(diceout1),
                      .diceout2(diceout2), .result(result), .roll(roll));

    initial begin
        roll_button1 = 0;
        roll_button2 = 0;
        reset = 0;
        clk = 0;
    end

    always
        #1 clk = !clk;

    initial begin
        $dumpfile("dice_game_ctrl_tb.vcd");
        $dumpvars;
    end

    initial begin
        #3 roll_button1 = 1;
        $finish;
    end

endmodule
`endif