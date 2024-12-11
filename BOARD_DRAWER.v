module BOARD_DRAWER (
    input clk,
    input rst,
    input [191:0]Board,
    output reg [14:0]the_vga_draw_frame_write_mem_address, // location to draw to.
    output reg [23:0]the_vga_draw_frame_write_mem_data, // color (8bit red, 8bit Green, 8bit Blue)
    output reg the_vga_draw_frame_write_a_pixel, // enable writing
    input enabled,
	 input [9:0]yCordEx
);
// this Module Takes what Jameison did in the vgaDriverToFrameBuff
//, and rewrites it to be a FSM.

// It also finds when it is in the center of a square,
// and when it should draw if it needs to. THIS DOES NOT WORK CURRENTLY

reg [3:0]S;
reg [3:0]NS;

reg [14:0]IDX; // Index to Write to.
reg [23:0] color;
wire [2:0] status;

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
                if (enabled) //CURRENTLY NOT IMPLEMENTED: check to see if this location needs to be written to.
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



getStatus g1 (
	.x_location(X),
	.y_location(Y),
   .BoardState(Board),
   .status(status)
);

reg [3:0] X; // these are Board Coords
reg [3:0] Y; // these are Board Coords

reg [10:0] Y_step;

reg [14:0] counter;

// contorl signals
always @(posedge clk or negedge rst) begin
    if (rst == 1'b0) begin
		IDX <= 15'd0; // default to top left
        //color <= 24'hFFFFFF; // default to white
        the_vga_draw_frame_write_mem_address <= 15'd0; // top Left of Board
		the_vga_draw_frame_write_mem_data <= 24'd0; // Color In HEX
		the_vga_draw_frame_write_a_pixel <= 1'b0; // Disable by Default
		counter <= 6'd0;
		X <= 7;
		Y <= 7;
	end
    else begin
        case (S)
            START : begin
                //color <= 24'hffffff; // set it to wight
                the_vga_draw_frame_write_a_pixel <= 1'b0;
                IDX <= 15'd0; // default to top left
            end
            SET_ADDRESS : begin
                the_vga_draw_frame_write_mem_address <= IDX;
					 Y_step <= IDX % 120;
            end
            CONVERT_IDX : begin // this is the worst way to do this but it is functional.

					// This tree is for finding out the y cord from IDX.
					if (Y_step < 15) begin
						Y <= 0;
						end
					else 
						if (Y_step > 14 && Y_step < 30) begin
							Y <= 1;
							end
						else
							if (Y_step > 29 && Y_step < 45) begin
								Y <= 2;
								end
							else
								if (Y_step > 44 && Y_step < 60) begin
									Y <= 3;
									end
								else
									if (Y_step > 59 && Y_step < 75) begin
										Y <= 4;
										end
									else
										if (Y_step > 74 && Y_step < 90) begin
											Y <= 5;
											end
										else
											if (Y_step > 89 && Y_step < 105) begin
												Y <= 6;
												end
											else begin
												Y <= 7;
												end
					
					
					// this tree finds out the x cord from IDX.
					if (IDX < 1801) begin
						X <= 0;
						end
					else 
						if (IDX > 1800 && IDX < 3601) begin
							X <= 1;
							end
						else
							if (IDX > 3600 && IDX < 5401) begin
								X <= 2;
								end
							else
								if (IDX > 5400 && IDX < 7201) begin
									X <= 3;
									end
								else
									if (IDX > 7200 && IDX < 9001) begin
										X <= 4;
										end
									else
										if (IDX > 9000 && IDX < 10801) begin
											X<= 5;
											end
										else
											if (IDX > 10800 && IDX < 12601) begin
												X<= 6;
												end
											else begin
												X<= 7;
												end 
            end
            SET_COLOR : begin
               // this is a tree to determain the st.
					case (status)
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
                if (IDX > 15'd14400) // need to be reset
                    IDX <= 15'd0;
                else
                    IDX <= IDX + 15'd1 ;
            end
        endcase
    end
end


endmodule