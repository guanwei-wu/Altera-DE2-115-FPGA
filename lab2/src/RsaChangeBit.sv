// This file change the data bit number
// It is useless since we didn't complete the bonus.
// It is just a decoration.

module RsaChangeBit (
  input         avm_clk,
  input         avm_rst_n,
  input i_change,
  output [9:0] i_RSA_bit
);

logic [9:0] i_RSA_bit_r, i_RSA_bit_w;

assign i_RSA_bit = i_RSA_bit_r;

always_comb begin
    if (i_change) begin
        i_RSA_bit_w = (i_RSA_bit_r == 11'b01000000000)? 11'b00010000000 : (i_RSA_bit_r << 1);
    end
    else begin
		  i_RSA_bit_w = i_RSA_bit_r;
	 end
end

always_ff @(posedge avm_clk or negedge avm_rst_n) begin
    if (!avm_rst_n) begin
        i_RSA_bit_r <= 11'b00100000000;
    end 
	 else begin
        i_RSA_bit_r <= i_RSA_bit_w;
    end
end

endmodule
