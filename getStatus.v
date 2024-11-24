module getStatus(
    input [3:0] x_location,      // X-coordinate (1 to 8)
    input [3:0] y_location,      // Y-coordinate (1 to 8)
    input [191:0] BoardState,    // 192-bit Board state
    output reg [2:0] status      // 3-bit status
);
    
    // Calculate the bit offset based on the x_location and y_location
    wire [5:0] index = (y_location - 1) * 8 + (x_location - 1);  // 0-based index for (x, y)

    always @(*) begin
        // Use the index to extract the corresponding 3 bits from the BoardState
        status = BoardState[index*3 +: 3]; // Extract 3 bits starting from the index*3
    end
    
endmodule