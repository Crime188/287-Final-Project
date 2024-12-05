module BOARD_DRAWER (
    input clk,
    input rst,
    input [191:0]Board,
    output reg [14:0]the_vga_draw_frame_write_mem_address, // location to draw to.
    output reg [23:0]the_vga_draw_frame_write_mem_data, // color (8bit red, 8bit Green, 8bit Blue)
    output reg the_vga_draw_frame_write_a_pixel, // enable writing
    input enabled
);
// this Module Takes what Jameison did in the vgaDriverToFrameBuff
//, and rewrites it to be a FSM.

// It also finds when it is in the center of a square,
// and when it should draw if it needs to. THIS DOES NOT WORK CURRENTLY

reg [3:0]S;
reg [3:0]NS;

reg [14:0]IDX; // Index to Write to.


parameter START = 4'd0,
    SET_ADDRESS = 4'd1,
    CONVERT_IDX = 4'd2,
    SET_COLOR = 4'd3,
    ENABLE_WRITE = 4'd4,
    DISABLE_WRITE = 4'd5,
    IDX_UP = 4'd6,
    CHECK_COLOR = 4'd7,
	 WAIT = 4'd8;

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
        START : NS = SET_ADDRESS;
		  SET_ADDRESS : NS = CONVERT_IDX;
        CONVERT_IDX : NS = CHECK_COLOR;
        CHECK_COLOR : NS = SET_COLOR;
        SET_COLOR : begin
            if ((enabled)) // CURRENRTLY NOT IMMPLEMETED: will check if it is in the center a square and is able to be written
                NS = ENABLE_WRITE;
            else begin
                if (IDX != 0) //CURRENTLY NOT IMPLEMENTED: check to see if this location needs to be written to.
                    NS = SET_COLOR; // so it will try to write again next clock cycle
                else
                    NS = IDX_UP; // itterate the IDX to try to find a working 
            end
                end
        ENABLE_WRITE : NS = WAIT;
        WAIT : begin
		  if (counter >= 2)
			NS = DISABLE_WRITE;
		  else
			NS = WAIT;
		  end
		  DISABLE_WRITE : NS = IDX_UP;
        IDX_UP : NS = SET_ADDRESS;
    endcase
end
reg [23:0] color;


getStatus g1 (
X,
Y,
Board,
status
);

wire [2:0] Piece;

assign Piece = status;

reg [3:0] X; // these are Board Coords
reg [3:0] Y; // these are Board Coords

reg [14:0] counter;

// contorl signals
always @(posedge clk or negedge rst) begin
    if (rst == 1'b0) begin
		IDX <= 15'd0; // default to top left
        color <= 24'hFFFFFF; // default to white
        the_vga_draw_frame_write_mem_address <= 15'd0; // top Left of Board
		the_vga_draw_frame_write_mem_data <= 24'd0; // Color In HEX
		the_vga_draw_frame_write_a_pixel <= 1'b0; // Disable by Default
		counter <= 6'd0;
	end
    else begin
        case (S)
            START : begin
                color <= 24'hffffff; // set it to wight
                the_vga_draw_frame_write_a_pixel <= 1'b0;
                IDX <= 15'd0; // default to top left
            end
            SET_ADDRESS : begin
                the_vga_draw_frame_write_mem_address <= IDX;
            end
            CONVERT_IDX : begin // not so sure about this one
                Y <= (IDX / 120); 
                X <= (IDX % 120) / 15; 
            end
            SET_COLOR : begin
                case (Piece)
                    3'b000: color <= 24'hFFFFFF; // blank - white 
                    3'b001: color <= 24'h98f5f9; // Player 1 Piece
                    3'b010: color <= 24'hfe5c5e; // Player 2 Piece
                    3'b101: color <= 24'h3f97fc; // Player 1 King
                    3'b110: color <= 24'hd80305; // Player 2 King
                    3'b111: color <= 24'h000000; // Blank Black
                    default : color <= 24'h123123; // Blackish // SOMTHING BAD HAPPEND
                endcase
            end
            CHECK_COLOR : begin
                the_vga_draw_frame_write_mem_data <= color;
            end
            ENABLE_WRITE : begin
					the_vga_draw_frame_write_a_pixel <= 1'b1;
                    counter <= 6'd0;
            end
            WAIT : counter <= counter + 6'd1;
            DISABLE_WRITE : begin
                the_vga_draw_frame_write_a_pixel <= 1'b0;
            end
            IDX_UP : begin
                if (IDX > 15'd119) // need to be reset
                    IDX <= 15'd0;
                else
                    IDX <= IDX + 1 ;
            end
        endcase
    end
end


endmodule