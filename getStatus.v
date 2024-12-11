module getStatus(
    input [3:0] x_location,      // X-coordinate (0 to 7)
    input [3:0] y_location,      // Y-coordinate (0 to 7)
    input [191:0] BoardState,    // 192-bit Board state
    output reg [2:0] status      // 3-bit status
);
    
    // Calculate the bit offset based on the x_location and y_location
    reg [5:0] index;  // 0-based index for (x, y)
		reg [2:0] result;
always @(*) begin
	// index = (y_location) * 8 + (x_location);
	// Use the index to extract the corresponding 3 bits from the BoardState
	result = BoardState[((y_location) * 8 + (x_location))*3 +: 3]; // Extract 3 bits starting from the index*3
	status = result;
	
	end	
endmodule
