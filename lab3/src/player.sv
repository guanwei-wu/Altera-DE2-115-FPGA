module AudPlayer(
	input           i_rst_n,
	input           i_bclk,
	input           i_daclrck,
	input           i_en,
	input [15:0]    i_dac_data,
	output          o_aud_dacdat
);

localparam S_IDLE = 1'd0;
localparam S_PLAY = 1'd1; // send

logic        state, state_nxt;
logic [ 3:0] counter, counter_nxt; // count 16
logic [15:0] OAD, OAD_nxt; // o_aud_dacdat
//logic LRC, LRC_nxt;

assign o_aud_dacdat = OAD;

always_comb begin
    if (i_en) begin
        case(state)
            S_IDLE: begin
                if (/*LRC !=*/i_daclrck) begin //right side
                    state_nxt   = S_PLAY;
                    counter_nxt = 0;
                    OAD_nxt = i_dac_data[15];
                    //LRC_nxt = i_daclrck;
                end
                else begin
                    state_nxt   = S_IDLE;
                    counter_nxt = counter;
                    OAD_nxt = 0;
                    //LRC_nxt = i_daclrck;
                end
            end
            S_PLAY: begin
                if (counter == 15) begin
						  if (~i_daclrck) begin // check if right side end
								state_nxt   = S_IDLE;
								counter_nxt = 0;
								OAD_nxt = 0;
						  end
						  else begin
								state_nxt   = state;
								counter_nxt = counter;
								OAD_nxt = 0;
						  end
                    //LRC_nxt = i_daclrck;
                end
                else begin
                    state_nxt   = state;
                    counter_nxt = counter + 1;
                    OAD_nxt = i_dac_data[14-counter];
                    //LRC_nxt = i_daclrck;
                end
            end
            default: begin
					 state_nxt   = S_IDLE;
					 counter_nxt = counter;
                OAD_nxt = 0;
                //LRC_nxt = i_daclrck;
				end
        endcase
    end else begin
		  state_nxt   = S_IDLE;
		  counter_nxt = 0;
        OAD_nxt = 0;
	 end
end

always_ff @(negedge i_bclk or negedge i_rst_n) begin
	if (!i_rst_n) begin
      state <= S_IDLE;
		counter <= 0;
      OAD <= 0;
	   //LRC <= i_daclrck;
	end 
   else begin
      state <= state_nxt;
		counter <= counter_nxt;
      OAD <= OAD_nxt;
	   //LRC <= LRC_nxt;
	end
end

endmodule