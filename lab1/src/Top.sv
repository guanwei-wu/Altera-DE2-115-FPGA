module Top (
    input           i_clk,
    input           i_rst_n,
    input           i_start,
    output  [3:0]   o_random_out,
    // bonus: memory
    output  [3:0]   o_memory_out
);

// please check out the working example in lab1 README (or Top_exmaple.sv) first

/*

----- STATE -----
{IDLE} -> {RANDOM NEW} (press key-0)
{RANDOM NEW} -> {RANDOM NEW} (keep T second)
clk == 50M Hz -> T ~= [0.16 / 0.32 / 0.64 / 1.28] sec with count == [2^23 / 2^24 / 2^25 / 2^26]
{RANDOM NEW} -> {CHANGE T} -> {RANDOM NEW} ([9 / 4 / 2 / 1] times double T once)
{CHANGE T} -> {IDLE} (reset or T is equal to 2^26)

----- RANDOM -----
random new -> LCG -> X(n+1) = 16807 * X(n) (mod 2147483647)
then (mod 16)
2147483647 = 2^31 - 1

*/

// ==================== State ====================
// parameter   S_IDLE = 1'b0;
// parameter   S_PROC = 1'b1;
parameter   S_IDLE      = 2'b00;
parameter   S_RUN_RAND  = 2'b01;
parameter   S_CHANGE_T  = 2'b10;

// ==================== Logic ====================
logic   [1:0]   state, state_nxt;

// how long is T (display time)
logic   [27:0]  cnt_T, cnt_T_nxt;
logic   [27:0]  T_num, T_num_nxt;

// time to change T (update frequency)
logic   [4:0]   cnt_t, cnt_t_nxt;
logic   [4:0]   t_num, t_num_nxt;

logic   [31:0]  out, out_nxt;
logic   [3:0]   memory, memory_nxt;

// random start (whether reset or not)
logic           ini, ini_nxt;

// ==================== Assignment ====================
assign  o_random_out    = out % 16;
assign  o_memory_out    = memory % 16;

// ==================== Combinational Circuit ====================
always_comb begin
    if (i_start) begin
        state_nxt       = S_RUN_RAND;
        cnt_T_nxt       = 1;
        T_num_nxt       = 1 << 23;
        cnt_t_nxt       = 1;
        t_num_nxt       = 9;
        out_nxt         = ini ? 1 : (out * 16807) % (2147483647);
        memory_nxt      = ini ? 0 : out;
        ini_nxt         = 0;
    end
    else begin
        case (state)

            S_IDLE: begin
                state_nxt       = S_IDLE;
                cnt_T_nxt       = 0;
                T_num_nxt       = 0;
                cnt_t_nxt       = 0;
                t_num_nxt       = 0;
                out_nxt         = out;
                memory_nxt      = memory;
                ini_nxt         = ini;
            end

            S_RUN_RAND: begin
                if (cnt_T < T_num) begin
                    state_nxt       = S_RUN_RAND;
                    cnt_T_nxt       = cnt_T + 1;
                    T_num_nxt       = T_num;
                    cnt_t_nxt       = cnt_t;
                    t_num_nxt       = t_num;
                    out_nxt         = out;
                    memory_nxt      = memory;
                    ini_nxt         = ini;
                end
                else begin
                    state_nxt       = S_CHANGE_T;
                    cnt_T_nxt       = cnt_T;
                    T_num_nxt       = T_num;
                    cnt_t_nxt       = cnt_t;
                    t_num_nxt       = t_num;
                    out_nxt         = out;
                    memory_nxt      = memory;
                    ini_nxt         = ini;
                end
            end

            S_CHANGE_T: begin
                if (cnt_t < t_num) begin
                    state_nxt       = S_RUN_RAND;
                    cnt_T_nxt       = 1;
                    T_num_nxt       = T_num;
                    cnt_t_nxt       = cnt_t + 1;
                    t_num_nxt       = t_num;
                    out_nxt         = (out * 16807) % (2147483647);
                    memory_nxt      = memory;
                    ini_nxt         = ini;
                end
                else begin
                    if (t_num == 1) begin
                        state_nxt       = S_IDLE;
                        cnt_T_nxt       = 0;
                        T_num_nxt       = 0;
                        cnt_t_nxt       = 0;
                        t_num_nxt       = 0;
                        out_nxt         = (out * 16807) % (2147483647);
                        memory_nxt      = memory;
                        ini_nxt         = ini;
                    end
                    else begin
                        state_nxt       = S_RUN_RAND;
                        cnt_T_nxt       = 1;
                        T_num_nxt       = T_num << 1;
                        cnt_t_nxt       = 1;
                        t_num_nxt       = t_num >> 1;
                        out_nxt         = (out * 16807) % (2147483647);
                        memory_nxt      = memory;
                        ini_nxt         = ini;
                    end
                end
            end

            default: begin
                state_nxt       = S_IDLE;
                cnt_T_nxt       = 0;
                T_num_nxt       = 0;
                cnt_t_nxt       = 0;
                t_num_nxt       = 0;
                out_nxt         = out;
                memory_nxt      = memory;
                ini_nxt         = ini;
            end
            
        endcase
    end
end

// ==================== Sequential Circuit ====================
always_ff @(posedge i_clk or negedge i_rst_n) begin
    if (!i_rst_n) begin
        state   <= S_IDLE;
        cnt_T   <= 0;
        T_num   <= 0;
        cnt_t   <= 0;
        t_num   <= 0;
        out     <= 0;
        memory  <= 0;
        ini     <= 1;
    end
    else begin
        state   <= state_nxt;
        cnt_T   <= cnt_T_nxt;
        T_num   <= T_num_nxt;
        cnt_t   <= cnt_t_nxt;
        t_num   <= t_num_nxt;
        out     <= out_nxt;
        memory  <= memory_nxt;
        ini     <= ini_nxt;
    end
end

endmodule