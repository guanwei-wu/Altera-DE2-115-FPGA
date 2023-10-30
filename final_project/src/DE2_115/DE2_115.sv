module DE2_115 (
	// default clock
	input CLOCK_50,
	input CLOCK2_50,
	input CLOCK3_50,
	
	// ??, not used
	input ENETCLK_25,
	input SMA_CLKIN,
	output SMA_CLKOUT,
	
	// LED, may used
	output [8:0] LEDG,
	output [17:0] LEDR,
	
	// Button, may used
	input [3:0] KEY,
	input [17:0] SW,
	
	// Seven segment display, may used
	output [6:0] HEX0,
	output [6:0] HEX1,
	output [6:0] HEX2,
	output [6:0] HEX3,
	output [6:0] HEX4,
	output [6:0] HEX5,
	output [6:0] HEX6,
	output [6:0] HEX7,
	
	// LCD, may used
	output LCD_BLON,
	inout [7:0] LCD_DATA,
	output LCD_EN,
	output LCD_ON,
	output LCD_RS,
	output LCD_RW,
	
	// UART, not used
	output UART_CTS,
	input UART_RTS,
	input UART_RXD,
	output UART_TXD,
	
	// PS2, keyboard
	inout PS2_CLK,
	inout PS2_DAT,
	inout PS2_CLK2,
	inout PS2_DAT2,
	
	// SD CARD, not used
	output SD_CLK,
	inout SD_CMD,
	inout [3:0] SD_DAT,
	input SD_WP_N,
	
	// VGA, screen display
	output [7:0] VGA_B,
	output VGA_BLANK_N,
	output VGA_CLK,
	output [7:0] VGA_G,
	output VGA_HS,
	output [7:0] VGA_R,
	output VGA_SYNC_N,
	output VGA_VS,
	
	// AUDIO, audio control
	input AUD_ADCDAT,
	inout AUD_ADCLRCK,
	inout AUD_BCLK,
	output AUD_DACDAT,
	inout AUD_DACLRCK,
	output AUD_XCK,
	
	// EEPROM, not used
	output EEP_I2C_SCLK,
	inout EEP_I2C_SDAT,
	
	// I2C, for audio
	output I2C_SCLK,
	inout I2C_SDAT,
	
	// ETHERNET, not used
	output ENET0_GTX_CLK,
	input ENET0_INT_N,
	output ENET0_MDC,
	input ENET0_MDIO,
	output ENET0_RST_N,
	input ENET0_RX_CLK,
	input ENET0_RX_COL,
	input ENET0_RX_CRS,
	input [3:0] ENET0_RX_DATA,
	input ENET0_RX_DV,
	input ENET0_RX_ER,
	input ENET0_TX_CLK,
	output [3:0] ENET0_TX_DATA,
	output ENET0_TX_EN,
	output ENET0_TX_ER,
	input ENET0_LINK100,
	output ENET1_GTX_CLK,
	input ENET1_INT_N,
	output ENET1_MDC,
	input ENET1_MDIO,
	output ENET1_RST_N,
	input ENET1_RX_CLK,
	input ENET1_RX_COL,
	input ENET1_RX_CRS,
	input [3:0] ENET1_RX_DATA,
	input ENET1_RX_DV,
	input ENET1_RX_ER,
	input ENET1_TX_CLK,
	output [3:0] ENET1_TX_DATA,
	output ENET1_TX_EN,
	output ENET1_TX_ER,
	input ENET1_LINK100,
	
	// TV?, not used
	input TD_CLK27,
	input [7:0] TD_DATA,
	input TD_HS,
	output TD_RESET_N,
	input TD_VS,
	inout [15:0] OTG_DATA,
	output [1:0] OTG_ADDR,
	output OTG_CS_N,
	output OTG_WR_N,
	output OTG_RD_N,
	input OTG_INT,
	output OTG_RST_N,
	input IRDA_RXD,
	
	// SDRAM, not used
	output [12:0] DRAM_ADDR,
	output [1:0] DRAM_BA,
	output DRAM_CAS_N,
	output DRAM_CKE,
	output DRAM_CLK,
	output DRAM_CS_N,
	inout [31:0] DRAM_DQ,
	output [3:0] DRAM_DQM,
	output DRAM_RAS_N,
	output DRAM_WE_N,
	
	// SRAM, may used
	output [19:0] SRAM_ADDR,
	output SRAM_CE_N,
	inout [15:0] SRAM_DQ,
	output SRAM_LB_N,
	output SRAM_OE_N,
	output SRAM_UB_N,
	output SRAM_WE_N,
	
	// Flash, not used
	output [22:0] FL_ADDR,
	output FL_CE_N,
	inout [7:0] FL_DQ,
	output FL_OE_N,
	output FL_RST_N,
	input FL_RY,
	output FL_WE_N,
	output FL_WP_N,
	
	// Other, not used
	inout [35:0] GPIO,
	input HSMC_CLKIN_P1,
	input HSMC_CLKIN_P2,
	input HSMC_CLKIN0,
	output HSMC_CLKOUT_P1,
	output HSMC_CLKOUT_P2,
	output HSMC_CLKOUT0,
	inout [3:0] HSMC_D,
	input [16:0] HSMC_RX_D_P,
	output [16:0] HSMC_TX_D_P,
	inout [6:0] EX_IO
);

wire [2:0] key_input;

assign AUD_XCK = CLOCK_12;

wire [15:0] data_jump;

wire       w_show_en;     // 1 when in display time
wire [9:0] w_vga_x_cord;  // next pixel cordinate,  x
wire [9:0] w_vga_y_cord;  // next pixel cordinate,  y

wire jump;
wire CLOCK_25;     // 25MHz clock from pll
wire CLOCK_12,CLOCK_100k;
wire rst_main;     // main reset, high active

wire [1:0] w_character_vga;
wire [1:0] w_arr_point [0:3];
wire w_change_arr;
wire [1:0] w_life;
wire [1:0] w_state;
wire [3:0] w_cnt_shot;

wire w_hit;
wire [9:0] w_sq_height [0:3]; // square also need
wire w_jumping [0:3]; // need more jumps [3:0]
wire [9:0] w_nd_x [0:5];  // nd_x = 0 won't show any needle
wire [1:0] w_nd_y [0:5];  // only record which strip it is
wire [9:0] w_nd_height [0:5];

wire w_start;
assign w_start = (key_input == 3'd5);
wire [13:0] w_score;
wire [13:0] w_high_score;
wire w_jump;
wire [2:0] w_character;
//assign w_jump = SW[16];	// no need
assign w_character = key_input; 

assign rst_main = SW[17];
// assign VGA_B = 8'd255;
// assign VGA_R = 8'd255;
// assign VGA_G = 8'd255;
assign LEDR[17:1] = 17'd0;
assign LEDR[0] = (w_jump) ? 1'b1:1'b0; 
assign LEDG = 9'd0;

//=== ALTPLL ===//
// The clock
my_atlpll pll(
	.clk_clk(CLOCK_50),       // clk.clk
	.clock_25m_clk(CLOCK_25), // 25Mhz clk
	.clock_12m_clk(CLOCK_12), // 12Mhz clk
	.clock_100k_clk(CLOCK_100k), // 100khz clk
	.reset_reset_n(~rst_main) // reset.reset_n
);

//=== VGA Display ===//
// Display on the screen using VGA
VGA vga(
	.i_rst_n(~rst_main),
	.i_clk_25M(CLOCK_25),

	.VGA_BLANK_N(VGA_BLANK_N),
	.VGA_CLK(VGA_CLK),
	.VGA_HS(VGA_HS),
	.VGA_SYNC_N(VGA_SYNC_N),
	.VGA_VS(VGA_VS),

	.o_show_en(w_show_en),     
	.o_x_cord(w_vga_x_cord),	// VGA module return x, y in reverse coordinate
	.o_y_cord(w_vga_y_cord)
);
Screen screen(
    .clk(CLOCK_25),
    .rst_n(~rst_main),
    .i_x_cord(w_vga_y_cord),
    .i_y_cord(w_vga_x_cord),

    .character(w_character_vga),
    .arr_point(w_arr_point),
    .change_arr(w_change_arr),

    .life(w_life),
    .state(w_state),
    .cnt_shot(w_cnt_shot),
    .hit(w_hit),
    .sq_height(w_sq_height), // square also need
    .jumping(w_jumping), // need more jumpings [3:0]

    .nd_x(w_nd_x),  // nd_x = 0 won't show any needle
    .nd_y(w_nd_y),  // only record which strip it is
    .nd_height(w_nd_height),

    .o_VGA_R(VGA_R),
    .o_VGA_G(VGA_G),
    .o_VGA_B(VGA_B)
);
GameCore gamecore (
    .clk(CLOCK_25),
    .rst_n(~rst_main),
    .i_x_cord(w_vga_y_cord),
    .i_y_cord(w_vga_x_cord),
    .start(w_start),
    .jump(w_jump),
    .character(w_character),

    .score(w_score),
    .high_score(w_high_score),
    .character_vga(w_character_vga),
    .arr_point(w_arr_point),
    .change_arr(w_change_arr),

    .cnt_shot(w_cnt_shot),
    .life(w_life),
    .state(w_state),
    
    .hit(w_hit),
    .sq_height(w_sq_height), // square also need
    .jumping(w_jumping), // need more jumps [3:0]

    .nd_x(w_nd_x),  // nd_x = 0 won't show any needle
    .nd_y(w_nd_y),  // only record which strip it is
    .nd_height(w_nd_height)
);

//=== Audio ===//
// Read the data from the microphone and generate control signal

I2cInitializer init0(
	.i_rst_n(~rst_main),
	.i_clk(CLOCK_100k),
	.i_start(1'b1),
	.o_finished(I2C_finished),
	.o_sclk(I2C_SCLK),
	.io_sdat(I2C_SDAT),
	//.o_oen(i2c_oen) // you are outputing (you are not outputing only when you are "ack"ing.)
);

Audiocontroller audiocontroller0(
	.i_rst_n(~rst_main), 
	.i_clk(AUD_BCLK),
	.i_lrc(AUD_ADCLRCK),
	.i_start(I2C_finished),
	.i_data(AUD_ADCDAT),
	.o_jump(w_jump),
	.o_data(data_jump) //testing
);

//=== KeyBoard ===//
// Read the input of keyboard, use PS2
PS2controller ps2controller(
	.i_clk(CLOCK_50),
	.i_rst_n(~rst_main),
	.io_ps2_clk(PS2_CLK),
	.io_ps2_dat(PS2_DAT),
	.o_key_data(key_input) //0:IDLE, 1:UP, 2:DOWN, 3:LEFT, 4:RIGHT, 5:SPACE, 6:ENTER, 7:BACKSPACE
);

SevenHexDecoder hex0(
	.i_hex(w_score%10),
	//.o_seven_ten(HEX7),
	.o_seven_one(HEX0)
);

SevenHexDecoder hex1(
	.i_hex((w_score%100)/10),
	//.o_seven_ten(HEX7),
	.o_seven_one(HEX1)
);

SevenHexDecoder hex2(
	.i_hex((w_score%1000)/100),
	//.o_seven_ten(HEX7),
	.o_seven_one(HEX2)
);

SevenHexDecoder hex3(
	.i_hex(w_score/1000),
	//.o_seven_ten(HEX7),
	.o_seven_one(HEX3)
);

SevenHexDecoder hex4(
	.i_hex(w_high_score%10),
	//.o_seven_ten(HEX7),
	.o_seven_one(HEX4)
);

SevenHexDecoder hex5(
	.i_hex((w_high_score%100)/10),
	//.o_seven_ten(HEX7),
	.o_seven_one(HEX5)
);

SevenHexDecoder hex6(
	.i_hex((w_high_score%1000)/100),
	//.o_seven_ten(HEX7),
	.o_seven_one(HEX6)
);

SevenHexDecoder hex7(
	.i_hex(w_high_score/1000),
	//.o_seven_ten(HEX7),
	.o_seven_one(HEX7)
);
/* Test keyboard
SevenHexDecoder hex0(
	.i_hex({1'b0,key_input}),
	.o_seven_ten(HEX7),
	.o_seven_one(HEX6)
);
*/
/*
// Test audio
SevenHexDecoder hex0(
	.i_hex(data_jump[15:12]),
	.o_seven_ten(HEX7),
	.o_seven_one(HEX6)
);
SevenHexDecoder hex1(
	.i_hex(data_jump[11:8]),
	.o_seven_ten(HEX5),
	.o_seven_one(HEX4)
);
SevenHexDecoder hex2(
	.i_hex(data_jump[7:4]),
	.o_seven_ten(HEX3),
	.o_seven_one(HEX2)
);
SevenHexDecoder hex3(
	.i_hex({3'b0,w_jump}),
	.o_seven_ten(HEX1),
	.o_seven_one(HEX0)
);
*/

// 7-segment display
//assign HEX0 = '1;
//assign HEX1 = '1;
//assign HEX2 = '1;
//assign HEX3 = '1;
//assign HEX4 = '1;
//assign HEX5 = '1;
//assign HEX6 = '1;
//assign HEX7 = '1;

endmodule
