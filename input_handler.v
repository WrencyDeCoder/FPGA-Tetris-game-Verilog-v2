module input_handler (
	input  	clk,
	input 	raw_signal,
	output	signal
);

	reg snapshot = 1'b0;
	reg snapshot_bfr = 1'b0;
	reg [4:0] counter = 5'd0;

	wire counter_rising;

	always @(posedge clk) begin
	  if (counter == 5'd10) begin
		 counter <= 1'b0;
		 snapshot <= raw_signal;
	  end else counter <= counter + 1'b1;
	end

	always @(posedge clk) snapshot_bfr <= snapshot;

	assign signal = snapshot & (~snapshot_bfr);

endmodule 