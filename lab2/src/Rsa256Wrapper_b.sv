// `include "include/RsaInclude.sv"
// `include "RsaInclude.sv"


module Rsa256Wrapper (
    input  [RSA_BIT_LOG2_MAX:0] i_RSA_bit,  
    input         avm_rst,
    input         avm_clk,
    output  [4:0] avm_address,
    output        avm_read,
    input  [31:0] avm_readdata,
    output        avm_write,
    output [31:0] avm_writedata,
    input         avm_waitrequest
);

// RSA chunk
logic [RSA_BIT_LOG2_MAX-3:0] RSA_CHUNK;

assign RSA_CHUNK = i_RSA_bit >> 3;

localparam RX_BASE     = 0*4;   //query RX_BASE, [7:0] is received data
localparam TX_BASE     = 1*4;   //query TX_BASE, [7:0] can write value
localparam STATUS_BASE = 2*4;   //query STATUS_BASE to know whether RX and TX is free
localparam TX_OK_BIT   = 6;
localparam RX_OK_BIT   = 7;

// Feel free to design your own FSM!
localparam S_GET_KEY = 0;
localparam S_GET_DATA = 1;
localparam S_WAIT_CALCULATE = 2;
localparam S_SEND_DATA = 3;

logic [RSA_BIT_MAX-1:0] n_r, n_w, d_r, d_w, enc_r, enc_w, dec_r, dec_w;   //N, D, ciphertext, output_decode text
logic [1:0] state_r, state_w;   //S
logic [RSA_BIT_LOG2_MAX-2:0] bytes_counter_r, bytes_counter_w;   //the byte we have view
logic [4:0] avm_address_r, avm_address_w;   //querying address??
logic avm_read_r, avm_read_w, avm_write_r, avm_write_w; //according to TX, RX

logic rsa_start_r, rsa_start_w; //->core
logic rsa_finished; //core->
logic [RSA_BIT_MAX-1:0] rsa_dec;  //core->, decoded text

assign avm_address = avm_address_r;
assign avm_read = avm_read_r;
assign avm_write = avm_write_r;
assign avm_writedata =(i_RSA_bit == 11'b01000000000)? dec_r[503-:8] : ((i_RSA_bit == 11'b00100000000)? dec_r[247-:8] : dec_r[119-:8]);

Rsa256Core rsa256_core(
    .i_RSA_bit(i_RSA_bit),
    .i_clk(avm_clk),
    .i_rst(avm_rst),
    .i_start(rsa_start_r),
    .i_a(enc_r),
    .i_d(d_r),
    .i_n(n_r),
    .o_a_pow_d(rsa_dec),
    .o_finished(rsa_finished)
);

task StartRead; // read protocol ctrl
    input [4:0] addr;
    begin
        avm_read_w = 1;
        avm_write_w = 0;
        avm_address_w = addr;   // STATUS_BASE --valid-> RX_BASE --ready-> STATUS_BASE
    end
endtask
task StartWrite;
    input [4:0] addr;
    begin
        avm_read_w = 0;
        avm_write_w = 1;
        avm_address_w = addr;
    end
endtask

always_comb begin
    avm_read_w = avm_read_r;
    avm_write_w = avm_write_r;
    avm_address_w = avm_address_r;
    n_w = n_r;
    d_w = d_r;
    enc_w = enc_r;
    rsa_start_w = rsa_start_r;
    dec_w = dec_r;
    bytes_counter_w = bytes_counter_r;
    state_w = state_r;
    case (state_r)
        S_GET_KEY : begin
            if (!avm_waitrequest) begin
                case (avm_address_r)
                    STATUS_BASE : begin // waiting for RX ready
                        if (avm_readdata[RX_OK_BIT]) begin
                            StartRead(RX_BASE);
                        end
                    end
                    RX_BASE : begin     // more bit
                        if (bytes_counter_r < RSA_CHUNK) begin 
                            n_w = n_r << 8 | avm_readdata[7:0];   //[7:0]?
                        end
                        else if (bytes_counter_r < (RSA_CHUNK*2)) begin
                            d_w = d_r << 8 | avm_readdata[7:0];
                        end

                        if (bytes_counter_r == (RSA_CHUNK*2-1)) begin
                            bytes_counter_w = 0;
                            state_w = S_GET_DATA;
                            enc_w = 0;
                            dec_w = 0;
                        end
                        else bytes_counter_w = bytes_counter_r + 1;
                        
                        StartRead(STATUS_BASE);
                    end
                    default : begin
                    end
                endcase
            end
        end
        S_GET_DATA : begin
            if (!avm_waitrequest) begin
                case (avm_address_r)
                    STATUS_BASE : begin // waiting for RX ready
                        if (avm_readdata[RX_OK_BIT]) begin
                            StartRead(RX_BASE);
                        end
                    end
                    RX_BASE : begin
                        if (bytes_counter_r < RSA_CHUNK) begin // RSA_CHUNK
                            enc_w = enc_r << 8 | avm_readdata[7:0];   //[7:0]?
                        end

                        if (bytes_counter_r == (RSA_CHUNK-1)) begin
                            bytes_counter_w = 0;
                            state_w = S_WAIT_CALCULATE;
                            rsa_start_w = 1;
                        end
                        else bytes_counter_w = bytes_counter_r + 1;
                        
                        StartRead(STATUS_BASE);
                    end
                    default : begin
                    end
                endcase
            end
        end
        S_WAIT_CALCULATE : begin
            rsa_start_w = 0;
            if (rsa_finished) begin
                dec_w = rsa_dec;
                state_w = S_SEND_DATA;
            end
        end
        S_SEND_DATA : begin
            if (!avm_waitrequest) begin
                case (avm_address_r)
                    STATUS_BASE : begin // waiting for RX ready
                        if (avm_readdata[TX_OK_BIT]) begin
                            StartWrite(TX_BASE);
                        end
                    end
                    TX_BASE : begin
                        if (bytes_counter_r < (RSA_CHUNK-1)) begin 
                            dec_w = dec_r << 8;
                        end

                        if (bytes_counter_r == (RSA_CHUNK-2)) begin
                            enc_w = 0;
                            bytes_counter_w = 0;
                            state_w = S_GET_DATA;
                        end
                        else bytes_counter_w = bytes_counter_r + 1;
                        
                        StartRead(STATUS_BASE);
                    end
                    default : begin
                    end
                endcase
            end
        end
        default: begin
        end
    endcase
end

always_ff @(posedge avm_clk or posedge avm_rst) begin
    if (avm_rst) begin
        n_r <= 0;
        d_r <= 0;
        enc_r <= 0;
        dec_r <= 0;
        avm_address_r <= STATUS_BASE;
        avm_read_r <= 1;
        avm_write_r <= 0;
        state_r <= S_GET_KEY;
        bytes_counter_r <= 0;  
        rsa_start_r <= 0;
    end else begin
        n_r <= n_w;     // N
        d_r <= d_w;     // D
        enc_r <= enc_w; // cipher text
        dec_r <= dec_w;
        avm_address_r <= avm_address_w;
        avm_read_r <= avm_read_w;
        avm_write_r <= avm_write_w;
        state_r <= state_w;
        bytes_counter_r <= bytes_counter_w;
        rsa_start_r <= rsa_start_w;
    end
end

endmodule
