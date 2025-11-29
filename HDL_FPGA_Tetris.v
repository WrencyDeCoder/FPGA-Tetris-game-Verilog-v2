`timescale 1ns / 1ns

`include "definitions.vh"

module HDL_FPGA_Tetris (
	input 	wire		clk_50,
	input	wire		reset_n,
	
	input	wire		button_down,
	input	wire		button_rotate,
	input	wire		button_left,
	input	wire		button_right,

	input  	wire 	sw_pause,
	
	output	wire			vga_hsync,
	output	wire			vga_vsync,
	output	wire			vga_blank,
	output	wire			vga_clk,
	output	wire			vga_sync,
	output	wire  [9:0]	vga_r,
	output	wire  [9:0]	vga_g,
	output	wire  [9:0]	vga_b
	
);
	// wire
	wire 	[9:0]	x;
	wire 	[9:0]	y;
	wire 			clk_25;
	wire 			active_area;
	wire  	[29:0] 	RGB;
	
	assign vga_r = RGB[29:20];
	assign vga_g = RGB[19:10];
	assign vga_b = RGB[ 9: 0];
	
	// create clock 25MHz
	reg clk_div2;
	always @(posedge clk_50 or negedge reset_n) begin
		if (!reset_n)
			clk_div2 <= 1'b0;
		else
			clk_div2 <= ~clk_div2;
	end
	assign clk_25 = clk_div2;
	
	// create clock for game, we can set in definitions.vh
	reg game_clk;
	reg [31:0] counter;
	always @ (posedge clk_50 or negedge reset_n) begin
		if (!reset_n) begin
			counter <= 0;
			game_clk <= 0;
		end else begin
			if (counter == `GAME_CLOCK_COUNTER_MAX) begin 
				counter <= 0;
				game_clk <= 1;
			end else begin
				counter <= counter + 1;
				game_clk <= 0;
			end
		end
	end
	
	vga_controller vga_inst ( 
		.clk_25(clk_25),
		.reset_n(reset_n),
		.x(x),
		.y(y),
		.hsync(vga_hsync),
		.vsync(vga_vsync),
		.active_area(active_area),
		.vga_clk(vga_clk),
		.blank(vga_blank),
	   .sync(vga_sync)
	);
	
	game_logic_controller game_inst (
		.clk(game_clk),
		.reset_n(reset_n),
		.down_btn(button_down),
		.right_btn(button_right),
		.left_btn(button_left),
		.sw_pause(sw_pause),
		.rotate_btn(button_rotate),
		.active_area(active_area),
		.screen_x(x),
		.screen_y(y),
		.RGB(RGB)
	);
	
endmodule
