module input_handler (
	input  	clk,
	input 	raw_signal,
	output	signal
);

	reg snapshot;
	reg snapshot_bfr;
	reg [19:0] counter;

	wire counter_rising;

	always @(posedge clk) begin
	  if (counter == 20'b1111_0100_0010_0100_0000) begin
		 counter <= 1'b0;
		 snapshot <= raw_signal;
	  end else counter <= counter + 1'b1;
	end

	always @(posedge clk) snapshot_bfr <= snapshot;

	assign signal = snapshot & (~snapshot_bfr);

endmodule 