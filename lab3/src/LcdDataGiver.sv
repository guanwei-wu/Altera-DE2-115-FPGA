module LcdDataGiver(
	 input  i_clk_800k,
	 input  i_rst_n,
	 output [7:0] o_character,
	 output [7:0] o_address,
	 output start,
	 input  busy,
	 input  i_key_0,// play/play_pause
	 input  i_key_1,// record/record_pause
	 input  i_key_2,// stop
	 input  [4:0] i_DSP_option
);

logic start_r, start_w;
logic [3:0] LCD_state_r, LCD_state_w;
logic [3:0] curr_state_r, curr_state_w;
logic [7:0] character_r, character_w;
logic [7:0] address_r, address_w, o_address_r, o_address_w; 

assign start = start_r;
assign o_character = character_r;
assign o_address = o_address_r;

// define states
localparam LCD_CHOOSE_STATE = 4'd15;
//localparam TESTING = 4'd12;
localparam S_RECD       = 4'd2;
localparam S_RECD_PAUSE = 4'd3;
localparam S_PLAY       = 4'd4;
localparam S_PLAY_PAUSE = 4'd5;
localparam S_I2C_FIN	   = 4'd6;
localparam LCD_S_RECD       = 4'd2;
localparam LCD_S_RECD_PAUSE = 4'd3;
localparam LCD_S_PLAY       = 4'd4;
localparam LCD_S_PLAY_PAUSE = 4'd5;
localparam LCD_S_I2C_FIN	 = 4'd6;

// DSP option
logic [4:0] i_speed;
assign i_speed = i_DSP_option[2:0]+ 1;
logic DSP_fast, DSP_slow_0, DSP_slow_1;
assign DSP_fast = !i_DSP_option[3] && (i_speed != 1);
assign DSP_slow_0 = i_DSP_option[3] && !i_DSP_option[4] && (i_speed != 1);
assign DSP_slow_1 = i_DSP_option[3] && i_DSP_option[4] && (i_speed != 1);

always_comb begin
	start_w = start_r;
	LCD_state_w = LCD_state_r;
	curr_state_w = curr_state_r;
	character_w = character_r;
	address_w = address_r;
	o_address_w = o_address_r;
	case (curr_state_r)
		S_RECD : curr_state_w = (i_key_1)? S_RECD_PAUSE : ((i_key_2)? S_I2C_FIN : S_RECD);
		S_RECD_PAUSE : curr_state_w = (i_key_1)? S_RECD : ((i_key_2)? S_I2C_FIN : S_RECD_PAUSE);
		S_PLAY : curr_state_w = (i_key_0)? S_PLAY_PAUSE : ((i_key_2)? S_I2C_FIN : S_PLAY);
		S_PLAY_PAUSE : curr_state_w = (i_key_0)? S_PLAY : ((i_key_2)? S_I2C_FIN : S_PLAY_PAUSE);
		S_I2C_FIN : curr_state_w = (i_key_0)? S_PLAY : ((i_key_1)? S_RECD : S_I2C_FIN);
		default : curr_state_w = S_I2C_FIN;
	endcase
	case (LCD_state_r)
		LCD_CHOOSE_STATE : begin
			case (curr_state_r)
				S_RECD : begin
					LCD_state_w = LCD_S_RECD;
					address_w = 8'h00;
					o_address_w = 8'h00;
				end
				S_RECD_PAUSE : begin
					LCD_state_w = LCD_S_RECD_PAUSE;
					address_w = 8'h00;
					o_address_w = 8'h00;
				end
				S_PLAY : begin
					LCD_state_w = LCD_S_PLAY;
					address_w = 8'h00;
					o_address_w = 8'h00;
				end
				S_PLAY_PAUSE : begin
					LCD_state_w = LCD_S_PLAY_PAUSE;
					address_w = 8'h00;
					o_address_w = 8'h00;
				end
				S_I2C_FIN : begin
					LCD_state_w = LCD_S_I2C_FIN;
					address_w = 8'h00;
					o_address_w = 8'h00;
				end
				default : begin
					LCD_state_w = LCD_CHOOSE_STATE;
				end
			endcase
		end
		/*TESTING : begin
			// testing text
			// ___Fuck___You___
			// __LAB3__!!!QAQ__
			// 20_20_20_46_75_63_6B_20_20_20_59_6F_75_20_20_20
			// 20_20_4C_41_42_33_20_20_21_21_21_51_41_51_20_20
			if (busy) begin
				start_w = 0;
			end else if (!start_r) begin
				start_w = 1;
				case (address_r)
					8'h00 : begin
						character_w = 8'h20;
						address_w = 8'h01;
						o_address_w = 8'h00;
					end
					8'h01 : begin
						character_w = 8'h20;
						address_w = 8'h02;
						o_address_w = 8'h01;
					end
					8'h02 : begin
						character_w = 8'h20;
						address_w = 8'h03;
						o_address_w = 8'h02;
					end
					8'h03 : begin
						character_w = 8'h46;
						address_w = 8'h04;
						o_address_w = 8'h03;
					end
					8'h04 : begin
						character_w = 8'h75;
						address_w = 8'h05;
						o_address_w = 8'h04;
					end
					8'h05 : begin
						character_w = 8'h63;
						address_w = 8'h06;
						o_address_w = 8'h05;
					end
					8'h06 : begin
						character_w = 8'h6B;
						address_w = 8'h07;
						o_address_w = 8'h06;
					end
					8'h07 : begin
						character_w = 8'h20;
						address_w = 8'h08;
						o_address_w = 8'h07;
					end
					8'h08 : begin
						character_w = 8'h20;
						address_w = 8'h09;
						o_address_w = 8'h08;
					end
					8'h09 : begin
						character_w = 8'h20;
						address_w = 8'h0A;
						o_address_w = 8'h09;
					end
					8'h0A : begin
						character_w = 8'h59;
						address_w = 8'h0B;
						o_address_w = 8'h0A;
					end
					8'h0B : begin
						character_w = 8'h6F;
						address_w = 8'h0C;
						o_address_w = 8'h0B;
					end
					8'h0C : begin
						character_w = 8'h75;
						address_w = 8'h0D;
						o_address_w = 8'h0C;
					end
					8'h0D : begin
						character_w = 8'h20;
						address_w = 8'h0E;
						o_address_w = 8'h0D;
					end
					8'h0E : begin
						character_w = 8'h20;
						address_w = 8'h0F;
						o_address_w = 8'h0E;
					end
					8'h0F : begin
						character_w = 8'h20;
						address_w = 8'h40;
						o_address_w = 8'h0F;
					end
					8'h40 : begin
						character_w = 8'h20;
						address_w = 8'h41;
						o_address_w = 8'h40;
					end
					8'h41 : begin
						character_w = 8'h20;
						address_w = 8'h42;
						o_address_w = 8'h41;
					end
					8'h42 : begin
						character_w = 8'h4C;
						address_w = 8'h43;
						o_address_w = 8'h42;
					end
					8'h43 : begin
						character_w = 8'h41;
						address_w = 8'h44;
						o_address_w = 8'h43;
					end
					8'h44 : begin
						character_w = 8'h42;
						address_w = 8'h45;
						o_address_w = 8'h44;
					end
					8'h45 : begin
						character_w = 8'h33;
						address_w = 8'h46;
						o_address_w = 8'h45;
					end
					8'h46 : begin
						character_w = 8'h20;
						address_w = 8'h47;
						o_address_w = 8'h46;
					end
					8'h47 : begin
						character_w = 8'h20;
						address_w = 8'h48;
						o_address_w = 8'h47;
					end
					8'h48 : begin
						character_w = 8'h21;
						address_w = 8'h49;
						o_address_w = 8'h48;
					end
					8'h49 : begin
						character_w = 8'h21;
						address_w = 8'h4A;
						o_address_w = 8'h49;
					end
					8'h4A : begin
						character_w = 8'h21;
						address_w = 8'h4B;
						o_address_w = 8'h4A;
					end
					8'h4B : begin
						character_w = 8'h51;
						address_w = 8'h4C;
						o_address_w = 8'h4B;
					end
					8'h4C : begin
						character_w = 8'h41;
						address_w = 8'h4D;
						o_address_w = 8'h4C;
					end
					8'h4D : begin
						character_w = 8'h51;
						address_w = 8'h4E;
						o_address_w = 8'h4D;
					end
					8'h4E : begin
						character_w = 8'h20;
						address_w = 8'h4F;
						o_address_w = 8'h4E;
					end
					8'h4F : begin
						character_w = 8'h20;
						o_address_w = 8'h4F;
						state_w = CHOOSE_STATE;
					end
				endcase
			end else begin
			end
		end*/
		LCD_S_RECD : begin
			if (busy) begin
				start_w = 0;
			end else if (!start_r) begin
				start_w = 1;
				case (address_r)
					8'h00 : begin
						character_w = 8'h52;
						address_w = 8'h01;
						o_address_w = 8'h00;
					end
					8'h01 : begin
						character_w = 8'h65;
						address_w = 8'h02;
						o_address_w = 8'h01;
					end
					8'h02 : begin
						character_w = 8'h63;
						address_w = 8'h03;
						o_address_w = 8'h02;
					end
					8'h03 : begin
						character_w = 8'h6F;
						address_w = 8'h04;
						o_address_w = 8'h03;
					end
					8'h04 : begin
						character_w = 8'h72;
						address_w = 8'h05;
						o_address_w = 8'h04;
					end
					8'h05 : begin
						character_w = 8'h64;
						address_w = 8'h06;
						o_address_w = 8'h05;
					end
					8'h06 : begin
						character_w = 8'h69;
						address_w = 8'h07;
						o_address_w = 8'h06;
					end
					8'h07 : begin
						character_w = 8'h6E;
						address_w = 8'h08;
						o_address_w = 8'h07;
					end
					8'h08 : begin
						character_w = 8'h67;
						address_w = 8'h09;
						o_address_w = 8'h08;
					end
					8'h09 : begin
						character_w = 8'h2E;
						address_w = 8'h0A;
						o_address_w = 8'h09;
					end
					8'h0A : begin
						character_w = 8'h2E;
						address_w = 8'h0B;
						o_address_w = 8'h0A;
					end
					8'h0B : begin
						character_w = 8'h2E;
						address_w = 8'h0C;
						o_address_w = 8'h0B;
					end
					8'h0C : begin
						character_w = 8'h20;
						address_w = 8'h0D;
						o_address_w = 8'h0C;
					end
					8'h0D : begin
						character_w = 8'h20;
						address_w = 8'h0E;
						o_address_w = 8'h0D;
					end
					8'h0E : begin
						character_w = 8'h20;
						address_w = 8'h0F;
						o_address_w = 8'h0E;
					end
					8'h0F : begin
						character_w = 8'h20;
						address_w = 8'h40;
						o_address_w = 8'h0F;
					end
					8'h40 : begin
						character_w = 8'h20;
						address_w = 8'h41;
						o_address_w = 8'h40;
					end
					8'h41 : begin
						character_w = 8'h20;
						address_w = 8'h42;
						o_address_w = 8'h41;
					end
					8'h42 : begin
						character_w = 8'h20;
						address_w = 8'h43;
						o_address_w = 8'h42;
					end
					8'h43 : begin
						character_w = 8'h20;
						address_w = 8'h44;
						o_address_w = 8'h43;
					end
					8'h44 : begin
						character_w = 8'h20;
						address_w = 8'h45;
						o_address_w = 8'h44;
					end
					8'h45 : begin
						character_w = 8'h20;
						address_w = 8'h46;
						o_address_w = 8'h45;
					end
					8'h46 : begin
						character_w = 8'h20;
						address_w = 8'h47;
						o_address_w = 8'h46;
					end
					8'h47 : begin
						character_w = 8'h20;
						address_w = 8'h48;
						o_address_w = 8'h47;
					end
					8'h48 : begin
						character_w = 8'h20;
						address_w = 8'h49;
						o_address_w = 8'h48;
					end
					8'h49 : begin
						character_w = 8'h20;
						address_w = 8'h4A;
						o_address_w = 8'h49;
					end
					8'h4A : begin
						character_w = 8'h20;
						address_w = 8'h4B;
						o_address_w = 8'h4A;
					end
					8'h4B : begin
						character_w = 8'h20;
						address_w = 8'h4C;
						o_address_w = 8'h4B;
					end
					8'h4C : begin
						character_w = 8'h20;
						address_w = 8'h4D;
						o_address_w = 8'h4C;
					end
					8'h4D : begin
						character_w = 8'h20;
						address_w = 8'h4E;
						o_address_w = 8'h4D;
					end
					8'h4E : begin
						character_w = 8'h20;
						address_w = 8'h4F;
						o_address_w = 8'h4E;
					end
					8'h4F : begin
						character_w = 8'h20;
						o_address_w = 8'h4F;
						LCD_state_w = LCD_CHOOSE_STATE;
					end
				endcase
			end else begin
			end
		end
		LCD_S_RECD_PAUSE : begin
			if (busy) begin
				start_w = 0;
			end else if (!start_r) begin
				start_w = 1;
				case (address_r)
					8'h00 : begin
						character_w = 8'h52;
						address_w = 8'h01;
						o_address_w = 8'h00;
					end
					8'h01 : begin
						character_w = 8'h65;
						address_w = 8'h02;
						o_address_w = 8'h01;
					end
					8'h02 : begin
						character_w = 8'h63;
						address_w = 8'h03;
						o_address_w = 8'h02;
					end
					8'h03 : begin
						character_w = 8'h6F;
						address_w = 8'h04;
						o_address_w = 8'h03;
					end
					8'h04 : begin
						character_w = 8'h72;
						address_w = 8'h05;
						o_address_w = 8'h04;
					end
					8'h05 : begin
						character_w = 8'h64;
						address_w = 8'h06;
						o_address_w = 8'h05;
					end
					8'h06 : begin
						character_w = 8'h69;
						address_w = 8'h07;
						o_address_w = 8'h06;
					end
					8'h07 : begin
						character_w = 8'h6E;
						address_w = 8'h08;
						o_address_w = 8'h07;
					end
					8'h08 : begin
						character_w = 8'h67;
						address_w = 8'h09;
						o_address_w = 8'h08;
					end
					8'h09 : begin
						character_w = 8'h20;
						address_w = 8'h0A;
						o_address_w = 8'h09;
					end
					8'h0A : begin
						character_w = 8'h50;
						address_w = 8'h0B;
						o_address_w = 8'h0A;
					end
					8'h0B : begin
						character_w = 8'h41;
						address_w = 8'h0C;
						o_address_w = 8'h0B;
					end
					8'h0C : begin
						character_w = 8'h55;
						address_w = 8'h0D;
						o_address_w = 8'h0C;
					end
					8'h0D : begin
						character_w = 8'h53;
						address_w = 8'h0E;
						o_address_w = 8'h0D;
					end
					8'h0E : begin
						character_w = 8'h45;
						address_w = 8'h0F;
						o_address_w = 8'h0E;
					end
					8'h0F : begin
						character_w = 8'h20;
						address_w = 8'h40;
						o_address_w = 8'h0F;
					end
					8'h40 : begin
						character_w = 8'h20;
						address_w = 8'h41;
						o_address_w = 8'h40;
					end
					8'h41 : begin
						character_w = 8'h20;
						address_w = 8'h42;
						o_address_w = 8'h41;
					end
					8'h42 : begin
						character_w = 8'h20;
						address_w = 8'h43;
						o_address_w = 8'h42;
					end
					8'h43 : begin
						character_w = 8'h20;
						address_w = 8'h44;
						o_address_w = 8'h43;
					end
					8'h44 : begin
						character_w = 8'h20;
						address_w = 8'h45;
						o_address_w = 8'h44;
					end
					8'h45 : begin
						character_w = 8'h20;
						address_w = 8'h46;
						o_address_w = 8'h45;
					end
					8'h46 : begin
						character_w = 8'h20;
						address_w = 8'h47;
						o_address_w = 8'h46;
					end
					8'h47 : begin
						character_w = 8'h20;
						address_w = 8'h48;
						o_address_w = 8'h47;
					end
					8'h48 : begin
						character_w = 8'h20;
						address_w = 8'h49;
						o_address_w = 8'h48;
					end
					8'h49 : begin
						character_w = 8'h20;
						address_w = 8'h4A;
						o_address_w = 8'h49;
					end
					8'h4A : begin
						character_w = 8'h20;
						address_w = 8'h4B;
						o_address_w = 8'h4A;
					end
					8'h4B : begin
						character_w = 8'h20;
						address_w = 8'h4C;
						o_address_w = 8'h4B;
					end
					8'h4C : begin
						character_w = 8'h20;
						address_w = 8'h4D;
						o_address_w = 8'h4C;
					end
					8'h4D : begin
						character_w = 8'h20;
						address_w = 8'h4E;
						o_address_w = 8'h4D;
					end
					8'h4E : begin
						character_w = 8'h20;
						address_w = 8'h4F;
						o_address_w = 8'h4E;
					end
					8'h4F : begin
						character_w = 8'h20;
						o_address_w = 8'h4F;
						LCD_state_w = LCD_CHOOSE_STATE;
					end
				endcase
			end else begin
			end
		end
		LCD_S_PLAY : begin
			if (busy) begin
				start_w = 0;
			end else if (!start_r) begin
				start_w = 1;
				case (address_r)
					8'h00 : begin
						character_w = 8'h50;
						address_w = 8'h01;
						o_address_w = 8'h00;
					end
					8'h01 : begin
						character_w = 8'h6C;
						address_w = 8'h02;
						o_address_w = 8'h01;
					end
					8'h02 : begin
						character_w = 8'h61;
						address_w = 8'h03;
						o_address_w = 8'h02;
					end
					8'h03 : begin
						character_w = 8'h79;
						address_w = 8'h04;
						o_address_w = 8'h03;
					end
					8'h04 : begin
						character_w = 8'h69;
						address_w = 8'h05;
						o_address_w = 8'h04;
					end
					8'h05 : begin
						character_w = 8'h6E;
						address_w = 8'h06;
						o_address_w = 8'h05;
					end
					8'h06 : begin
						character_w = 8'h67;
						address_w = 8'h07;
						o_address_w = 8'h06;
					end
					8'h07 : begin
						character_w = 8'h2E;
						address_w = 8'h08;
						o_address_w = 8'h07;
					end
					8'h08 : begin
						character_w = 8'h2E;
						address_w = 8'h09;
						o_address_w = 8'h08;
					end
					8'h09 : begin
						character_w = 8'h2E;
						address_w = 8'h0A;
						o_address_w = 8'h09;
					end
					8'h0A : begin
						character_w = 8'h20;
						address_w = 8'h0B;
						o_address_w = 8'h0A;
					end
					8'h0B : begin
						character_w = 8'h20;
						address_w = 8'h0C;
						o_address_w = 8'h0B;
					end
					8'h0C : begin
						character_w = 8'h20;
						address_w = 8'h0D;
						o_address_w = 8'h0C;
					end
					8'h0D : begin
						character_w = 8'h20;
						address_w = 8'h0E;
						o_address_w = 8'h0D;
					end
					8'h0E : begin
						character_w = 8'h20;
						address_w = 8'h0F;
						o_address_w = 8'h0E;
					end
					8'h0F : begin
						character_w = 8'h20;
						address_w = 8'h40;
						o_address_w = 8'h0F;
					end
					8'h40 : begin
						character_w = 8'h53;
						address_w = 8'h41;
						o_address_w = 8'h40;
					end
					8'h41 : begin
						character_w = 8'h70;
						address_w = 8'h42;
						o_address_w = 8'h41;
					end
					8'h42 : begin
						character_w = 8'h65;
						address_w = 8'h43;
						o_address_w = 8'h42;
					end
					8'h43 : begin
						character_w = 8'h65;
						address_w = 8'h44;
						o_address_w = 8'h43;
					end
					8'h44 : begin
						character_w = 8'h64;
						address_w = 8'h45;
						o_address_w = 8'h44;
					end
					8'h45 : begin
						character_w = 8'h20;
						address_w = 8'h46;
						o_address_w = 8'h45;
					end
					8'h46 : begin
						character_w = 8'h3A;
						address_w = 8'h47;
						o_address_w = 8'h46;
					end
					8'h47 : begin
						character_w = 8'h20;
						address_w = 8'h48;
						o_address_w = 8'h47;
					end
					8'h48 : begin
						if (DSP_fast) begin 
							case (i_speed)
								5'd1 : character_w = 8'h31;
								5'd2 : character_w = 8'h32;
								5'd3 : character_w = 8'h33;
								5'd4 : character_w = 8'h34;
								5'd5 : character_w = 8'h35;
								5'd6 : character_w = 8'h36;
								5'd7 : character_w = 8'h37;
								5'd8 : character_w = 8'h38;
								default : character_w = 8'h30;
							endcase
						end else if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h31;
						end else begin
							character_w = 8'h31;
						end
						address_w = 8'h49;
						o_address_w = 8'h48;
					end
					8'h49 : begin
						if (DSP_fast) begin 
							character_w = 8'h78;
						end else if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h2F;
						end else begin
							character_w = 8'h78;
						end
						address_w = 8'h4A;
						o_address_w = 8'h49;
					end
					8'h4A : begin
						if (DSP_slow_0 || DSP_slow_1) begin
							case (i_speed)
								5'd1 : character_w = 8'h31;
								5'd2 : character_w = 8'h32;
								5'd3 : character_w = 8'h33;
								5'd4 : character_w = 8'h34;
								5'd5 : character_w = 8'h35;
								5'd6 : character_w = 8'h36;
								5'd7 : character_w = 8'h37;
								5'd8 : character_w = 8'h38;
								default : character_w = 8'h30;
							endcase
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4B;
						o_address_w = 8'h4A;
					end
					8'h4B : begin
						if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h78;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4C;
						o_address_w = 8'h4B;
					end
					8'h4C : begin
						if (DSP_fast || DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h28;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4D;
						o_address_w = 8'h4C;
					end
					8'h4D : begin
						if (DSP_fast) begin 
							character_w = 8'h46;
						end else if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h53;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4E;
						o_address_w = 8'h4D;
					end
					8'h4E : begin
						if (DSP_slow_0) begin 
							character_w = 8'h30;
						end else if (DSP_slow_1) begin
							character_w = 8'h31;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4F;
						o_address_w = 8'h4E;
					end
					8'h4F : begin
						if (DSP_fast || DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h29;
						end else begin
							character_w = 8'h20;
						end
						o_address_w = 8'h4F;
						LCD_state_w = LCD_CHOOSE_STATE;
					end
				endcase
			end else begin
			end
		end
		LCD_S_PLAY_PAUSE : begin
			if (busy) begin
				start_w = 0;
			end else if (!start_r) begin
				start_w = 1;
				case (address_r)
					8'h00 : begin
						character_w = 8'h50;
						address_w = 8'h01;
						o_address_w = 8'h00;
					end
					8'h01 : begin
						character_w = 8'h6C;
						address_w = 8'h02;
						o_address_w = 8'h01;
					end
					8'h02 : begin
						character_w = 8'h61;
						address_w = 8'h03;
						o_address_w = 8'h02;
					end
					8'h03 : begin
						character_w = 8'h79;
						address_w = 8'h04;
						o_address_w = 8'h03;
					end
					8'h04 : begin
						character_w = 8'h69;
						address_w = 8'h05;
						o_address_w = 8'h04;
					end
					8'h05 : begin
						character_w = 8'h6E;
						address_w = 8'h06;
						o_address_w = 8'h05;
					end
					8'h06 : begin
						character_w = 8'h67;
						address_w = 8'h07;
						o_address_w = 8'h06;
					end
					8'h07 : begin
						character_w = 8'h20;
						address_w = 8'h08;
						o_address_w = 8'h07;
					end
					8'h08 : begin
						character_w = 8'h20;
						address_w = 8'h09;
						o_address_w = 8'h08;
					end
					8'h09 : begin
						character_w = 8'h50;
						address_w = 8'h0A;
						o_address_w = 8'h09;
					end
					8'h0A : begin
						character_w = 8'h41;
						address_w = 8'h0B;
						o_address_w = 8'h0A;
					end
					8'h0B : begin
						character_w = 8'h55;
						address_w = 8'h0C;
						o_address_w = 8'h0B;
					end
					8'h0C : begin
						character_w = 8'h53;
						address_w = 8'h0D;
						o_address_w = 8'h0C;
					end
					8'h0D : begin
						character_w = 8'h45;
						address_w = 8'h0E;
						o_address_w = 8'h0D;
					end
					8'h0E : begin
						character_w = 8'h20;
						address_w = 8'h0F;
						o_address_w = 8'h0E;
					end
					8'h0F : begin
						character_w = 8'h20;
						address_w = 8'h40;
						o_address_w = 8'h0F;
					end
					8'h40 : begin
						character_w = 8'h53;
						address_w = 8'h41;
						o_address_w = 8'h40;
					end
					8'h41 : begin
						character_w = 8'h70;
						address_w = 8'h42;
						o_address_w = 8'h41;
					end
					8'h42 : begin
						character_w = 8'h65;
						address_w = 8'h43;
						o_address_w = 8'h42;
					end
					8'h43 : begin
						character_w = 8'h65;
						address_w = 8'h44;
						o_address_w = 8'h43;
					end
					8'h44 : begin
						character_w = 8'h64;
						address_w = 8'h45;
						o_address_w = 8'h44;
					end
					8'h45 : begin
						character_w = 8'h20;
						address_w = 8'h46;
						o_address_w = 8'h45;
					end
					8'h46 : begin
						character_w = 8'h3A;
						address_w = 8'h47;
						o_address_w = 8'h46;
					end
					8'h47 : begin
						character_w = 8'h20;
						address_w = 8'h48;
						o_address_w = 8'h47;
					end
					8'h48 : begin
						if (DSP_fast) begin 
							case (i_speed)
								5'd1 : character_w = 8'h31;
								5'd2 : character_w = 8'h32;
								5'd3 : character_w = 8'h33;
								5'd4 : character_w = 8'h34;
								5'd5 : character_w = 8'h35;
								5'd6 : character_w = 8'h36;
								5'd7 : character_w = 8'h37;
								5'd8 : character_w = 8'h38;
								default : character_w = 8'h30;
							endcase
						end else if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h31;
						end else begin
							character_w = 8'h31;
						end
						address_w = 8'h49;
						o_address_w = 8'h48;
					end
					8'h49 : begin
						if (DSP_fast) begin 
							character_w = 8'h78;
						end else if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h2F;
						end else begin
							character_w = 8'h78;
						end
						address_w = 8'h4A;
						o_address_w = 8'h49;
					end
					8'h4A : begin
						if (DSP_slow_0 || DSP_slow_1) begin
							case (i_speed)
								5'd1 : character_w = 8'h31;
								5'd2 : character_w = 8'h32;
								5'd3 : character_w = 8'h33;
								5'd4 : character_w = 8'h34;
								5'd5 : character_w = 8'h35;
								5'd6 : character_w = 8'h36;
								5'd7 : character_w = 8'h37;
								5'd8 : character_w = 8'h38;
								default : character_w = 8'h30;
							endcase
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4B;
						o_address_w = 8'h4A;
					end
					8'h4B : begin
						if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h78;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4C;
						o_address_w = 8'h4B;
					end
					8'h4C : begin
						if (DSP_fast || DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h28;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4D;
						o_address_w = 8'h4C;
					end
					8'h4D : begin
						if (DSP_fast) begin 
							character_w = 8'h46;
						end else if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h53;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4E;
						o_address_w = 8'h4D;
					end
					8'h4E : begin
						if (DSP_slow_0) begin 
							character_w = 8'h30;
						end else if (DSP_slow_1) begin
							character_w = 8'h31;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4F;
						o_address_w = 8'h4E;
					end
					8'h4F : begin
						if (DSP_fast || DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h29;
						end else begin
							character_w = 8'h20;
						end
						o_address_w = 8'h4F;
						LCD_state_w = LCD_CHOOSE_STATE;
					end
				endcase
			end else begin
			end
		end
		LCD_S_I2C_FIN : begin
			if (busy) begin
				start_w = 0;
			end else if (!start_r) begin
				start_w = 1;
				case (address_r)
					8'h00 : begin
						character_w = 8'h54;
						address_w = 8'h01;
						o_address_w = 8'h00;
					end
					8'h01 : begin
						character_w = 8'h68;
						address_w = 8'h02;
						o_address_w = 8'h01;
					end
					8'h02 : begin
						character_w = 8'h69;
						address_w = 8'h03;
						o_address_w = 8'h02;
					end
					8'h03 : begin
						character_w = 8'h73;
						address_w = 8'h04;
						o_address_w = 8'h03;
					end
					8'h04 : begin
						character_w = 8'h20;
						address_w = 8'h05;
						o_address_w = 8'h04;
					end
					8'h05 : begin
						character_w = 8'h69;
						address_w = 8'h06;
						o_address_w = 8'h05;
					end
					8'h06 : begin
						character_w = 8'h73;
						address_w = 8'h07;
						o_address_w = 8'h06;
					end
					8'h07 : begin
						character_w = 8'h20;
						address_w = 8'h08;
						o_address_w = 8'h07;
					end
					8'h08 : begin
						character_w = 8'h4C;
						address_w = 8'h09;
						o_address_w = 8'h08;
					end
					8'h09 : begin
						character_w = 8'h41;
						address_w = 8'h0A;
						o_address_w = 8'h09;
					end
					8'h0A : begin
						character_w = 8'h42;
						address_w = 8'h0B;
						o_address_w = 8'h0A;
					end
					8'h0B : begin
						character_w = 8'h33;
						address_w = 8'h0C;
						o_address_w = 8'h0B;
					end
					8'h0C : begin
						character_w = 8'h20;
						address_w = 8'h0D;
						o_address_w = 8'h0C;
					end
					8'h0D : begin
						character_w = 8'h57;
						address_w = 8'h0E;
						o_address_w = 8'h0D;
					end
					8'h0E : begin
						character_w = 8'h4F;
						address_w = 8'h0F;
						o_address_w = 8'h0E;
					end
					8'h0F : begin
						character_w = 8'h57;
						address_w = 8'h40;
						o_address_w = 8'h0F;
					end
					8'h40 : begin
						character_w = 8'h53;
						address_w = 8'h41;
						o_address_w = 8'h40;
					end
					8'h41 : begin
						character_w = 8'h70;
						address_w = 8'h42;
						o_address_w = 8'h41;
					end
					8'h42 : begin
						character_w = 8'h65;
						address_w = 8'h43;
						o_address_w = 8'h42;
					end
					8'h43 : begin
						character_w = 8'h65;
						address_w = 8'h44;
						o_address_w = 8'h43;
					end
					8'h44 : begin
						character_w = 8'h64;
						address_w = 8'h45;
						o_address_w = 8'h44;
					end
					8'h45 : begin
						character_w = 8'h20;
						address_w = 8'h46;
						o_address_w = 8'h45;
					end
					8'h46 : begin
						character_w = 8'h3A;
						address_w = 8'h47;
						o_address_w = 8'h46;
					end
					8'h47 : begin
						character_w = 8'h20;
						address_w = 8'h48;
						o_address_w = 8'h47;
					end
					8'h48 : begin
						if (DSP_fast) begin 
							case (i_speed)
								5'd1 : character_w = 8'h31;
								5'd2 : character_w = 8'h32;
								5'd3 : character_w = 8'h33;
								5'd4 : character_w = 8'h34;
								5'd5 : character_w = 8'h35;
								5'd6 : character_w = 8'h36;
								5'd7 : character_w = 8'h37;
								5'd8 : character_w = 8'h38;
								default : character_w = 8'h30;
							endcase
						end else if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h31;
						end else begin
							character_w = 8'h31;
						end
						address_w = 8'h49;
						o_address_w = 8'h48;
					end
					8'h49 : begin
						if (DSP_fast) begin 
							character_w = 8'h78;
						end else if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h2F;
						end else begin
							character_w = 8'h78;
						end
						address_w = 8'h4A;
						o_address_w = 8'h49;
					end
					8'h4A : begin
						if (DSP_slow_0 || DSP_slow_1) begin
							case (i_speed)
								5'd1 : character_w = 8'h31;
								5'd2 : character_w = 8'h32;
								5'd3 : character_w = 8'h33;
								5'd4 : character_w = 8'h34;
								5'd5 : character_w = 8'h35;
								5'd6 : character_w = 8'h36;
								5'd7 : character_w = 8'h37;
								5'd8 : character_w = 8'h38;
								default : character_w = 8'h30;
							endcase
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4B;
						o_address_w = 8'h4A;
					end
					8'h4B : begin
						if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h78;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4C;
						o_address_w = 8'h4B;
					end
					8'h4C : begin
						if (DSP_fast || DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h28;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4D;
						o_address_w = 8'h4C;
					end
					8'h4D : begin
						if (DSP_fast) begin 
							character_w = 8'h46;
						end else if (DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h53;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4E;
						o_address_w = 8'h4D;
					end
					8'h4E : begin
						if (DSP_slow_0) begin 
							character_w = 8'h30;
						end else if (DSP_slow_1) begin
							character_w = 8'h31;
						end else begin
							character_w = 8'h20;
						end
						address_w = 8'h4F;
						o_address_w = 8'h4E;
					end
					8'h4F : begin
						if (DSP_fast || DSP_slow_0 || DSP_slow_1) begin
							character_w = 8'h29;
						end else begin
							character_w = 8'h20;
						end
						o_address_w = 8'h4F;
						LCD_state_w = LCD_CHOOSE_STATE;
					end
				endcase
			end else begin
			end
		end
		default : begin
		end
	endcase
end

always_ff @(posedge i_clk_800k or negedge i_rst_n) begin
	if (!i_rst_n) begin
		start_r <= 1'b0;
		LCD_state_r <= LCD_CHOOSE_STATE;
		curr_state_r <= S_I2C_FIN;
		character_r <= 8'b0;
		address_r <= 8'b0;
		o_address_r <= 8'b0;
	end
	else begin
		start_r <= start_w;
		LCD_state_r <= LCD_state_w;
		curr_state_r <= curr_state_w;
		character_r <= character_w;
		address_r <= address_w;
		o_address_r <= o_address_w;
	end
end
 
endmodule
 