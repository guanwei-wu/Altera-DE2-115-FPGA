module Needle # (
    parameter y_gnd,	// bottom y
    parameter size,
    parameter narrow,
    parameter white_wall
)(	
    // input clk,
    // input rst_n,
    input [9:0] i_x_cord,
    input [9:0] i_y_cord,

    input show,

    input [9:0] nd_x,
    input [1:0] nd_y,
    input [9:0] height,	// height is positive, while "up" is negative

    output en
);
    reg en_reg;
    assign en = en_reg;

    always_comb begin

        if (~show) en_reg = 1'b0;
        else if (height == 10'd0) en_reg = 1'b0;
        else begin
            case (nd_y)
                2'd0 : en_reg = (i_x_cord > nd_x - size + white_wall && i_x_cord < nd_x + size + white_wall && i_y_cord < y_gnd + narrow && i_y_cord + height > y_gnd + narrow);
                2'd1 : en_reg = (i_x_cord > nd_x - size + white_wall && i_x_cord < nd_x + size + white_wall && i_y_cord < 2*y_gnd + narrow && i_y_cord + height > 2*y_gnd + narrow);
                2'd2 : en_reg = (i_x_cord > nd_x - size + white_wall && i_x_cord < nd_x + size + white_wall && i_y_cord < 3*y_gnd + narrow && i_y_cord + height > 3*y_gnd + narrow);
                2'd3 : en_reg = (i_x_cord > nd_x - size + white_wall && i_x_cord < nd_x + size + white_wall && i_y_cord < 4*y_gnd + narrow && i_y_cord + height > 4*y_gnd + narrow);
                default : en_reg = 1'b0;
            endcase
        end
    end
endmodule