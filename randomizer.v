module randomizer (
  input clk,
  output [7:0] LFSR_out
);
	localparam LFSR_SEED  = 8'b10101010;

	reg [7:0] LFSR;
	assign LFSR_out = LFSR;
	wire feedback = LFSR[7];
	
	initial LFSR = LFSR_SEED;
	
	always @(posedge clk)
	begin
		 LFSR[0] <= feedback;
		 LFSR[1] <= LFSR[0];
		 LFSR[2] <= LFSR[1] ^ feedback;
		 LFSR[3] <= LFSR[2] ^ feedback;
		 LFSR[4] <= LFSR[3] ^ feedback;
		 LFSR[5] <= LFSR[4];
		 LFSR[6] <= LFSR[5];
		 LFSR[7] <= LFSR[6];
	end
	
endmodule 