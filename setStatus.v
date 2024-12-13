module setStatus(
    input [3:0] x_location,      // X-coordinate (0 to 7)
    input [3:0] y_location,      // Y-coordinate (0 to 7)
    input [191:0] BoardState,    // Current 192-bit Board state
    input [2:0] new_status,      // 3-bit new status to be set
    output reg [191:0] updated_board // Updated 192-bit Board state
);
    
    // Calculate the bit offset based on the x_location and y_location
    reg [5:0] index;  // 0-based index for (x, y)
    
    always @(*) begin
        // Compute the index of the 3-bit section in the BoardState
        index = (y_location * 8 + x_location);  // This gives a 0-63 index for the 3-bit status
        
        // Directly update the 3 bits at the calculated index using bit shifts
        updated_board = BoardState;  // Start with the original board state
        
        // Shift the new status to the correct position (index * 3 bits)
        updated_board[(index * 3) +: 3] = new_status;  // Update the 3-bit section at the correct position
    end
endmodule
