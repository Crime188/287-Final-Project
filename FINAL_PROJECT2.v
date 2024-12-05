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

wire [191:0] BOARD;
assign BOARD = 192'b000010000010000010000010010000010000010000010000000010000010000010000010111000111000111000111000000111000111000111000111001000001000001000001000000001000001000001000001001000001000001000001000;


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


parameter MEMORY_SIZE = 16'd19200; // 160*120 // Number of memory spots ... highly reduced since memory is slow
parameter PIXEL_VIRTUAL_SIZE = 16'd4; // Pixels per spot - therefore 4x4 pixels are drawn per memory location

//* ACTUAL VGA RESOLUTION *
parameter VGA_WIDTH = 16'd640; 
parameter VGA_HEIGHT = 16'd480;

// Our reduced RESOLUTION 160 by 120 needs a memory of 19,200 words each 24 bits wide *
parameter VIRTUAL_PIXEL_WIDTH = VGA_WIDTH/PIXEL_VIRTUAL_SIZE; // 160
parameter VIRTUAL_PIXEL_HEIGHT = VGA_HEIGHT/PIXEL_VIRTUAL_SIZE; // 120

wire [14:0]address;
wire [23:0]data;
wire pixel;


// instatiate the Board Drawer
BOARD_DRAWER draw1(
    clk,
    rst,
    BOARD,
    address,
    data,
    pixel,
	 active_pixels
);

always@(*) begin
the_vga_draw_frame_write_mem_address = address;
the_vga_draw_frame_write_mem_data = data;
the_vga_draw_frame_write_a_pixel = pixel;
end
endmodule

