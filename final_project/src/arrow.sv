module Arrow # (
    parameter x_idle,
    parameter y_idle,
    parameter size_arr
)(
	input [9:0] i_x_cord,
    input [9:0] i_y_cord,
    input clk,
    input rst_n,

    input show,
    input change,

    input [1:0] point,    

    output en
);
	reg [5:0] cnt_r, cnt_w;
	reg state_r, state_w;
	reg en_reg;
	parameter split = 10;
    assign en = en_reg;

    always_comb begin
    	if (i_x_cord == 10'd1 && i_y_cord == 10'd1) begin
			if (~change) begin
				cnt_w = 6'd0;
				state_w = 1'b0;
			end
			else begin
				if (cnt_r == split) begin
					cnt_w = 6'd0;
					state_w = ~state_r;
				end
				else begin
					cnt_w = cnt_r + 6'd1;
					state_w = state_r;
				end
			end
    	end
    	else begin
    		cnt_w = cnt_r;
    		state_w = state_r;
    	end
		
		if (~show) en_reg = 1'b0;
    	else if (state_r == 1'b0) begin
			case (point)
				2'd0 : en_reg = (i_y_cord < y_idle + 8*size_arr && i_y_cord > y_idle - 6*size_arr && i_x_cord < x_idle + size_arr && i_x_cord > x_idle - size_arr) || 
                                (i_y_cord < y_idle - 2*size_arr && i_y_cord > y_idle - 4*size_arr && i_x_cord <= x_idle + 2*size_arr && i_x_cord >= x_idle ) || 
                                (i_y_cord < y_idle - 2*size_arr && i_y_cord > y_idle - 4*size_arr && i_x_cord <= x_idle  && i_x_cord >= x_idle - 2*size_arr) || 
                                (i_y_cord < y_idle  && i_y_cord >= y_idle - 2*size_arr && i_x_cord < x_idle + 4*size_arr && i_x_cord >= x_idle + 2*size_arr) || 
                                (i_y_cord < y_idle  && i_y_cord >= y_idle - 2*size_arr && i_x_cord <= x_idle - 2*size_arr && i_x_cord > x_idle - 4*size_arr);
				2'd1 : en_reg = (i_y_cord < y_idle + 6*size_arr && i_y_cord > y_idle - 8*size_arr && i_x_cord < x_idle + size_arr && i_x_cord > x_idle - size_arr) || 
                                (i_y_cord < y_idle + 4*size_arr && i_y_cord > y_idle + 2*size_arr && i_x_cord <= x_idle + 2*size_arr && i_x_cord >= x_idle ) || 
                                (i_y_cord < y_idle + 4*size_arr && i_y_cord > y_idle + 2*size_arr && i_x_cord <= x_idle  && i_x_cord >= x_idle - 2*size_arr) || 
                                (i_y_cord <= y_idle + 2*size_arr && i_y_cord > y_idle && i_x_cord < x_idle + 4*size_arr && i_x_cord >= x_idle + 2*size_arr) || 
                                (i_y_cord <= y_idle + 2*size_arr && i_y_cord > y_idle && i_x_cord <= x_idle - 2*size_arr && i_x_cord > x_idle - 4*size_arr);
				2'd2 : en_reg = (i_y_cord < y_idle + size_arr && i_y_cord > y_idle - size_arr && i_x_cord < x_idle + 6*size_arr && i_x_cord > x_idle - 6*size_arr) || 
                                (i_y_cord <= y_idle + 2*size_arr && i_y_cord >= y_idle && i_x_cord < x_idle - 2*size_arr && i_x_cord > x_idle - 4*size_arr) || 
                                (i_y_cord <= y_idle  && i_y_cord >= y_idle - 2*size_arr && i_x_cord < x_idle - 2*size_arr && i_x_cord > x_idle - 4*size_arr) || 
                                (i_y_cord < y_idle + 4*size_arr && i_y_cord >= y_idle + 2*size_arr && i_x_cord < x_idle && i_x_cord >= x_idle - 2*size_arr) || 
                                (i_y_cord <= y_idle - 2*size_arr && i_y_cord > y_idle - 4*size_arr && i_x_cord < x_idle && i_x_cord >= x_idle - 2*size_arr);
				2'd3 : en_reg = (i_y_cord < y_idle + size_arr && i_y_cord > y_idle - size_arr && i_x_cord < x_idle + 6*size_arr && i_x_cord > x_idle - 6*size_arr) || 
                                (i_y_cord <= y_idle + 2*size_arr && i_y_cord >= y_idle && i_x_cord < x_idle + 4*size_arr && i_x_cord > x_idle + 2*size_arr) || 
                                (i_y_cord <= y_idle  && i_y_cord >= y_idle - 2*size_arr && i_x_cord < x_idle + 4*size_arr && i_x_cord > x_idle + 2*size_arr) || 
                                (i_y_cord <= y_idle + 4*size_arr && i_y_cord > y_idle + 2*size_arr && i_x_cord <= x_idle + 2*size_arr && i_x_cord > x_idle) || 
                                (i_y_cord <= y_idle - 2*size_arr && i_y_cord > y_idle - 4*size_arr && i_x_cord <= x_idle + 2*size_arr && i_x_cord > x_idle);
				default : en_reg = (i_y_cord < y_idle + size_arr && i_y_cord > y_idle - size_arr && i_x_cord < x_idle + size_arr && i_x_cord > x_idle - size_arr);
			endcase
    	end
    	else en_reg = 1'b0;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (~rst_n) begin
            state_r <= 1'b0;
            cnt_r <= 6'd0;
        end
        else begin
            state_r <= state_w;
            cnt_r <= cnt_w;
        end
    end
endmodule