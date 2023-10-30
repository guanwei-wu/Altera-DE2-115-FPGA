// `include "include/RsaInclude.sv"
//`include "RsaInclude.sv"


module Rsa256Core (
	input  [10:0]  i_RSA_bit,
  input          i_clk,
	input          i_rst,
	input          i_start,
	input  [RSA_BIT_MAX-1:0] i_a, // cipher text y
	input  [RSA_BIT_MAX-1:0] i_d, // private key
	input  [RSA_BIT_MAX-1:0] i_n,
	output [RSA_BIT_MAX-1:0] o_a_pow_d, // plain text x
	output         o_finished
);

// RSA bit
logic [3:0] RSA_bit_LOG2;

assign RSA_bit_LOG2 = (i_RSA_bit == 11'b10000000000)? 4'd10 : ((i_RSA_bit == 11'b01000000000)? 4'd9 : ((i_RSA_bit == 11'b00100000000)? 4'd8 : 4'd7));

// operations for RSA256 decryption
// namely, the Montgomery algorithm

// Core Logic
parameter S_IDLE = 2'd0;
parameter S_PREP = 2'd1;
parameter S_MONT = 2'd2;
parameter S_CALC = 2'd3;
logic [  1:0] state, state_nxt;
logic [RSA_BIT_LOG2_MAX:0] counter, counter_nxt;
logic [RSA_BIT_MAX-1:0] t, t_nxt, m, m_nxt;

// Prep Logic
logic [RSA_BIT_MAX-1:0] prep_output;
logic         prep_start;
logic         prep_finish;

// Mont Logic
logic [RSA_BIT_MAX-1:0] mont_output_m, mont_output_t;
logic         mont_start_m, mont_start_t;
logic         mont_finish_m, mont_finish_t;

// store

// y * 2^i_RSA_bit (modN)
RsaPrep M_Prep(
    .i_RSA_bit_LOG2(RSA_bit_LOG2),
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_start(i_start),
    .i_keep(prep_start),
    .i_a({1'b1}<<i_RSA_bit),
    .i_b(i_a),
    .i_n(i_n),
    .o_prep(prep_output),
    .o_finish(prep_finish)
);

// mt * 2^(-i_RSA_bit) (modN)
RsaMont M_Mont_m(
    .i_RSA_bit_LOG2(RSA_bit_LOG2),
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_keep(mont_start_m),
    .i_state(state),
    .i_a(m),
    .i_b(t),
    .i_n(i_n),
    .o_mont(mont_output_m),
    .o_finish(mont_finish_m)
);

// t^2 * 2^(-i_RSA_bit) (modN)
RsaMont M_Mont_t(
    .i_RSA_bit_LOG2(RSA_bit_LOG2),
    .i_clk(i_clk),
    .i_rst(i_rst),
    .i_keep(mont_start_t),
    .i_state(state),
    .i_a(t),
    .i_b(t),
    .i_n(i_n),
    .o_mont(mont_output_t),
    .o_finish(mont_finish_t)
);

assign o_a_pow_d = m;
assign o_finished = counter[RSA_bit_LOG2];

always_comb begin
    // backup
    if (i_start) begin
        state_nxt = S_PREP;
        prep_start = 1;
        mont_start_m = 0;
        mont_start_t = 0;
        t_nxt = 0;
        m_nxt = 1;
        counter_nxt = 0;
    end
    else begin
        case(state)
            S_IDLE: begin
                state_nxt = i_start ? S_PREP : S_IDLE;
                prep_start = 0;
                mont_start_m = 0;
                mont_start_t = 0;
                t_nxt = 0;
                m_nxt = 0;
                counter_nxt = 0;
            end

            S_PREP: begin
                state_nxt = prep_finish ? S_MONT : S_PREP;
                prep_start = 1;
                mont_start_m = 0;
                mont_start_t = 0;
                t_nxt = prep_finish ? prep_output : 0;
                m_nxt = 1;
                counter_nxt = 0;
            end

            S_MONT: begin
                state_nxt = (mont_finish_m & mont_finish_t & !counter[RSA_bit_LOG2]) ? S_CALC : S_MONT;
                prep_start = 0;
                mont_start_m = i_d[counter] ? 1 : 0;
                mont_start_t = 1;
                t_nxt = mont_finish_t ? mont_output_t : t;
                m_nxt = (mont_finish_m & mont_start_m) ? mont_output_m : m;
                counter_nxt = counter;
            end

            S_CALC: begin
                state_nxt = ((counter + 1) == {1'b1}<<RSA_bit_LOG2) ? S_IDLE : S_MONT;
                prep_start = 0;
                mont_start_m = 0;
                mont_start_t = 0;
                t_nxt = t;
                m_nxt = m;
                counter_nxt = counter + 1;
            end

            default: begin
                state_nxt = S_IDLE;
                prep_start = 0;
                mont_start_m = 0;
                mont_start_t = 0;
                t_nxt = 0;
                m_nxt = 0;
                counter_nxt = 0;
            end
        endcase
    end
end

always_ff @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        state <= S_IDLE;
        counter <= 0;
        t <= 0;
        m <= 0;
    end
    else begin
        state <= state_nxt;
        counter <= counter_nxt;
        t <= t_nxt;
        m <= m_nxt;
    end
end

endmodule

// ====================================================================================================

// SubModule
module RsaPrep (
  input [3:0]    i_RSA_bit_LOG2,
	input          i_clk,
	input          i_rst,
	input          i_start,
    input          i_keep,
	input  [RSA_BIT_MAX:0] i_a,
	input  [RSA_BIT_MAX-1:0] i_b,
	input  [RSA_BIT_MAX-1:0] i_n,
	output [RSA_BIT_MAX-1:0] o_prep,
	output         o_finish
);

logic [RSA_BIT_LOG2_MAX:0] counter, counter_nxt;
logic [RSA_BIT_MAX-1:0] t, t_nxt, m, m_nxt;

assign o_prep = i_keep ? m : 0;
assign o_finish = counter[i_RSA_bit_LOG2]&counter[0] ? 1 : 0;

always_comb begin
    if (i_start) begin
        t_nxt = i_b;
        counter_nxt = 0;
        m_nxt = 0;
    end
    else begin
        if (i_keep) begin
            counter_nxt = counter + 1;
            m_nxt = (i_a[counter]) ? ((m+t>=i_n) ? (m+t-i_n) : (m+t)) : (m);
            t_nxt = ((t<<1) > i_n) ? (t<<1)-i_n : (t<<1);
        end
        else begin
            counter_nxt = 0;
            m_nxt = 0;
            t_nxt = 0;
        end
    end
end

always_ff @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        counter <= 0;
        t <= 0;
        m <= 0;
    end
    else begin
        counter <= counter_nxt;
        t <= t_nxt;
        m <= m_nxt;
    end
end

endmodule

module RsaMont (
  input [3:0]    i_RSA_bit_LOG2,
	input          i_clk,
	input          i_rst,
	input          i_keep,
    input  [  1:0] i_state,
	input  [RSA_BIT_MAX-1:0] i_a,
	input  [RSA_BIT_MAX-1:0] i_b,
	input  [RSA_BIT_MAX-1:0] i_n,
	output [RSA_BIT_MAX-1:0] o_mont,
	output         o_finish
);

logic [RSA_BIT_LOG2_MAX:0] counter, counter_nxt;
logic [RSA_BIT_MAX+1:0] m, m_nxt;

assign o_mont = (m>=i_n) ? (m-i_n) : m;
assign o_finish = counter[i_RSA_bit_LOG2] ? 1 : 0;

always_comb begin
    if(i_state == 2) begin
        counter_nxt = counter + 1;
    end
    else begin
        counter_nxt = 0;
    end

    if (i_keep) begin
        if (i_a[counter]) begin
            if ((m+i_b)%2) begin
                m_nxt = (m + i_b + i_n) >> 1;
            end
            else begin
                m_nxt = (m + i_b) >> 1;
            end
        end
        else begin
            if (m%2) begin
                m_nxt = (m + i_n) >> 1;
            end
            else begin
                m_nxt = m >> 1;
            end
        end
    end
    else begin
        m_nxt = 0;
    end
end

always_ff @(posedge i_clk or posedge i_rst) begin
    if (i_rst) begin
        counter <= 0;
        m <= 0;
    end
    else begin
        counter <= counter_nxt;
        m <= m_nxt;
    end
end

endmodule