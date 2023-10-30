module GameCore (
    input clk,
    input rst_n,
    input [9:0] i_x_cord,
    input [9:0] i_y_cord,

    input start,
    input jump,
    input [2:0] character,

    output [1:0] state,
    //----s0 and s1
    output [3:0] cnt_shot,
    //----s2
    output [1:0] life,
    output [13:0] score, //DE2_115
    output [13:0] high_score,

    output [1:0] character_vga,
    output [1:0] arr_point [0:3],
    output change_arr,
    
    output hit,
    output [9:0] sq_height [0:3], // square also need
    output jumping [0:3], // need more jumps [3:0]

    output [9:0] nd_x [0:5],  // nd_x = 0 won't show any needle
    output [1:0] nd_y [0:5],  // only record which strip it is
    output [9:0] nd_height [0:5]
);
	parameter cnt_shot_split = 120;
    reg [6:0] small_cnt_w, small_cnt_r;
    reg [3:0] cnt_shot_w, cnt_shot_r;
    assign cnt_shot = cnt_shot_r;

    reg [14:0] score_w, score_r;
    assign score = score_r >> 1;

    reg [14:0] high_score_w, high_score_r;
    assign high_score = high_score_r >> 1;

    wire new_shot;
    assign new_shot = (i_x_cord == 10'd1 && i_y_cord == 10'd1);

    reg [1:0] state_r, state_w;
    assign state = state_r;

    reg [1:0] arr_point_w [0:3];
    reg [1:0] arr_point_r [0:3];
    assign arr_point = arr_point_r;
    reg change_arr_r, change_arr_w;
    assign change_arr = change_arr_r;

    // assign arr_point [0] = 2'd0;
    // assign arr_point [1] = 2'd1;
    // assign arr_point [2] = 2'd2;
    // assign arr_point [3] = 2'd3;
    // assign change_arr = 1'b0;

    reg add_life_r, add_life_w;
	reg [1:0] life_r, life_w;
    assign life = life_r; 

    reg [9:0] speed_r, speed_w;
    // assign speed = (score_r < 2400) ? 10'd1 : ((score_r - 2400)/3000 + 10'd2);

	parameter hit_cnt_max = 120;
	reg [6:0] hit_cnt_r, hit_cnt_w;
    assign hit = (hit_cnt_r > 0);
	 
	 // character choice
	reg [1:0] character_w, character_r;
	assign character_vga = character_r;
	
	parameter x_sq = 60;   // x of square, should turn to upper parameter
    parameter size_sq = 16; // half len of square
    parameter jump_height = 50;
	 // 4 square
    reg [9:0] sq_height_w [0:3];
	reg [9:0] sq_height_r [0:3];
    reg is_up_w [0:3];
	reg is_up_r [0:3];
    assign sq_height [0] = sq_height_r[0];
    assign sq_height [1] = sq_height_r[1];
    assign sq_height [2] = sq_height_r[2];
    assign sq_height [3] = sq_height_r[3];

    assign jumping [0] = sq_height_r[0] > 10'd0;
    assign jumping [1] = sq_height_r[1] > 10'd0;
    assign jumping [2] = sq_height_r[2] > 10'd0;
    assign jumping [3] = sq_height_r[3] > 10'd0;

    parameter random_prob = 1000;	// p = 20% for not gen 
    reg [9:0] random_w, random_r;
    parameter min_nd_span = 120;
    parameter max_nd_height = 15;
    parameter min_nd_height = 5;
    wire [9:0] random;
    assign random = (random_r * cnt_shot_r) % 1024;	//

    reg [9:0] nd_x_w [0:5];
    reg [9:0] nd_x_r [0:5];
    reg [9:0] nd_y_w [0:5];
    reg [9:0] nd_y_r [0:5];
    reg [9:0] nd_height_w [0:5];
    reg [9:0] nd_height_r [0:5];

    assign nd_x = nd_x_r;
    assign nd_y = nd_y_r;
    assign nd_height = nd_height_r;


    // assign nd_x [0] = 10'd200;//X
    // assign nd_x [1] = 10'd200;//X
    // assign nd_x [2] = 10'd300;//X
    // assign nd_x [3] = 10'd400;//X
    // assign nd_x [4] = 10'd500;//X
// 
    // assign nd_y [0] = 2'd0;//X
    // assign nd_y [1] = 2'd1;//X
    // assign nd_y [2] = 2'd1;//X
    // assign nd_y [3] = 2'd2;//X
    // assign nd_y [4] = 2'd3;//X
// 
    // assign nd_height [0] = 10'd12;//X
    // assign nd_height [1] = 10'd5;//X
    // assign nd_height [2] = 10'd10;//X
    // assign nd_height [3] = 10'd15;//X
    // assign nd_height [4] = 10'd20;//X


    always_comb begin

    	if (state_r == 2'd2) begin
    		if (score_r % 3750 > 3500) begin
    			change_arr_w = 1'b1;
    			arr_point_w = arr_point_r;
    		end 
    		else if (change_arr_r && !jumping[0] && !jumping[1] && !jumping[2] && !jumping[3]) begin
    			change_arr_w = 1'b0;

    			arr_point_w [0] = random_r [1:0];

    			case (random_r [3:2])
    				2'd0 : begin
    					arr_point_w [1] = random_r [1:0] + 2'd1;
    					arr_point_w [2] = random_r [1:0] + 2'd2;
    					arr_point_w [3] = random_r [1:0] + 2'd3;
    				end
    				2'd1 : begin
    					arr_point_w [1] = random_r [1:0] + 2'd2;
    					arr_point_w [2] = random_r [1:0] + 2'd3;
    					arr_point_w [3] = random_r [1:0] + 2'd1;
    				end
    				2'd2 : begin
    					arr_point_w [1] = random_r [1:0] + 2'd3;
    					arr_point_w [2] = random_r [1:0] + 2'd1;
    					arr_point_w [3] = random_r [1:0] + 2'd2;
    				end
    				2'd3 : begin
    					arr_point_w [1] = random_r [1:0] + 2'd1;
    					arr_point_w [2] = random_r [1:0] + 2'd3;
    					arr_point_w [3] = random_r [1:0] + 2'd2;
    				end
    			endcase
    		end
    		else begin
    			change_arr_w = change_arr_r;
    			arr_point_w = arr_point_r;
    		end
    	end
    	else begin
    		change_arr_w = 1'b0;
    		arr_point_w [0] = 2'd0;
    		arr_point_w [1] = 2'd1;
    		arr_point_w [2] = 2'd2;
    		arr_point_w [3] = 2'd3;
    	end

    	if (state_r == 2'd2) begin
    		if (new_shot) begin
    			if (score_r < 2400) begin 
    				speed_w = 10'd1;
    				add_life_w = 1'b0;
    			end
    			else if (jumping[0] || jumping[1] || jumping[2] || jumping[3]) begin 
    				speed_w = speed_r;
    				add_life_w = 1'b0;
    			end
    			else if (((score_r - 2400)/2700 + 10'd2) > speed_r) begin
    				speed_w = speed_r + 10'd1;
    				add_life_w = 1'b1;
    			end
    			else begin 
    				add_life_w = 1'b0;
    				speed_w = speed_r;
    			end
    		end
    		else begin
    			speed_w = speed_r;
    			add_life_w = add_life_r;
    		end
    	end
    	else begin 
    		speed_w = 10'd1;
    		add_life_w = 1'b0;
    	end


    	if (state_r == 2'd1) begin
    		score_w = 15'd0;
    	end
    	else if (state_r == 2'd2) begin
    		if (new_shot) score_w = score_r + 15'd1;
    		else score_w = score_r;
    	end
    	else begin
    		score_w = score_r;
    	end

    	if (state_r == 2'd0) begin
    		high_score_w = (score_r > high_score_r) ? score_r : high_score_r;
    	end
    	else begin
    		high_score_w = high_score_r;
    	end

    	//----nd_x
    	if (state_r == 2'd2) begin
    		if (new_shot) begin
    			if (nd_x_r[0] <= 10'd7) begin
    				nd_x_w [0] = nd_x_r [1];
    				nd_x_w [1] = nd_x_r [2];
    				nd_x_w [2] = nd_x_r [3];
    				nd_x_w [3] = nd_x_r [4];
    				nd_x_w [4] = nd_x_r [5];
    				nd_x_w [5] = 10'd0;
    			end
    			else begin
    				nd_x_w [0] = nd_x_r [0] - speed_r;
    				nd_x_w [1] = nd_x_r [1] - speed_r;
    				nd_x_w [2] = nd_x_r [2] - speed_r;
    				nd_x_w [3] = nd_x_r [3] - speed_r;
    				nd_x_w [4] = nd_x_r [4] - speed_r;
    				nd_x_w [5] = nd_x_r [5] - speed_r;
	
    				if (nd_x_r [4] > 600 - min_nd_span) nd_x_w [5] = 10'd0;
    				else if (nd_x_r [5] == 10'd0) begin
    					if (random > random_prob) nd_x_w [5] = 10'd599;
    					else nd_x_w [5] = 10'd0;
    				end
    				else nd_x_w [5] = nd_x_r [5] - speed_r;
    			end
    		end
    		else begin
    			nd_x_w [0] = nd_x_r [0];
				nd_x_w [1] = nd_x_r [1];
				nd_x_w [2] = nd_x_r [2];
				nd_x_w [3] = nd_x_r [3];
				nd_x_w [4] = nd_x_r [4];
				nd_x_w [5] = nd_x_r [5];
    		end
    	end
    	else begin
    		nd_x_w [0] = 10'd99;
    		nd_x_w [1] = 10'd199;
    		nd_x_w [2] = 10'd299;
    		nd_x_w [3] = 10'd399;
    		nd_x_w [4] = 10'd499;
    		nd_x_w [5] = 10'd599;
    	end

    	//----nd_y
    	if (state_r == 2'd2) begin
    		if (new_shot) begin
				if (nd_x_r[0] <= 10'd7) begin
    				nd_y_w [0] = nd_y_r [1];
    				nd_y_w [1] = nd_y_r [2];
    				nd_y_w [2] = nd_y_r [3];
    				nd_y_w [3] = nd_y_r [4];
    				nd_y_w [4] = nd_y_r [5];
    				nd_y_w [5] = random % 4;
    				nd_height_w [0] = nd_height_r [1];
					nd_height_w [1] = nd_height_r [2];
					nd_height_w [2] = nd_height_r [3];
					nd_height_w [3] = nd_height_r [4];
					nd_height_w [4] = nd_height_r [5];
					nd_height_w [5] = (random % max_nd_height) + min_nd_height;
    			end
    			else begin
    				nd_y_w [0] = nd_y_r [0];
					nd_y_w [1] = nd_y_r [1];
					nd_y_w [2] = nd_y_r [2];
					nd_y_w [3] = nd_y_r [3];
					nd_y_w [4] = nd_y_r [4];
					nd_y_w [5] = nd_y_r [5];
					nd_height_w [0] = nd_height_r [0];
					nd_height_w [1] = nd_height_r [1];
					nd_height_w [2] = nd_height_r [2];
					nd_height_w [3] = nd_height_r [3];
					nd_height_w [4] = nd_height_r [4];
					nd_height_w [5] = nd_height_r [5];
    			end
    		end
    		else begin
    			nd_y_w [0] = nd_y_r [0];
				nd_y_w [1] = nd_y_r [1];
				nd_y_w [2] = nd_y_r [2];
				nd_y_w [3] = nd_y_r [3];
				nd_y_w [4] = nd_y_r [4];
				nd_y_w [5] = nd_y_r [5];
				nd_height_w [0] = nd_height_r [0];
				nd_height_w [1] = nd_height_r [1];
				nd_height_w [2] = nd_height_r [2];
				nd_height_w [3] = nd_height_r [3];
				nd_height_w [4] = nd_height_r [4];
				nd_height_w [5] = nd_height_r [5];
    		end
    	end
    	else begin
    		nd_y_w [0] = 2'd0;
			nd_y_w [1] = 2'd0;
			nd_y_w [2] = 2'd0;
			nd_y_w [3] = 2'd0;
			nd_y_w [4] = 2'd0;
			nd_y_w [5] = 2'd0;
			nd_height_w [0] = 10'd0;
			nd_height_w [1] = 10'd0;
			nd_height_w [2] = 10'd0;
			nd_height_w [3] = 10'd0;
			nd_height_w [4] = 10'd0;
			nd_height_w [5] = 10'd0;
    	end

        //----hit
		if (state_r == 2'd2) begin 
			if (new_shot) begin
				if (character == 3'd6) begin
					hit_cnt_w = hit_cnt_r;
					if (life_r == 2'd3) life_w = life_r;
					else life_w = life_r + 2'd1;
				end
				else if (character == 3'd7) begin
					hit_cnt_w = hit_cnt_r;
					life_w = life_r - 2'd1;
				end
				else if (add_life_r) begin
					hit_cnt_w = hit_cnt_r;
					if (life_r == 2'd3) life_w = life_r;
					else life_w = life_r + 2'd1;
				end
				else if (hit_cnt_r > 7'd0) begin
					if (hit_cnt_r < hit_cnt_max) begin
						hit_cnt_w = hit_cnt_r + 7'd1;
						life_w = life_r;
					end
					else begin
						hit_cnt_w = 7'd0;
						life_w = life_r;
					end
				end
				else if ((nd_x [0] < x_sq + size_sq) && (nd_x [0] > x_sq - size_sq)) begin // OK
					case (nd_y [0])
						2'd0 : begin
							if(sq_height[0] < nd_height[0]) begin
								hit_cnt_w = 7'd1;
								life_w = life_r - 2'd1;
							end else begin
								hit_cnt_w = hit_cnt_r;
								life_w = life_r;
							end
						end
						2'd1 : begin
							if(sq_height[1] < nd_height[0]) begin
								hit_cnt_w = 7'd1;
								life_w = life_r - 2'd1;
							end else begin
								hit_cnt_w = hit_cnt_r;
								life_w = life_r;
							end
						end
						2'd2 : begin
							if(sq_height[2] < nd_height[0]) begin
								hit_cnt_w = 7'd1;
								life_w = life_r - 2'd1;
							end else begin
								hit_cnt_w = hit_cnt_r;
								life_w = life_r;
							end
						end
						2'd3 : begin
							if(sq_height[3] < nd_height[0]) begin
								hit_cnt_w = 7'd1;
								life_w = life_r - 2'd1;
							end else begin
								hit_cnt_w = hit_cnt_r;
								life_w = life_r;
							end
						end
						default : begin 
							hit_cnt_w = hit_cnt_r;
							life_w = life_r;
						end
					endcase
				end
				else begin
					hit_cnt_w = hit_cnt_r;
					life_w = life_r;
				end
			end 
			else begin
				hit_cnt_w = hit_cnt_r;
				life_w = life_r;
			end
		end
		else begin
			life_w = 2'd3;
			hit_cnt_w = 7'b0;
		end

		//life_w = 2'd3; // demo mode
		//if (score_r > 10000) life_w = 2'd0;
		//else life_w = life_r;
        
        //----state
        case (state_r)
            2'd0 : begin
                if (start) state_w = 2'd1;
                else state_w = 2'd0;
            end
            2'd1 : begin
                if (cnt_shot_r == 3'd5) state_w = 2'd2;
                else state_w = 2'd1;
            end
            2'd2 : begin
                if (life_r == 2'd0) state_w = 2'd3;
                else state_w = 2'd2;
            end
            2'd3 : begin
                if (cnt_shot_r == 3'd5) state_w = 2'd0;
                else state_w = 2'd3;
            end
            default : state_w = state_r;
        endcase

        //----random
        if (state_r != 2'd2) begin
            if (random_r == 10'd1023) random_w = 10'd0;
            else random_w = random_r + 10'd1;
        end
        else begin
        	if (jump) begin
        		random_w = {random_r[4:0],small_cnt_w[4:0]};
        	end
        	else if (new_shot) begin
        		random_w = {random_r[8:0],random_r[2]^random_r[9]};
        	end
        	else random_w = random_r;
        end

        //----shot counter
        if (start) begin// || hit
            small_cnt_w = 7'd0;
            cnt_shot_w = 4'd0;
        end
        else if (state_r == 2'd2 && state_w == 2'd3) begin
        	small_cnt_w = 7'd0;
            cnt_shot_w = 4'd0;
        end
        else if (new_shot) begin
        	if (state_r == 2'd0) begin
        		if (cnt_shot_r < 4'd1) begin
		        	if(small_cnt_r == cnt_shot_split) begin
		            	small_cnt_w = 7'd0;
						cnt_shot_w = cnt_shot_r + 4'd1;
					end 
					else begin
		                small_cnt_w = small_cnt_r + 7'd3;
		                cnt_shot_w = cnt_shot_r;
		            end
		        end
		        else if (cnt_shot_r < 4'd3) begin
		        	if(small_cnt_r == cnt_shot_split) begin
		            	small_cnt_w = 7'd0;
						cnt_shot_w = cnt_shot_r + 4'd1;
					end 
					else begin
		                small_cnt_w = small_cnt_r + 7'd4;
		                cnt_shot_w = cnt_shot_r;
		            end
		        end
		        else if (cnt_shot_r < 4'd5) begin
		        	if(small_cnt_r == cnt_shot_split) begin
		            	small_cnt_w = 7'd0;
						cnt_shot_w = cnt_shot_r + 4'd1;
					end 
					else begin
		                small_cnt_w = small_cnt_r + 7'd6;
		                cnt_shot_w = cnt_shot_r;
		            end
		        end
		        else if (cnt_shot_r < 4'd7) begin
		        	if(small_cnt_r == cnt_shot_split) begin
		            	small_cnt_w = 7'd0;
						cnt_shot_w = cnt_shot_r + 4'd1;
					end 
					else begin
		                small_cnt_w = small_cnt_r + 7'd12;
		                cnt_shot_w = cnt_shot_r;
		            end
		        end
		        else if (cnt_shot_r < 4'd12) begin
		        	if(small_cnt_r == cnt_shot_split) begin
		            	small_cnt_w = 7'd0;
						cnt_shot_w = cnt_shot_r + 4'd1;
					end 
					else begin
		                small_cnt_w = small_cnt_r + 7'd20;
		                cnt_shot_w = cnt_shot_r;
		            end
		        end
		        else if (cnt_shot_r < 4'd13) begin
		        	if(small_cnt_r == cnt_shot_split) begin
		            	small_cnt_w = 7'd0;
						cnt_shot_w = cnt_shot_r + 4'd1;
					end 
					else begin
		                small_cnt_w = small_cnt_r + 7'd3;
		                cnt_shot_w = cnt_shot_r;
		            end
		        end
		        else if (cnt_shot_r < 4'd14) begin
		        	if(small_cnt_r == cnt_shot_split) begin
		            	small_cnt_w = 7'd0;
						cnt_shot_w = cnt_shot_r + 4'd1;
					end 
					else begin
		                small_cnt_w = small_cnt_r + 7'd2;
		                cnt_shot_w = cnt_shot_r;
		            end
		        end
		        else if (cnt_shot_r < 4'd15) begin
		        	if(small_cnt_r == cnt_shot_split) begin
		            	small_cnt_w = 7'd0;
						cnt_shot_w = cnt_shot_r + 4'd1;
					end 
					else begin
		                small_cnt_w = small_cnt_r + 7'd1;
		                cnt_shot_w = cnt_shot_r;
		            end
		        end
		        else begin
		        	if(small_cnt_r == cnt_shot_split) begin
		            	small_cnt_w = 7'd0;
						cnt_shot_w = 4'd0;
					end 
					else begin
		                small_cnt_w = small_cnt_r + 7'd1;
		                cnt_shot_w = cnt_shot_r;
		            end
		        end
	        end
	        else if (state_r == 2'd1) begin
	        	if(small_cnt_r == cnt_shot_split) begin
	            	small_cnt_w = 7'd0;
					cnt_shot_w = cnt_shot_r + 3'd1;
				end 
				else begin
	                small_cnt_w = small_cnt_r + 6'd3;
	                cnt_shot_w = cnt_shot_r;
	            end
	        end
	        else if (state_r == 2'd3) begin
	        	if(small_cnt_r == cnt_shot_split) begin
	            	small_cnt_w = 7'd0;
					cnt_shot_w = cnt_shot_r + 3'd1;
				end 
				else begin
	                small_cnt_w = small_cnt_r + 6'd3;
	                cnt_shot_w = cnt_shot_r;
	            end
	        end
	        else begin
	        	if(small_cnt_r == cnt_shot_split) begin
	            	small_cnt_w = 7'd0;
					cnt_shot_w = cnt_shot_r + 3'd1;
				end 
				else begin
	                small_cnt_w = small_cnt_r + 6'd1;
	                cnt_shot_w = cnt_shot_r;
	            end
	        end
        end
        else begin
            small_cnt_w = small_cnt_r;
            cnt_shot_w = cnt_shot_r;
        end
			
		// ---- character choice
		if (character == 3'd1) begin 	// up
			if (arr_point_r [0] == 2'd0) character_w = 2'd0;
			else if (arr_point_r [1] == 2'd0) character_w = 2'd1;
			else if (arr_point_r [2] == 2'd0) character_w = 2'd2;
			else character_w = 2'd3;
		end else if (character == 3'd2) begin //down
			if (arr_point_r [0] == 2'd1) character_w = 2'd0;
			else if (arr_point_r [1] == 2'd1) character_w = 2'd1;
			else if (arr_point_r [2] == 2'd1) character_w = 2'd2;
			else character_w = 2'd3;
		end else if (character == 3'd3) begin	//left
			if (arr_point_r [0] == 2'd2) character_w = 2'd0;
			else if (arr_point_r [1] == 2'd2) character_w = 2'd1;
			else if (arr_point_r [2] == 2'd2) character_w = 2'd2;
			else character_w = 2'd3;
		end else if (character == 3'd4) begin 	//right
			if (arr_point_r [0] == 2'd3) character_w = 2'd0;
			else if (arr_point_r [1] == 2'd3) character_w = 2'd1;
			else if (arr_point_r [2] == 2'd3) character_w = 2'd2;
			else character_w = 2'd3;
		end else if (state_r == 2'b0) begin
			character_w = 2'd0;
		end
		else begin
			character_w = character_r;
		end
		  
        // ---- jump
		if (sq_height_r[0] <= 10'd0) is_up_w[0] = 1'b1;
		else if (sq_height_r[0] >= jump_height) is_up_w[0] = 1'b0;
		else is_up_w[0] = is_up_r[0];
		if (new_shot) begin
			if (jumping[0]) begin    // []
				if (is_up_r[0]) sq_height_w[0] = sq_height_r[0] + speed_r;
				else if (sq_height_r[0] < speed_r) sq_height_w[0] = 10'd0;
				else sq_height_w [0] = sq_height_r[0] - speed_r;
			end
			else if ((jump) && (character_r == 2'd0)) sq_height_w[0] = speed_r;
			else sq_height_w[0] = 10'd0;
		end
		else sq_height_w[0] = sq_height_r[0];

		if (sq_height_r[1] <= 10'd0) is_up_w[1] = 1'b1;
		else if (sq_height_r[1] >= jump_height) is_up_w[1] = 1'b0;
		else is_up_w[1] = is_up_r[1];
		if (new_shot) begin
			if (jumping[1]) begin    // []
				if (is_up_r[1]) sq_height_w[1] = sq_height_r[1] + speed_r;
				else if (sq_height_r[1] < speed_r) sq_height_w[1] = 10'd0;
				else sq_height_w[1] = sq_height_r[1] - speed_r;
			end
			else if ((jump) && (character_r == 2'd1)) sq_height_w[1] = speed_r;
			else sq_height_w[1] = 10'd0;
		end
		else sq_height_w[1] = sq_height_r[1];

		if (sq_height_r[2] <= 10'd0) is_up_w[2] = 1'b1;
		else if (sq_height_r[2] >= jump_height) is_up_w[2] = 1'b0;
		else is_up_w[2] = is_up_r[2];
		if (new_shot) begin
			if (jumping[2]) begin    // []
				if (is_up_r[2]) sq_height_w[2] = sq_height_r[2] + speed_r;
				else if (sq_height_r[2] < speed_r) sq_height_w[2] = 10'd0;
				else sq_height_w[2] = sq_height_r[2] - speed_r;
			end
			else if ((jump) && (character_r == 2'd2)) sq_height_w[2] = speed_r;
			else sq_height_w[2] = 10'd0;
		end
		else sq_height_w[2] = sq_height_r[2];

		if (sq_height_r[3] <= 10'd0) is_up_w[3] = 1'b1;
		else if (sq_height_r[3] >= jump_height) is_up_w[3] = 1'b0;
		else is_up_w[3] = is_up_r[3];
		if (new_shot) begin
			if (jumping[3]) begin    // []
				if (is_up_r[3]) sq_height_w[3] = sq_height_r[3] + speed_r;
				else if (sq_height_r[3] < speed_r) sq_height_w[3] = 10'd0;
				else sq_height_w[3] = sq_height_r[3] - speed_r;
			end
			else if ((jump) && (character_r == 2'd3)) sq_height_w[3] = speed_r;
			else sq_height_w[3] = 10'd0;
		end
		else sq_height_w[3] = sq_height_r[3];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if(~rst_n) begin
        	change_arr_r <= 1'b0;
        	arr_point_r [0] <= 2'd0;
        	arr_point_r [1] <= 2'd1;
        	arr_point_r [2] <= 2'd2;
        	arr_point_r [3] <= 2'd3;


        	speed_r <= 10'd1;
        	score_r <= 15'd0;
        	high_score_r <= 14'd0;
			character_r <= 2'b0;

			is_up_r[0] <= 1'b1;
			is_up_r[1] <= 1'b1;
			is_up_r[2] <= 1'b1;
			is_up_r[3] <= 1'b1;

			sq_height_r[0] <= 10'd0;
			sq_height_r[1] <= 10'd0;
			sq_height_r[2] <= 10'd0;
			sq_height_r[3] <= 10'd0;

			nd_x_r [0] <= 10'd99;
			nd_x_r [1] <= 10'd199;
			nd_x_r [2] <= 10'd299;
			nd_x_r [3] <= 10'd399;
			nd_x_r [4] <= 10'd499;
			nd_x_r [5] <= 10'd599;
			nd_y_r [0] <= 2'd0;
			nd_y_r [1] <= 2'd0;
			nd_y_r [2] <= 2'd0;
			nd_y_r [3] <= 2'd0;
			nd_y_r [4] <= 2'd0;
			nd_y_r [5] <= 2'd0;
			nd_height_r [0] <= 10'b0;
			nd_height_r [1] <= 10'b0;
			nd_height_r [2] <= 10'b0;
			nd_height_r [3] <= 10'b0;
			nd_height_r [4] <= 10'b0;
			nd_height_r [5] <= 10'b0;

			add_life_r <= 1'b0;
			life_r <= 2'd3;
			hit_cnt_r <= 0;
			small_cnt_r <= 7'd0;
			random_r <= 6'd0;
			cnt_shot_r <= 3'd0;
			state_r <= 2'd0;
        end else begin
        	change_arr_r <= change_arr_w;
        	arr_point_r <= arr_point_w;

        	speed_r <= speed_w;
        	score_r <= score_w;
        	high_score_r <= high_score_w;
			character_r <= character_w;
			is_up_r[0] <= is_up_w[0];
			is_up_r[1] <= is_up_w[1];
			is_up_r[2] <= is_up_w[2];
			is_up_r[3] <= is_up_w[3];
			sq_height_r[0] <= sq_height_w[0];
			sq_height_r[1] <= sq_height_w[1];
			sq_height_r[2] <= sq_height_w[2];
			sq_height_r[3] <= sq_height_w[3];

			nd_x_r <= nd_x_w;
			nd_y_r <= nd_y_w;
			nd_height_r <= nd_height_w;

			add_life_r <= add_life_w;
			life_r <= life_w;
			hit_cnt_r <= hit_cnt_w;
			small_cnt_r <= small_cnt_w;
			random_r <= random_w;
			cnt_shot_r <= cnt_shot_w;
			state_r <= state_w;
        end
    end


endmodule

