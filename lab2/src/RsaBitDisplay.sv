// This file take the input i_RSA_bit and current state and then determine the display number

module RsaBitDisplay (
	input        [9:0] i_RSA_bit,
	input        [1:0] curr_state,
	output logic [6:0] o_hex_7,
	output logic [6:0] o_hex_6,
   output logic [6:0] o_hex_5,
   output logic [6:0] o_hex_4,
	output logic [6:0] o_hex_3,
	output logic [6:0] o_hex_2,
   output logic [6:0] o_hex_1,
   output logic [6:0] o_hex_0
);

/* The layout of seven segment display, 1: dark
 *    00
 *   5  1
 *    66
 *   4  2
 *    33
 */
parameter D0 = 7'b1000000;
parameter D1 = 7'b1111001;
parameter D2 = 7'b0100100;
parameter D3 = 7'b0110000;
parameter D4 = 7'b0011001;
parameter D5 = 7'b0010010;
parameter D6 = 7'b0000010;
parameter D7 = 7'b1011000;
parameter D8 = 7'b0000000;
parameter D9 = 7'b0010000;
parameter DN = 7'b1111111;

always_comb begin
	if (curr_state == 2'b00) begin
		o_hex_7 = DN;
		o_hex_6 = DN;
		o_hex_5 = DN;
		o_hex_4 = DN;
		case(i_RSA_bit)
		 11'b00010000000: begin o_hex_3 = DN; o_hex_2 = D1; o_hex_1 = D2; o_hex_0 = D8; end
		 11'b00100000000: begin o_hex_3 = DN; o_hex_2 = D2; o_hex_1 = D5; o_hex_0 = D6; end
		 11'b01000000000: begin o_hex_3 = DN; o_hex_2 = D5; o_hex_1 = D1; o_hex_0 = D2; end
		 default: begin o_hex_3 = D0; o_hex_2 = D0; o_hex_1 = D0; o_hex_0 = D0; end
		endcase
	end
	else begin
		o_hex_7 = D8;
		o_hex_6 = D8;
		o_hex_5 = D8;
		o_hex_4 = D8;
		o_hex_3 = D8;
		o_hex_2 = D8;
		o_hex_1 = D8;
		o_hex_0 = D8;
	end
end

endmodule
