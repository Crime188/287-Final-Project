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
    input [9:0]       SW,              // Switches

    //VGA
    output		          		VGA_BLANK_N,
	output		     [7:0]		VGA_B,
	output		          		VGA_CLK,
	output		     [7:0]		VGA_G,
	output		          		VGA_HS,
	output		     [7:0]		VGA_R,
	output		          		VGA_SYNC_N,
	output		          		VGA_VS


    
);

reg [191:0] BOARD;


// BEGIN THE VGA STUFF
wire clk;
wire rst;

assign clk = CLOCK_50;
assign rst = KEY[0];


// VGA DRIVER
wire active_pixels; // is on when we're in the active draw space
wire frame_done;
wire [9:0]x; // current x
wire [9:0]y; // current y - 10 bits = 1024 ... a little bit more than we need

// the 3 signals to set to write to the picture *
reg [14:0] the_vga_draw_frame_write_mem_address;
reg [23:0] the_vga_draw_frame_write_mem_data;
reg the_vga_draw_frame_write_a_pixel;    

// This is the frame driver point that you can write to the draw_frame *
vga_frame_driver my_frame_driver(
	.clk(clk),
	.rst(rst),

	.active_pixels(active_pixels),
	.frame_done(frame_done),

	.x(x),
	.y(y),

	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.VGA_HS(VGA_HS),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_VS(VGA_VS),
	.VGA_B(VGA_B),
	.VGA_G(VGA_G),
	.VGA_R(VGA_R),

	// writes to the frame buf - you need to figure out how x and y or other details provide a translation *
	.the_vga_draw_frame_write_mem_address(the_vga_draw_frame_write_mem_address),
	.the_vga_draw_frame_write_mem_data(the_vga_draw_frame_write_mem_data),
	.the_vga_draw_frame_write_a_pixel(the_vga_draw_frame_write_a_pixel)
);

//reg [15:0]i;
//reg [7:0]S;
//reg [7:0]NS;
// parameter 
// 	START 			= 8'd0,
// 	// W2M is write to memory
// 	W2M_INIT 		= 8'd1,
// 	W2M_COND 		= 8'd2,
// 	W2M_INC 			= 8'd3,
// 	W2M_DONE 		= 8'd4,
// 	// The RFM = READ_FROM_MEMOERY reading cycles
// 	RFM_INIT_START = 8'd5,
// 	RFM_INIT_WAIT 	= 8'd6,
// 	RFM_DRAWING 	= 8'd7,
// 	ERROR 			= 8'hFF;

// parameter MEMORY_SIZE = 16'd19200; // 160*120 // Number of memory spots ... highly reduced since memory is slow
// parameter PIXEL_VIRTUAL_SIZE = 16'd4; // Pixels per spot - therefore 4x4 pixels are drawn per memory location

// //* ACTUAL VGA RESOLUTION *
// parameter VGA_WIDTH = 16'd640; 
// parameter VGA_HEIGHT = 16'd480;

// // Our reduced RESOLUTION 160 by 120 needs a memory of 19,200 words each 24 bits wide *
// parameter VIRTUAL_PIXEL_WIDTH = VGA_WIDTH/PIXEL_VIRTUAL_SIZE; // 160
// parameter VIRTUAL_PIXEL_HEIGHT = VGA_HEIGHT/PIXEL_VIRTUAL_SIZE; // 120

wire [14:0] adrr;
wire [23:0] framedraw;
wire en;

assign LEDR = adrr;
// BOARD DRAWER INSTYANTIATION
BOARD_DRAWER b1(
    clk,
    rst,
    BOARD,
    adrr,
    framedraw,
    en,
    enabled
	);

	wire enabled;
	assign enabled = !KEY[1] || up; // thinking about adding in Hysn and Vsysn but nto sure.

	reg up;

always@(*) begin
the_vga_draw_frame_write_mem_address = adrr;
the_vga_draw_frame_write_mem_data = framedraw;
the_vga_draw_frame_write_a_pixel = en;    
end


wire [6:0] seg7_neg_sign;
wire [6:0] seg7_dig0;
wire [6:0] seg7_dig1;
wire [6:0] seg7_dig2;

assign HEX0 = seg7_dig0;               // 7-segment display for digit 0
assign HEX1 = seg7_dig1;               // 7-segment display for digit 1
assign HEX2 = seg7_dig2;               // 7-segment display for digit 2 
assign HEX3 = seg7_neg_sign;           // Negative sign indicator


// Instance for display conversion (converts status to 7-segment display)
three_decimal_vals_w_neg display(
    Curr_Player_Turn,
    seg7_neg_sign,
    seg7_dig0,
    seg7_dig1,
    seg7_dig2
);

reg start_move;
//reg [3:0] x1_location;
//reg [3:0] x2_location;
//reg [3:0] y1_location;
//reg [3:0] y2_location;

wire move_done;
wire [191:0] updated_board;
reg Curr_Player_Turn;
wire corrected_Player_Turn;

// Instanciate the Piece Mover
PIECE_MOVER p1(
    clk,
    rst,                     // Reset signal for FSM
    start_move,              // Trigger for starting a new move
    BOARD,      // Current Board state
	Curr_Player_Turn, // the current player's turn
	x1,       // Source X-coordinate
    y1,       // Source Y-coordinate
    x2,       // Destination X-coordinate
    y2,       // Destination Y-coordinate
    updated_board, // Updated Board state
	corrected_Player_Turn, // the correct Player turn after the Move has been Done
    move_done               // Move completion signal
);



// Instantiate the Selector, and give it its own reset signal.

wire [3:0] num;
assign num = SW[3:0];

wire [3:0] x1;
wire [3:0] y1;
wire [3:0] x2;
wire [3:0] y2;
wire Selector_done;

reg s_rst;

wire submit;
assign submit = !KEY[3];


selector s1(
    clk, // clock
    s_rst, // reset signal
    submit, // submiting Button
    num, // number to submit 
    x1, // 
    y1,
    x2,
    y2,
    Selector_done
);

// FSM TIME

reg [3:0] S;
reg [3:0] NS;

parameter StartState = 4'b0000 ,
	RUN_SELECTOR = 4'b0001,
	WAIT_SELECTOR = 4'b0011,
	RUN_PIECE_MOVER = 4'b0100,
	WAIT_MOVE = 4'b0101,
	UPDATE_BOARD = 4'b0110,
	DRAW_BOARD = 4'b0111,
	WAIT_DRAW = 4'b1000,
	DRAW_DONE = 4'b1001;

// S Transition
always @(posedge clk or negedge rst) begin
	if (rst == 0)
		S <= StartState;
	else 
		S <= NS;
end

reg [20:0] wait_Counter;

// NS Transition Block
always @(*) begin
	case (S)
		StartState : NS = RUN_SELECTOR;
		RUN_SELECTOR : NS = WAIT_SELECTOR;
		WAIT_SELECTOR : begin
			if (Selector_done)
				NS = RUN_PIECE_MOVER;
			else
				NS = WAIT_SELECTOR;
		end
		RUN_PIECE_MOVER : NS = WAIT_MOVE;
		WAIT_MOVE : begin
			if (move_done)
				NS = UPDATE_BOARD;
			else
				NS = WAIT_MOVE;
		end
		UPDATE_BOARD : NS = DRAW_BOARD;
		DRAW_BOARD : NS = WAIT_DRAW;
		WAIT_DRAW : begin
			if (wait_Counter > 20'd900000)
				NS = DRAW_DONE;
			else
				NS = WAIT_DRAW;
		end
		DRAW_DONE : NS = StartState;
		default: NS = StartState;
	endcase
end
// Logic One
always @(posedge clk or negedge rst) begin
	if (rst == 1'b0) begin
		// Default Board State.
		s_rst <= 0; // reset the Selector
		start_move <= 0; // make sure that the move is disabled
		up <= 0;
		Curr_Player_Turn <= 1; // default to player 1
		BOARD <= 192'b000010000010000010000010010000010000010000010000000010000010000010000010111000111000111000111000000111000111000111000111001000001000001000001000000001000001000001000001001000001000001000001000;
	end
	else begin
		case (S)
			StartState : begin
				s_rst <= 0; // reset the Selector
			end
			RUN_SELECTOR : begin
				s_rst <= 1; // allow the Selector to run.
			end
			WAIT_SELECTOR : start_move <= 0; // Make sure the move is disabled
			RUN_PIECE_MOVER : start_move <= 1; // start the Move
			WAIT_MOVE : start_move <= 0; // stop the move.
			UPDATE_BOARD : begin
				BOARD <= updated_board;
				Curr_Player_Turn <= corrected_Player_Turn;
			end
			DRAW_BOARD :begin
				up <= 1; // Start drawing the thing
				wait_Counter <= 0;
			end 
			WAIT_DRAW : wait_Counter <= wait_Counter +1;
			DRAW_DONE : up <= 0; // stop drawing
			default: up <= 0;
		endcase
	end
end
endmodule