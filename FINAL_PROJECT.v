module FINAL_PROJECT ( 
    ////////////// CLOCK //////////
    input             CLOCK_50,        // 50 MHz clock
    ////////////// SEG7 //////////
    output [6:0]      HEX0,           // 7-segment display 0
    output [6:0]      HEX1,           // 7-segment display 1
    output [6:0]      HEX2,           // 7-segment display 2
    output [6:0]      HEX3,           // 7-segment display 3 (negative sign)
    ////////////// KEY //////////
    input [3:0]       KEY,            // 4 keys for control
    ////////////// LED //////////
    output [9:0]      LEDR,           // LEDs
    ////////////// SW //////////
    input [9:0]       SW              // Switches
);

wire [191:0] BOARD;
assign BOARD = 192'b000010000010000010000010010000010000010000010000000010000010000010000010111000111000111000111000000111000111000111000111001000001000001000001000000001000001000001000001001000001000001000001000;


wire [6:0] seg7_neg_sign;
wire [6:0] seg7_dig0;
wire [6:0] seg7_dig1;
wire [6:0] seg7_dig2;

assign LEDR[9:6] = Disired_X;          // Desired X-coordinate
assign LEDR[5:2] = Disired_Y;          // Desired Y-coordinate

assign HEX0 = seg7_dig0;               // 7-segment display for digit 0
assign HEX1 = seg7_dig1;               // 7-segment display for digit 1
assign HEX2 = seg7_dig2;               // 7-segment display for digit 2 (constant 0)
assign HEX3 = seg7_neg_sign;           // Negative sign indicator

// Instance for display conversion (converts status to 7-segment display)
three_decimal_vals_w_neg display(
    status,
    seg7_neg_sign,
    seg7_dig0,
    seg7_dig1,
    seg7_dig2
);
reg [3:0] Disired_X;   // X-coordinate (4 bits for 1-8)
reg [3:0] Disired_Y;   // Y-coordinate (4 bits for 1-8)
reg en;                 // Enable signal for getting status

wire [2:0] status;     // Status of the cell at (Disired_X, Disired_Y)

// Instantiate getStatus module to fetch the cell status from the BoardState
getStatus g1 (
    .x_location(Disired_X),
    .y_location(Disired_Y),
    .BoardState(BOARD),
    .status(status)
);
always @(*) begin
    Disired_X = SW[9:7] + 1;
    Disired_Y = SW[2:0] + 1;
end
endmodule