module Square # (
    parameter y_idle,	// bottom y
    parameter x_idle, 	// center x
    parameter size
)(	
    input clk,
    input rst_n,
	input [9:0] i_x_cord,
    input [9:0] i_y_cord,

    input show,
    input hit,
    input jumping,	// whether Square is jumpinging

	input [9:0] height,	// height is positive, while "up" is negative

    output en
);  
	reg [2:0] cnt_r, cnt_w;
	reg [2:0] state_r, state_w;
	reg en_reg;
	parameter split = 5;
    assign en = en_reg;

    always_comb begin
    	if (i_x_cord == 10'd1 && i_y_cord == 10'd1) begin
    		if (cnt_r == split) cnt_w = 3'd0;
    		else cnt_w = cnt_r + 3'd1;

    		if (cnt_r == split) begin
    			if (state_r == 3'd7) state_w = 3'd0;
    			else state_w = state_r + 3'd1;
    		end
    		else state_w = state_r;
    	end
    	else begin
    		cnt_w = cnt_r;
    		state_w = state_r;
    	end

    	if (~show) en_reg = 1'b0;
    	else begin
    		case (state_r)
    			3'd0 : en_reg = (i_x_cord > x_idle - size && i_x_cord < x_idle + size && i_y_cord + height < y_idle && i_y_cord + height > y_idle - 2*size);
    			3'd1 : en_reg = (~hit && i_x_cord > x_idle - size - size / 8 && i_x_cord < x_idle + size + size / 8 && i_y_cord + height < y_idle && i_y_cord + height > y_idle - 2*size + size / 4);
    			3'd2 : en_reg = (i_x_cord > x_idle - size - size / 4 && i_x_cord < x_idle + size + size / 4 && i_y_cord + height < y_idle && i_y_cord + height > y_idle - 2*size + size / 2);
    			3'd3 : en_reg = (~hit && i_x_cord > x_idle - size - size / 8 && i_x_cord < x_idle + size + size / 8 && i_y_cord + height < y_idle && i_y_cord + height > y_idle - 2*size + size / 4);
    			3'd4 : en_reg = (i_x_cord > x_idle - size && i_x_cord < x_idle + size && i_y_cord + height < y_idle && i_y_cord + height > y_idle - 2*size);
    			3'd5 : en_reg = (~hit && i_x_cord > x_idle - size + size / 8 && i_x_cord < x_idle + size - size / 8 && i_y_cord + height < y_idle && i_y_cord + height > y_idle - 2*size - size / 4);
    			3'd6 : en_reg = (i_x_cord > x_idle - size + size / 4 && i_x_cord < x_idle + size - size / 4 && i_y_cord + height < y_idle && i_y_cord + height > y_idle - 2*size - size / 2);
    			3'd7 : en_reg = (~hit && i_x_cord > x_idle - size + size / 8 && i_x_cord < x_idle + size - size / 8 && i_y_cord + height < y_idle && i_y_cord + height > y_idle - 2*size - size / 4);
    			default : en_reg = (i_x_cord > x_idle - size && i_x_cord < x_idle + size && i_y_cord + height < y_idle && i_y_cord + height > y_idle - 2*size);
    		endcase // state_r
    	end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state_r <= 3'd0;
            cnt_r <= 3'd0;
        end
        else begin
            state_r <= state_w;
            cnt_r <= cnt_w;
        end
    end
endmodule