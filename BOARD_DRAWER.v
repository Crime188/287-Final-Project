module BOARD_DRAWER (
    input clk,
    input rst,
    input [191:0]Board,
    output reg [14:0]the_vga_draw_frame_write_mem_address, // location to draw to.
    output reg [23:0]the_vga_draw_frame_write_mem_data, // color (8bit red, 8bit Green, 8bit Blue)
    output reg the_vga_draw_frame_write_a_pixel, // enable writing
    input x,
    input y,
    input active_pixels;
);
// this Module Takes what Jameison did in the vgaDriverToFrameBuff
//, and rewrites it to be a FSM.

// It also finds when it is in the center of a square,
// and when it should draw if it needs to. THIS DOES NOT WORK CURRENTLY

reg [2:0]S;
reg [2:0]NS;

reg [14:0] IDX;


parameter START = 3'd0,
    Check_Status = 3'd1,
    Check_0 = 3'd2,
    Color = 3'd3,
    Itter = 3'd4;

// S update Block
always @(posedge clk or negedge rst)
begin
	if (rst == 1'b0)
		S <= START;
	else
		S <= NS;
end

/* NS transitions always block */
always @(*) begin
    case (S)
        START: NS = Check_Status;
        Check_Status: begin
            // Example: Checking horizontal center (magic numbers for position)
            if ((x % 15 >= 6) && (x % 15 <= 9) && (active_pixels)) // Center of a line
                NS = Check_0;
            else
                NS = Itter;
        end
        Check_0: begin
            // Example: Check for center of a 2D grid
            if ((y % 15 >= 6) && (y % 15 <= 9) && (active))
				//if ((IDX / 240) > 10)
                NS = Color;
            else
                NS = Itter;
        end
        Itter: NS = Check_Status;
    endcase
end


reg [2:0]status;

getStatus statusGetter(X,Y,Board,ST);

// contorl singlas
always @(posedge clk or negedge rst) begin
    if (rst == 1'b0) begin
		IDX <= 15'd0 ;
      the_vga_draw_frame_write_mem_address <= 15'd0 ;
		the_vga_draw_frame_write_mem_data <= 24'd0 ;
		the_vga_draw_frame_write_a_pixel <= 1'b0 ;
      status <= 3'b111 ; // default to black
	end
    else begin
        case (S)
            START : begin
                IDX <= 15'd0;
                the_vga_draw_frame_write_mem_address <= 15'd0;
                the_vga_draw_frame_write_mem_data <= 24'd0;
                the_vga_draw_frame_write_a_pixel <= 1'b0;
                status <= 3'b100;
            end
            Check_Status : begin
                status <= ST;
            end
            Check_0 : begin
                case (ST)
                    3'b000 : the_vga_draw_frame_write_mem_data <= 24'hFFFFFF; // white
                    3'b001 : the_vga_draw_frame_write_mem_data <= 24'h98F5F9; // Player 1 Piece (tuqouies)
                    3'b010 : the_vga_draw_frame_write_mem_data <= 24'hFE5C5E; // Player 2 piece (pink)
                    3'b101 : the_vga_draw_frame_write_mem_data <= 24'h3F97FC; // Player 1 King (Blue)
                    3'b110 : the_vga_draw_frame_write_mem_data <= 24'hD80305; // Player 2 King (RED)
                    3'b111 : the_vga_draw_frame_write_mem_data <= 24'h000000; // Black
                    default: the_vga_draw_frame_write_mem_data <= 24'h123123; // Blackish
                endcase
            end
            Color : begin
                the_vga_draw_frame_write_mem_address <= IDX;
                the_vga_draw_frame_write_a_pixel <= 1'b1;
            end
            Itter : begin
                the_vga_draw_frame_write_a_pixel <= 1'b0;
                
                if (IDX > 15'd14400)
                    IDX <= 0;
                else
                    IDX <= IDX + 15'd1;
            end
        endcase
    end
end


endmodule