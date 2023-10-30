module Audiocontroller(
    input i_rst_n,
    input i_clk,
    input i_lrc,
    input i_start,
    input i_data,
    output o_jump,
    output [15:0] o_data //testing
);

localparam S_IDLE = 2'd0;
localparam S_STILL = 2'd1;
localparam S_DETECT = 2'd2;

logic [ 1:0] state, state_nxt;
logic [ 4:0] counter, counter_nxt; // count 16

logic [15:0] data, data_nxt;
logic [13:0] cnt_loud, cnt_loud_nxt;
logic JUMP, JUMP_nxt;

assign o_jump = JUMP;
//assign o_data = {2'b0,cnt_loud};

always_comb begin
    case(state)
        S_IDLE: begin
            if (i_start) begin
                state_nxt = S_STILL;
                counter_nxt = counter;
                data_nxt = 0;
                JUMP_nxt  = 0;
                cnt_loud_nxt = cnt_loud;
            end
            else begin
                state_nxt = S_IDLE;
                counter_nxt = counter;
                data_nxt = 0;
                JUMP_nxt  = 0;
                cnt_loud_nxt = cnt_loud;
            end
        end
        S_STILL: begin
            if (i_lrc) begin
                state_nxt = S_DETECT;
                counter_nxt = 0;
                data_nxt = 0;
                JUMP_nxt  = JUMP;
                cnt_loud_nxt = cnt_loud;
            end
            else begin
                state_nxt = S_STILL;
                counter_nxt = counter;
                data_nxt = 0;
                JUMP_nxt  = JUMP;
                cnt_loud_nxt = cnt_loud;
            end
        end
        S_DETECT: begin
            if (counter < 16) begin // 0 to 15
                state_nxt = S_DETECT;
                counter_nxt = counter + 1; //count
                data_nxt = {data[14:0],i_data};
                JUMP_nxt = JUMP;
                cnt_loud_nxt = cnt_loud;
            end
            else begin
                if (~i_lrc) begin
                    state_nxt = S_STILL;
                    counter_nxt = counter;
                        if (cnt_loud < 1500) begin
                            if ( (data[15]==0 && data>16'd1600) || (data[15]==1 && (~data+1'b1)>16'd1600) ) begin
                                cnt_loud_nxt = cnt_loud + 1;
                            end
                            else begin
                                cnt_loud_nxt = cnt_loud;
                            end
                            JUMP_nxt = JUMP;
                        end
                        else begin
                            if (cnt_loud < 2200) begin
                                JUMP_nxt = 1;
                                cnt_loud_nxt = cnt_loud + 1;
                            end
                            else begin
                                JUMP_nxt = 0;
                                cnt_loud_nxt = 0;
                            end
                        end
                    data_nxt = data;
                end
                else begin
                    state_nxt = state;
                    counter_nxt = counter;
                    data_nxt = data;
                    JUMP_nxt = JUMP;
                    cnt_loud_nxt = cnt_loud;
                end
            end
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state <= S_IDLE;
        counter <= 0;
        data <= 0;
        JUMP <= 0;
        cnt_loud <= 0;
    end
    else begin
        state <= state_nxt;
        counter <= counter_nxt;
        data <= data_nxt;
        JUMP <= JUMP_nxt;
        cnt_loud <= cnt_loud_nxt;
    end
end
endmodule
