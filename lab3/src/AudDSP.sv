module AudDSP (
	input i_rst_n,
	//input i_clk, //not used
   input i_start,
	input i_pause,
	input i_stop,
	input[3:0] i_speed,
	input i_fast,
	input i_slow_0, // constant interpolation
	input i_slow_1, // linear interpolation
	input i_daclrck,
	input [15:0]  i_sram_data,
	output [15:0] o_dac_data,
	output [19:0] o_sram_addr,
   output play_en // Use to start the player
);

logic signed [15:0] o_data_r, o_data_w; // final output (used in slow mode)
logic signed [15:0] data_r, data_w; // store previous data
logic [19:0] address_r, address_w;
logic [3:0] counter_r, counter_w; // use for slow mode
logic signed [4:0] signed_speed; // use for signed operation

assign o_dac_data = (counter_r == 0)? i_sram_data : o_data_r;
assign o_sram_addr = address_r;
assign play_en = (address_r > 0);
assign signed_speed = {1'b0,i_speed};

always_comb begin
  o_data_w = o_data_r;
  data_w = data_r;
  address_w = address_r;
  counter_w = counter_r;
  if (i_start) begin
    if (i_fast) begin
      data_w = i_sram_data;
      address_w = address_r + i_speed;
      counter_w = 0;
    end else if (i_slow_0) begin
      o_data_w = data_r;
      data_w = (counter_r == 0)? i_sram_data : data_r;
      address_w = (counter_r == 0)? address_r + 1 : address_r;
      counter_w = (counter_r + 1 == i_speed)? 0 : counter_r + 1;
    end else if (i_slow_1) begin
      o_data_w = ($signed(counter_r)*$signed(i_sram_data) + (signed_speed-$signed(counter_r))*(data_r)) / signed_speed;
      data_w = (counter_r == 0)? i_sram_data : data_r;
      address_w = (counter_r == 0)? address_r + 1 : address_r;
      counter_w = (counter_r + 1 == i_speed)? 0 : counter_r + 1;
    end else begin // normal mode
      data_w = i_sram_data;
      address_w = address_r + 1;
      counter_w = 0;
    end
  end else if (i_pause) begin
    // Stay the same
  end else if (i_stop) begin
    o_data_w = 16'b0;
    data_w = 16'b0;
    address_w = 20'b0;
    counter_w = 4'b0;
  end else begin
  end
end

always_ff @(posedge i_daclrck or negedge i_rst_n) begin
  if (!i_rst_n) begin
    o_data_r <= 16'b0;
    data_r <= 16'b0;
    address_r <= 20'b0;
    counter_r <= 0;
  end else begin
    o_data_r <= o_data_w;
    data_r <= data_w;
    address_r <= address_w;
    counter_r <= counter_w;
  end
end

endmodule
