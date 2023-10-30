module Screen (
    input clk,
    input rst_n,
    input [9:0] i_x_cord,
    input [9:0] i_y_cord,

    input [1:0] character,
    input [1:0] arr_point [0:3],
    input change_arr,

    input [1:0] life,
    input [1:0] state,
    input [3:0] cnt_shot,
    input hit,
    input [9:0] sq_height [0:3], // square also need
    input jumping [0:3], // need more jumpings [3:0]

    input [9:0] nd_x [0:5],  // nd_x = 0 won't show any needle
    input [1:0] nd_y [0:5],  // only record which strip it is
    input [9:0] nd_height [0:5],

    output [7:0] o_VGA_R,
    output [7:0] o_VGA_G,
    output [7:0] o_VGA_B
);
    reg [7:0] VGA_R_reg, VGA_G_reg, VGA_B_reg;
    assign o_VGA_B = VGA_B_reg;
    assign o_VGA_G = VGA_G_reg;
    assign o_VGA_R = VGA_R_reg;

    //----state 0----
    parameter y_logo = 240;
    parameter x_logo = 320;
    parameter size_logo = 60;

    parameter y_load = 360;
    parameter x_load_span = 24;
    parameter size_load = 8;
    //----state 2----
    parameter narrow = 15;  // upper blank narrow
    parameter white_wall = 40;

    parameter y_gnd = 110;  // y of strip ground, square bottom, needle bottom

    parameter x_sq = 100;   // x of square, should turn to upper parameter
    parameter size_sq = 16; // half len of square

    parameter y_life = 30;
    parameter size_life = 8;
    parameter x_life_span = 30;

    parameter x_arr = 33;
    parameter size_arr = 2;

    parameter size_nd = 4;  // half thick of needle

    wire logo_en;

    wire [14:0] load_en;
    wire [14:0] show_load;
    assign show_load [14] = cnt_shot > 4'd14;
    assign show_load [13] = cnt_shot > 4'd13;
    assign show_load [12] = cnt_shot > 4'd12;
    assign show_load [11] = cnt_shot > 4'd11;
    assign show_load [10] = cnt_shot > 4'd10;
    assign show_load [9] = cnt_shot > 4'd9;
    assign show_load [8] = cnt_shot > 4'd8;
    assign show_load [7] = cnt_shot > 4'd7;
    assign show_load [6] = cnt_shot > 4'd6;
    assign show_load [5] = cnt_shot > 4'd5;
    assign show_load [4] = cnt_shot > 4'd4;
    assign show_load [3] = cnt_shot > 4'd3;
    assign show_load [2] = cnt_shot > 4'd2;
    assign show_load [1] = cnt_shot > 4'd1;
    assign show_load [0] = cnt_shot > 4'd0;

    wire [3:0] start_en;
    wire [3:0] end_en;
    wire [3:0] show_start;
    wire [3:0] show_end;
    assign show_start [3] = cnt_shot > 4'd3;
    assign show_start [2] = cnt_shot > 4'd2;
    assign show_start [1] = cnt_shot > 4'd1;
    assign show_start [0] = cnt_shot > 4'd0;
    assign show_end [3] = cnt_shot <= 4'd3;
    assign show_end [2] = cnt_shot <= 4'd2;
    assign show_end [1] = cnt_shot <= 4'd1;
    assign show_end [0] = cnt_shot == 4'd0;

    wire [2:0] life_en;
    wire [2:0] show_life;
    assign show_life [2] = life > 2'd2;
    assign show_life [1] = life > 2'd1;
    assign show_life [0] = life > 2'd0;


    wire [3:0] sq_en;

    wire [5:0] nd_en;

    wire [3:0] arr_en;

    genvar i;
    generate
        Square # (
            .y_idle(y_logo),
            .x_idle(x_logo),
            .size(size_logo)
        ) logo (
            .clk(clk),
            .rst_n(rst_n),
            .i_x_cord(i_x_cord),
            .i_y_cord(i_y_cord),
    
            .hit(1'b0),
            .show(state == 2'd0),
            .jumping(1'd0),
    
            .height(10'd0),
    
            .en(logo_en)
        );
        for (i = 0; i < 15; i = i + 1) begin : gen_load
            Square # (
                .y_idle(y_load),
                .x_idle(320 + (i - 7)*x_load_span),
                .size(size_load)
            ) load (
                .clk(clk),
                .rst_n(rst_n),
                .i_x_cord(i_x_cord),
                .i_y_cord(i_y_cord),
        
                .hit(1'b0),
                .show(show_load [i]  && state == 2'd0),
                .jumping(1'd0),
        
                .height(10'd0),
        
                .en(load_en [i])
            );
        end
        for (i = 0; i < 4; i = i + 1) begin : gen_start
            Square # (
                .y_idle((i+1)*y_gnd + narrow),
                .x_idle(x_sq),
                .size(size_sq)
            ) load (
                .clk(clk),
                .rst_n(rst_n),
                .i_x_cord(i_x_cord),
                .i_y_cord(i_y_cord),
        
                .hit(1'b0),
                .show(show_start [i]  && state == 2'd1),
                .jumping(1'd0),
        
                .height(10'd0),
        
                .en(start_en [i])
            );
        end
        for (i = 0; i < 4; i = i + 1) begin : gen_end
            Square # (
                .y_idle((i+1)*y_gnd + narrow),
                .x_idle(x_sq),
                .size(size_sq)
            ) load (
                .clk(clk),
                .rst_n(rst_n),
                .i_x_cord(i_x_cord),
                .i_y_cord(i_y_cord),
        
                .hit(1'b0),
                .show(show_end [i]  && state == 2'd3),
                .jumping(1'd0),
        
                .height(10'd0),
        
                .en(end_en [i])
            );
        end
        for (i = 0; i < 4; i = i + 1) begin : gen_arr
            Arrow # (
                .x_idle(x_arr),
                .y_idle(i * y_gnd + y_gnd / 2),
                .size_arr(size_arr)
            ) arr (
                .i_x_cord(i_x_cord),
                .i_y_cord(i_y_cord),
                .clk(clk),
                .rst_n(rst_n),
        
                .show(state == 2'd2),
                .change(change_arr),
        
                .point(arr_point [i]),  //[]
        
                .en(arr_en [i])
            );
        end
        for (i = 0; i < 3; i = i + 1) begin : gen_life
            Square # (
                .y_idle(y_life),
                .x_idle(640 - (i+1)*x_life_span),  //640 - k*x_life_span
                .size(size_life)
            ) life (
                .clk(clk),
                .rst_n(rst_n),
                .i_x_cord(i_x_cord),
                .i_y_cord(i_y_cord),
        
                .hit(1'b0),
                .show(show_life [i] && state == 2'd2), //life == ???
                .jumping(1'd0),
        
                .height(10'd0),
        
                .en(life_en [i])
            );
        end
        for (i = 0; i < 4; i = i + 1) begin : gen_sq
            Square # (
                .y_idle((i+1)*y_gnd + narrow),    //k*y_gnd + narrow
                .x_idle(x_sq),
                .size(size_sq)
            ) sq (
                .clk(clk),
                .rst_n(rst_n),
                .i_x_cord(i_x_cord),
                .i_y_cord(i_y_cord),
        
                .hit(hit),
                .show(state == 2'd2),
                .jumping(jumping [i]), //[]
        
                .height(sq_height [i]),
        
                .en(sq_en [i])
            );
        end
        for (i = 0; i < 6; i = i + 1) begin : gen_nd
            Needle # (
                .size(size_nd),
                .y_gnd(y_gnd),
                .narrow(narrow),
                .white_wall(white_wall)
            ) nd (
                .i_x_cord(i_x_cord),
                .i_y_cord(i_y_cord),
        
                .show(state == 2'd2),
        
                .nd_x(nd_x [i]),    //[]
                .nd_y(nd_y [i]),    //[]
                .height(nd_height [i]), //[]
        
                .en(nd_en [i])
            );
        end
    endgenerate

    
    always_comb begin   
        // change arr
        if (logo_en) begin
            VGA_R_reg = 8'd0;
            VGA_G_reg = 8'd255;
            VGA_B_reg = 8'd255;
        end
        else if (load_en != 15'd0) begin
            VGA_R_reg = 8'd255;
            VGA_G_reg = 8'd0;
            VGA_B_reg = 8'd0;
        end
        else if (start_en != 3'd0) begin
            VGA_R_reg = 8'd0;
            VGA_G_reg = 8'd255;
            VGA_B_reg = 8'd255;
        end
        else if (end_en != 3'd0) begin
            VGA_R_reg = 8'd0;
            VGA_G_reg = 8'd255;
            VGA_B_reg = 8'd255;
        end
        else if (arr_en != 4'd0) begin
            VGA_R_reg = change_arr ? 8'd255 : 8'd0;
            VGA_G_reg = 8'd0;
            case (character)
                2'd0 : VGA_B_reg = arr_en[0] ? 8'd255 : 8'd63;
                2'd1 : VGA_B_reg = arr_en[1] ? 8'd255 : 8'd63;
                2'd2 : VGA_B_reg = arr_en[2] ? 8'd255 : 8'd63;
                2'd3 : VGA_B_reg = arr_en[3] ? 8'd255 : 8'd63;
                default : VGA_B_reg = 8'd127;
            endcase // character
        end
        else if (state == 2'd2 && i_x_cord < white_wall + 10) begin
            VGA_R_reg = 8'd255;
            VGA_G_reg = 8'd255;
            VGA_B_reg = 8'd255;
        end 
        else if (life_en != 3'd0) begin
            VGA_R_reg = 8'd255;
            VGA_G_reg = 8'd0;
            VGA_B_reg = 8'd0;
        end
        else if (nd_en != 6'd0) begin
            VGA_R_reg = (nd_en [0] || nd_en [1]) ? 8'd255 : 8'd0;
            VGA_G_reg = (nd_en [0]) ? 8'd0 : 8'd255; 
            VGA_B_reg = 8'd0;
        end
        else if (sq_en != 4'd0) begin
            VGA_R_reg = 8'd0;
            VGA_G_reg = 8'd255;
            VGA_B_reg = 8'd255;
        end
        else begin
            if ((state == 2'd2)) begin
                if (i_y_cord == y_gnd + narrow || i_y_cord == 2*y_gnd + narrow || i_y_cord == 3*y_gnd + narrow || i_y_cord == 4*y_gnd + narrow) begin
                    VGA_R_reg = 8'd255;
                    VGA_G_reg = 8'd255;
                    VGA_B_reg = 8'd255;
                end
                else begin
                    VGA_R_reg = 8'd0;
                    VGA_G_reg = 8'd0;
                    VGA_B_reg = 8'd0;
                end
            end
            else begin
                VGA_R_reg = 8'd0;
                VGA_G_reg = 8'd0;
                VGA_B_reg = 8'd0;
            end
        end
    end

endmodule