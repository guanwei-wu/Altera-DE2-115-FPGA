module LcdDisplayer (
	input        i_clk_800k,
	input 		 i_rst_n,
	inout  [7:0] o_LCD_DATA,
	output       o_LCD_EN,
	output       o_LCD_RS,
	output       o_LCD_RW,
	output       o_LCD_ON,
	output       o_LCD_BLON,
	input  [7:0] i_character,
	input  [7:0] i_address,
	input 		 start,
	output 		 busy
);

// Turn LCD ON
assign o_LCD_ON = 1'b1;
assign o_LCD_BLON = 1'b1;

// define states
localparam WAIT = 3'd0;
localparam INIT = 3'd1;
localparam GET_DATA = 3'd2;
localparam SET_ADDR = 3'd3;
localparam SET_WORD = 3'd4;

logic [7:0] data_r, data_w; 
logic en_r, en_w, rs_r, rs_w, rw_r, rw_w;
logic busy_r, busy_w;

// clock cycle 1.25 us
localparam WAIT_CLOCK = 30000;
localparam ADDR_SETUP_INTERVAL = 2;
localparam ENABLE_INTERVAL = 2;
localparam PROCESSING_INTERVAL = 500;

logic [2:0] state_r, state_w;
logic [15:0] counter_r, counter_w;
logic [1:0] init_stage_r, init_stage_w;
logic [7:0] character_r, character_w, address_r, address_w;

assign o_LCD_DATA = data_r;
assign o_LCD_EN = en_r;
assign o_LCD_RS = rs_r;
assign o_LCD_RW = rw_r;
assign busy = busy_r;

always_comb begin
	state_w = state_r;
	counter_w = counter_r;
	init_stage_w = init_stage_r;
	data_w = data_r;
	en_w = en_r;
	rs_w = rs_r;
	rw_w = rw_r;
	busy_w = busy_r;
	character_w = character_r;
	address_w = address_r;
	case (state_r)
		WAIT : begin
			if (counter_r < WAIT_CLOCK) begin
				counter_w = counter_r + 1;
			end
			else begin
				state_w = INIT;
				counter_w = 16'b0;
				rs_w = 0;
				rw_w = 1;
			end
		end
		INIT : begin
			rs_w = 0;
			rw_w = 0;
			case (init_stage_r) 
				2'b00 : data_w = 8'b00111000;
				2'b01 : data_w = 8'b00001100;
				2'b10 : data_w = 8'b00000001;
				2'b11 : data_w = 8'b00000110;
			endcase
			if (counter_r < ADDR_SETUP_INTERVAL) begin
				counter_w = counter_r + 1;
			end else if (counter_r < ADDR_SETUP_INTERVAL + ENABLE_INTERVAL) begin
				en_w = 1;
				counter_w = counter_r + 1;
			end else if (counter_r < ADDR_SETUP_INTERVAL + ENABLE_INTERVAL + PROCESSING_INTERVAL) begin
				en_w = 0;
				counter_w = counter_r + 1;
			end else begin
				counter_w = 0;
				rs_w = 0;
				rw_w = 1;
				if (init_stage_r != 2'b11) begin
					init_stage_w = init_stage_r + 1;
				end else begin
					init_stage_w = 2'b00;
					busy_w = 0;
					state_w = GET_DATA;
				end
			end
		end
		GET_DATA : begin
			if (start) begin
				busy_w = 1;
				state_w = SET_ADDR;
				character_w = i_character;
				address_w = i_address;
			end
		end
		SET_ADDR : begin
			rs_w = 0;
			rw_w = 0;
			data_w = {1'b1,address_r[6:0]};
			if (counter_r < ADDR_SETUP_INTERVAL) begin
				counter_w = counter_r + 1;
			end else if (counter_r < ADDR_SETUP_INTERVAL + ENABLE_INTERVAL) begin
				en_w = 1;
				counter_w = counter_r + 1;
			end else if (counter_r < ADDR_SETUP_INTERVAL + ENABLE_INTERVAL + PROCESSING_INTERVAL) begin
				en_w = 0;
				counter_w = counter_r + 1;
			end else begin
				counter_w = 0;
				rs_w = 0;
				rw_w = 1;
				state_w = SET_WORD;
			end
		end
		SET_WORD : begin
			rs_w = 1;
			rw_w = 0;
			data_w = character_r;
			if (counter_r < ADDR_SETUP_INTERVAL) begin
				counter_w = counter_r + 1;
			end else if (counter_r < ADDR_SETUP_INTERVAL + ENABLE_INTERVAL) begin
				en_w = 1;
				counter_w = counter_r + 1;
			end else if (counter_r < ADDR_SETUP_INTERVAL + ENABLE_INTERVAL + PROCESSING_INTERVAL) begin
				en_w = 0;
				counter_w = counter_r + 1;
			end else begin
				counter_w = 0;
				rs_w = 0;
				rw_w = 1;
				busy_w = 0;
				state_w = GET_DATA;
			end
		end
		default : begin
		end
	endcase
end

always_ff @(posedge i_clk_800k or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= WAIT;
		counter_r <= 16'b0;
		init_stage_r <= 2'b00;
		data_r <= 8'b00111111;
		en_r <= 1'b1;
		rs_r <= 1'b0;
		rw_r <= 1'b0;
		busy_r <= 1'b1;
		character_r = 8'b0;
		address_r = 8'b0;
	end
	else begin
		state_r <= state_w;
		counter_r <= counter_w;
		init_stage_r <= init_stage_w;
		data_r <= data_w;
		en_r <= en_w;
		rs_r <= rs_w;
		rw_r <= rw_w;
		busy_r <= busy_w;
		character_r = character_w;
		address_r = address_w;
	end
end

endmodule
