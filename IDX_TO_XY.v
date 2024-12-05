module IDX_TO_XY (
input [14:0]idx,
output reg [3:0]x_location,
output reg [3:0]y_location
);

always @(*) begin
    x_location = 8;
    y_location = 8;
end
endmodule