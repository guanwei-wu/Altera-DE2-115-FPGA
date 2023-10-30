module PS2controller(
	input i_clk,
	input i_rst_n,
	inout io_ps2_clk,
	inout io_ps2_dat,
	output [2:0] o_key_data
);

logic ps2_clk0, ps2_clk1;// detect negedge
logic [3:0] cnt_r, cnt_w;
logic [7:0] pressed_key_r, pressed_key_w;
logic key_break_r, key_break_w;
logic [2:0] o_key_r, o_key_w;

assign o_key_data = o_key_r;
 
always_comb begin
	cnt_w = cnt_r;
	pressed_key_w = pressed_key_r;
	key_break_w = key_break_r;
	o_key_w = o_key_r;
	if (ps2_clk1 & (~ps2_clk0)) begin
		if (cnt_r < 10) begin
			cnt_w = cnt_r + 1;
		end
		case (cnt_r)
			4'd0 : ; //start
			4'd1 : pressed_key_w = {io_ps2_dat,7'b0} + (pressed_key_r >> 1);
			4'd2 : pressed_key_w = {io_ps2_dat,7'b0} + (pressed_key_r >> 1);
			4'd3 : pressed_key_w = {io_ps2_dat,7'b0} + (pressed_key_r >> 1);
			4'd4 : pressed_key_w = {io_ps2_dat,7'b0} + (pressed_key_r >> 1);
			4'd5 : pressed_key_w = {io_ps2_dat,7'b0} + (pressed_key_r >> 1);
			4'd6 : pressed_key_w = {io_ps2_dat,7'b0} + (pressed_key_r >> 1);
			4'd7 : pressed_key_w = {io_ps2_dat,7'b0} + (pressed_key_r >> 1);
			4'd8 : pressed_key_w = {io_ps2_dat,7'b0} + (pressed_key_r >> 1);
			4'd9 : ; //parity, we just ignore it
			4'd10 : begin //stop
				cnt_w = 4'd0; 
				if (pressed_key_r == 8'hF0) begin //break, 8'hF0
					key_break_w = 1'b1;
				end else if (!key_break_r) begin
					case (pressed_key_r)
						8'h75: o_key_w = 3'd1; //UP, 8'h75 
						8'h72: o_key_w = 3'd2; //DOWN, 8'h72 
						8'h6B: o_key_w = 3'd3; //LEFT, 8'h6B 
						8'h74: o_key_w = 3'd4; //RIGHT, 8'h74 
						8'h29: o_key_w = 3'd5; //SPACE, 8'h29
						8'h5A: o_key_w = 3'd6; //ENTER, 8'h5A
						8'h66: o_key_w = 3'd7; //BACKSPACE, 8'h66
						8'hE0: o_key_w = o_key_r; //8'hE0 
						default : o_key_w = 3'd0; // Not pressed
					endcase
				end else begin
					key_break_w = 1'b0;
					pressed_key_w = 8'h00;
					o_key_w = 3'd0; 
				end
			end
			default : ;
		endcase
	end
end

 // Flip-flop
always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (~i_rst_n) begin
		ps2_clk0 <= 1'b1;
		ps2_clk1 <= 1'b1;
		cnt_r <= 4'b0000;
		pressed_key_r <= 8'h00;
		key_break_r <= 1'b0;
		o_key_r <= 2'b00;
	end else begin
		ps2_clk0 <= io_ps2_clk;
		ps2_clk1 <= ps2_clk0;
		cnt_r <= cnt_w;
		pressed_key_r <= pressed_key_w;
		key_break_r <= key_break_w;
		o_key_r <= o_key_w;
	end
end

endmodule
