module Top (
	input i_rst_n,
	input i_clk,
	input i_key_0,// play/play_pause
	input i_key_1,// record/record_pause
	input i_key_2,// stop
	input i_LCD_key_0,
	input i_LCD_key_1,
	input i_LCD_key_2,
	input [4:0] i_DSP_option,//SW[4:0]
	// i_DSP_option is used to the mode we use
	// SW[4] determine slow_0 (0) or slow_1 (1)
	// SW[3] determine fast (0) or slow (1)
	// SW[2:0] determine i_speed (SW[2:0] + 1)
	// If i_speed == 1, i_fast, i_slow_0, i_slow_1 = 0
	
	// AudDSP and SRAM
	output [19:0] o_SRAM_ADDR,
	inout  [15:0] io_SRAM_DQ,
	output        o_SRAM_WE_N,
	output        o_SRAM_CE_N,
	output        o_SRAM_OE_N,
	output        o_SRAM_LB_N,
	output        o_SRAM_UB_N,
	
	// I2C
	input  i_clk_100k,
	output o_I2C_SCLK,
	inout  io_I2C_SDAT,
	
	// AudPlayer
	input  i_AUD_ADCDAT,
	inout  i_AUD_ADCLRCK,
	inout  i_AUD_BCLK,
	inout  i_AUD_DACLRCK,
	output o_AUD_DACDAT,

	// SEVENDECODER (optional display)
	// output [5:0] o_record_time,
	// output [5:0] o_play_time,

	// LCD (optional display)
	input        i_clk_800k,
	inout  [7:0] o_LCD_DATA,
	output       o_LCD_EN,
	output       o_LCD_RS,
	output       o_LCD_RW,
	output       o_LCD_ON,
	output       o_LCD_BLON

	// LED
	// output  [8:0] o_ledg,
	// output [17:0] o_ledr
);

// design the FSM and states as you like
parameter S_IDLE       = 0;
parameter S_I2C        = 1;
parameter S_RECD       = 2;
parameter S_RECD_PAUSE = 3;
parameter S_PLAY       = 4;
parameter S_PLAY_PAUSE = 5;
parameter S_I2C_FIN	  = 6;

logic [3:0] state_r, state_w;

// Determine same logic here
logic I2C_start, I2C_finished;
logic DSP_start, DSP_pause, DSP_stop;
logic REC_start, REC_pause, REC_stop;
logic player_en;

assign I2C_start = (state_r == S_I2C)? 1:0;
assign DSP_start = (state_r == S_PLAY)? 1:0;
assign DSP_pause = (state_r == S_PLAY_PAUSE)? 1:0;
assign DSP_stop = (state_r == S_I2C_FIN)? 1:0;
assign REC_start = (state_r == S_RECD)? 1:0;
assign REC_pause = (state_r == S_RECD_PAUSE)? 1:0;
assign REC_stop = (state_r == S_I2C_FIN)? 1:0;

// DSP option
logic [4:0] i_speed;
assign i_speed = i_DSP_option[2:0]+ 1;
logic DSP_fast, DSP_slow_0, DSP_slow_1;
assign DSP_fast = !i_DSP_option[3] && (i_speed != 1);
assign DSP_slow_0 = i_DSP_option[3] && !i_DSP_option[4] && (i_speed != 1);
assign DSP_slow_1 = i_DSP_option[3] && i_DSP_option[4] && (i_speed != 1);

logic i2c_oen, i2c_sdat;
logic [19:0] addr_record, addr_play;
logic [15:0] data_record, data_play, dac_data;

//assign io_I2C_SDAT = (i2c_oen) ? i2c_sdat : 1'bz;

assign o_SRAM_ADDR = (state_r == S_RECD) ? addr_record : addr_play[19:0];
assign io_SRAM_DQ  = (state_r == S_RECD) ? data_record : 16'dz; // sram_dq as output
assign data_play   = (state_r != S_RECD) ? io_SRAM_DQ : 16'd0; // sram_dq as input

assign o_SRAM_WE_N = (state_r == S_RECD) ? 1'b0 : 1'b1;
assign o_SRAM_CE_N = 1'b0;
assign o_SRAM_OE_N = 1'b0;
assign o_SRAM_LB_N = 1'b0;
assign o_SRAM_UB_N = 1'b0;

logic [7:0] LCD_character, LCD_address;
logic LCD_start, LCD_busy;
// below is a simple example for module division
// you can design these as you like


// === I2cInitializer ===
// sequentially sent out settings to initialize WM8731 with I2C protocal
I2cInitializer init0(
	.i_rst_n(i_rst_n),
	.i_clk(i_clk_100k),
	.i_start(I2C_start),
	.o_finished(I2C_finished),
	.o_sclk(o_I2C_SCLK),
	.io_sdat(io_I2C_SDAT),
	.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

// === AudDSP ===
// responsible for DSP operations including fast play and slow play at different speed
// in other words, determine which data addr to be fetch for player 
AudDSP dsp0(
	.i_rst_n(i_rst_n),
	//.i_clk(),
	.i_start(DSP_start),
	.i_pause(DSP_pause),
	.i_stop(DSP_stop),
	.i_speed(i_speed),
	.i_fast(DSP_fast),
	.i_slow_0(DSP_slow_0), // constant interpolation
	.i_slow_1(DSP_slow_1), // linear interpolation
	.i_daclrck(i_AUD_DACLRCK),
	.i_sram_data(data_play),
	.o_dac_data(dac_data),
	.o_sram_addr(addr_play),
	.play_en(player_en)
);

// === AudPlayer ===
// receive data address from DSP and fetch data to sent to WM8731 with I2S protocal
AudPlayer player0(
	.i_rst_n(i_rst_n),
	.i_bclk(i_AUD_BCLK),
	.i_daclrck(i_AUD_DACLRCK),
	.i_en(player_en), // enable AudPlayer only when playing audio, work with AudDSP
	.i_dac_data(dac_data), //dac_data
	.o_aud_dacdat(o_AUD_DACDAT)
);

// === AudRecorder ===
// receive data from WM8731 with I2S protocal and save to SRAM
AudRecorder recorder0(
	.i_rst_n(i_rst_n), 
	.i_clk(i_AUD_BCLK),
	.i_lrc(i_AUD_ADCLRCK),
	.i_start(REC_start),
	.i_pause(REC_pause),
	.i_stop(REC_stop),
	.i_data(i_AUD_ADCDAT),
	.o_address(addr_record),
	.o_data(data_record)
);

// === LcdDisplayer ===
// Show the information on the 16x2 LCD
LcdDisplayer lcddisplayer0(
	.i_clk_800k(i_clk_800k),
	.i_rst_n(i_rst_n),
	.o_LCD_DATA(o_LCD_DATA), // [7:0]
	.o_LCD_EN(o_LCD_EN),
	.o_LCD_RS(o_LCD_RS),
	.o_LCD_RW(o_LCD_RW),
	.o_LCD_ON(o_LCD_ON),
	.o_LCD_BLON(o_LCD_BLON),
	.i_character(LCD_character),
	.i_address(LCD_address),
	.start(LCD_start),
	.busy(LCD_busy)
);

LcdDataGiver lcddatagiver0(
	.i_clk_800k(i_clk_800k),
	.i_rst_n(i_rst_n),
	.o_character(LCD_character),
	.o_address(LCD_address),
	.start(LCD_start),
	.busy(LCD_busy),
	.i_key_0(i_LCD_key_0),// play/play_pause
	.i_key_1(i_LCD_key_1),// record/record_pause
	.i_key_2(i_LCD_key_2),// stop
	.i_DSP_option(i_DSP_option)
);

always_comb begin
	// design your control here
	case (state_r)
		S_IDLE : state_w = S_I2C;
		S_I2C	: state_w = (I2C_finished)? S_I2C_FIN : S_I2C;
		S_RECD : state_w = (i_key_1)? S_RECD_PAUSE : ((i_key_2)? S_I2C_FIN : S_RECD);
		S_RECD_PAUSE : state_w = (i_key_1)? S_RECD : ((i_key_2)? S_I2C_FIN : S_RECD_PAUSE);
		S_PLAY : state_w = (i_key_0)? S_PLAY_PAUSE : ((i_key_2)? S_I2C_FIN : S_PLAY);
		S_PLAY_PAUSE : state_w = (i_key_0)? S_PLAY : ((i_key_2)? S_I2C_FIN : S_PLAY_PAUSE);
		S_I2C_FIN : state_w = (i_key_0)? S_PLAY : ((i_key_1)? S_RECD : S_I2C_FIN);
		default : state_w = S_IDLE;
	endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
	if (!i_rst_n) begin
		state_r <= S_IDLE;
	end
	else begin
		state_r <= state_w;
	end
end

endmodule
