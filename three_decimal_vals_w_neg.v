module three_decimal_vals_w_neg (
input [3:0]val,
output [6:0]seg7_neg_sign,
output [6:0]seg7_dig0,
output [6:0]seg7_dig1,
output [6:0]seg7_dig2
);

reg [3:0] result_one_digit;
reg [3:0] result_ten_digit;
reg [3:0] result_hundred_digit;
reg result_is_negative;

/* convert the binary value into 4 signals */
always @(*) begin
	result_ten_digit = val[1];
	result_one_digit = val[0];
	result_hundred_digit = val[2];
end

/* instantiate the modules for each of the seven seg decoders including the negative one */
seven_segment dig2(result_hundred_digit,seg7_dig2);
seven_segment dig1(result_ten_digit,seg7_dig1);
seven_segment dig0(result_one_digit,seg7_dig0);
seven_segment_negative neg(result_is_negative,seg7_neg_sign);
endmodule