module I2cInitializer(
	input i_rst_n,
	input i_clk,
	input i_start,
	output o_finished,
	output o_sclk,
	inout io_sdat,
	output o_oen //not using since we determine o_sdat in this module
);

logic	[1:0]	state_r, state_w;
logic	[3:0]	tasknum_r, tasknum_w;
logic	[2:0]	bit_cnt_r, bit_cnt_w;
logic	[1:0]	byte_cnt_r, byte_cnt_w;
logic			sclk_r, sclk_w;
logic			sdat_r, sdat_w;
logic	[23:0]	data_r, data_w;
logic			buffer_r, buffer_w;

localparam	S_IDLE = 0;
localparam	S_RW = 1;
localparam	S_ACK = 2;
localparam	S_DONE = 3;

localparam  ADDR = 8'b0011_0100;

localparam	LLI = 16'b0000000010010111;
localparam	RLI = 16'b0000001010010111;
localparam	LHO = 16'b0000010001111001;
localparam	RHO = 16'b0000011001111001;
localparam	AAPC = 16'b0000100000010101;
localparam	DAPC = 16'b0000101000000000;
localparam	PDC = 16'b0000110000000000;
localparam	DAI = 16'b0000111001000010;
localparam	SC = 16'b0001000000011001;
localparam	AC = 16'b0001001000000001;

localparam	T_IDLE = 0;
localparam	T_LLI = 1;
localparam	T_RLI = 2;
localparam	T_LHO = 3;
localparam	T_RHO = 4;
localparam	T_AAPC = 5;
localparam	T_DAPC = 6;
localparam	T_PDC = 7;
localparam	T_DAI = 8;
localparam	T_SC = 9;
localparam	T_AC = 10;
localparam	T_FIN = 11;

assign 	o_finished = (tasknum_r == T_FIN);
assign 	o_sclk = sclk_r;
assign 	io_sdat = o_oen? sdat_r : 1'bz;
assign 	o_oen = (state_r != S_ACK);// not ACK

always_comb begin
	state_w = state_r;
	tasknum_w = tasknum_r;
	bit_cnt_w = bit_cnt_r;
	byte_cnt_w = byte_cnt_r;
	sclk_w = sclk_r;
	sdat_w = sdat_r;
	data_w = data_r;
	buffer_w = buffer_r;	
	
	if ((tasknum_r == 0) && i_start) begin
		tasknum_w = 1;
	end
	
	if (sdat_r && (state_r == S_DONE) && (tasknum_r != T_FIN)) begin
		tasknum_w = tasknum_r + 1;
	end
	
	case (state_r)
		S_IDLE : begin
			bit_cnt_w = 3'b0;
			byte_cnt_w = 2'b0;
			buffer_w = 1'b0;
			sclk_w = 1'b1;
			case (tasknum_r)
				T_IDLE : data_w = 24'b0;
				T_LLI : data_w = {ADDR,LLI};
				T_RLI : data_w = {ADDR,RLI};
				T_LHO : data_w = {ADDR,LHO};
				T_RHO : data_w = {ADDR,RHO};
				T_AAPC : data_w = {ADDR,AAPC};
				T_DAPC : data_w = {ADDR,DAPC};
				T_PDC : data_w = {ADDR,PDC};
				T_DAI : data_w = {ADDR,DAI};
				T_SC : data_w = {ADDR,SC};
				T_AC : data_w = {ADDR,AC};
				T_FIN : data_w = 24'b0;
				default : data_w = 24'b0;
			endcase
			if (tasknum_r != 0) begin
				state_w = S_RW;
				sdat_w = 0;
			end
		end
		S_RW : begin
			sclk_w = ~sclk_r;
			if (!sclk_r) begin
				data_w = data_r << 1;
			end
			sdat_w = data_r[23];
			if (buffer_r && sclk_r) begin
				bit_cnt_w = bit_cnt_r + 1;
			end
			buffer_w = 1'b1;
			if ((bit_cnt_r == 3'd7) && sclk_r) begin
				state_w = S_ACK;
				bit_cnt_w = 3'd0;
			end
		end
		S_ACK : begin
			sclk_w = ~sclk_r;
			if ( !io_sdat /* acknowledgement */ && sclk_r) begin
				if (byte_cnt_r == 2) begin
					state_w = S_DONE;
					byte_cnt_w = 2'b0;
				end else begin
					state_w = S_RW;
					byte_cnt_w = byte_cnt_r + 1;
				end
			end
		end
		S_DONE : begin
			sclk_w = 1'b1;
			buffer_w = 1'b0;
			if (!buffer_r) begin
				sdat_w = 1;
			end else begin
				sdat_w = 0;
			end
			if (sdat_r && (tasknum_r != 10)) begin
				state_w = S_IDLE;
			end
		end
		default : begin
		end
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= S_IDLE;
		tasknum_r <= T_IDLE;
		bit_cnt_r <= 3'b0;
		byte_cnt_r <= 2'b0;
		sclk_r <= 1'b1;
		sdat_r <= 1'b1;
		data_r <= 24'b0;
		buffer_r <= 1'b0;
	end
	else begin
		state_r <= state_w;
		tasknum_r <= tasknum_w;
		bit_cnt_r <= bit_cnt_w;
		byte_cnt_r <= byte_cnt_w;
		sclk_r <= sclk_w;
		sdat_r <= sdat_w;
		data_r <= data_w;
		buffer_r <= buffer_w;
	end
end

endmodule
