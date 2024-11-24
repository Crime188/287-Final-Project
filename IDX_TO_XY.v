module IDX_TO_XY (
input [14:0]idx,
output reg [3:0]x_location,
output reg [3:0]y_location
);

always @(*) begin
    x_location = (idx / 15'd15) + 1'd1;
    y_location = (idx / 15'd600) + 1'd1;
end
endmodule