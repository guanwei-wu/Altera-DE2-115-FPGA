module AudRecorder(
    input i_rst_n,
    input i_clk,
    input i_lrc,
    input i_start,
    input i_pause,
    input i_stop,
    input i_data,
    output [19:0] o_address,
    output [15:0] o_data
);

localparam S_IDLE = 2'd0;
localparam S_STILL = 2'd1;
localparam S_RECORD = 2'd2;
localparam S_PAUSE = 2'd3;

logic [ 1:0] state, state_nxt;
logic [ 4:0] counter, counter_nxt; // count 16
logic [19:0] OADDR, OADDR_nxt; // o_address
logic [15:0] ODATA, ODATA_nxt; // o_data

assign o_address = OADDR;
assign o_data = ODATA;

always_comb begin
    case(state)
        S_IDLE: begin
            if (i_start) begin
                state_nxt = S_STILL;
                counter_nxt = counter;
                OADDR_nxt = 0;
                ODATA_nxt = 0;
            end
            else begin
                state_nxt = S_IDLE;
                counter_nxt = counter;
                OADDR_nxt = 0;
                ODATA_nxt = 0;
            end
        end
        S_STILL: begin
            if (i_lrc) begin
                state_nxt = S_RECORD;
                counter_nxt = 0;
                OADDR_nxt = OADDR;
                ODATA_nxt = ODATA;
            end
            else if (i_pause) begin
                state_nxt = S_PAUSE;
                counter_nxt = counter;
                OADDR_nxt = OADDR;
                ODATA_nxt = ODATA;
            end
            else if (i_stop) begin
                state_nxt = S_IDLE;
                counter_nxt = counter;
                OADDR_nxt = OADDR;
                ODATA_nxt = ODATA;
            end
            else begin
                state_nxt = S_STILL;
                counter_nxt = counter;
                OADDR_nxt = OADDR;
                ODATA_nxt = ODATA;
            end
        end
        S_RECORD: begin
            if (i_pause) begin
                state_nxt = S_PAUSE;
                counter_nxt = counter;
                OADDR_nxt = OADDR;
                ODATA_nxt = ODATA;
            end
            else if (i_stop) begin
                state_nxt = S_IDLE;
                counter_nxt = counter;
                OADDR_nxt = OADDR;
                ODATA_nxt = ODATA;
            end
            else if (counter < 16) begin // 0 to 15
                state_nxt = S_RECORD;
                counter_nxt = counter + 1; //count
                OADDR_nxt = OADDR;
                ODATA_nxt = {ODATA[14:0],i_data};
            end
            else begin
					 if (~i_lrc) begin
						 state_nxt = S_STILL;
						 counter_nxt = counter;
						 OADDR_nxt = OADDR + 1;
						 ODATA_nxt = ODATA;
					 end
					 else begin
						 state_nxt = state;
						 counter_nxt = counter;
						 OADDR_nxt = OADDR;
						 ODATA_nxt = ODATA;
					 end
            end
        end
        S_PAUSE: begin
            if (i_start) begin
                state_nxt = S_STILL;
                counter_nxt = 0;
                OADDR_nxt = OADDR;
                ODATA_nxt = 0;
            end
            else if (i_stop) begin
                state_nxt = S_IDLE;
                counter_nxt = 0;
                OADDR_nxt = OADDR;
                ODATA_nxt = 0;
            end
            else begin
                state_nxt = S_PAUSE;
                counter_nxt = 0;
                OADDR_nxt = OADDR;
                ODATA_nxt = 0;
            end
        end
        default: begin
            state_nxt = S_IDLE;
            counter_nxt = 0;
            OADDR_nxt = 0;
            ODATA_nxt = 0;
        end
    endcase
end

always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state <= S_IDLE;
        counter <= 0;
        OADDR <= 0;
        ODATA <= 0;
    end
    else begin
        state <= state_nxt;
        counter <= counter_nxt;
        OADDR <= OADDR_nxt;
        ODATA <= ODATA_nxt;
    end
end
endmodule
