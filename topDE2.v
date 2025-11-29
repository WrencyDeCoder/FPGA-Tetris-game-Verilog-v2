module topDE2 (
     input  wire CLOCK_50,        // Clock 50 MHz on DE2
     input  wire [3:0] KEY,       // KEY input buttons
     input  wire [9:0] SW,        // Switches for reset and others if needed
	 
	output wire [2:0] LEDG,

     output wire VGA_CLK,
     output wire VGA_BLANK,
     output wire VGA_SYNC,
     output wire VGA_HS,
     output wire VGA_VS,
     output wire [9:0] VGA_R,
     output wire [9:0] VGA_G,
     output wire [9:0] VGA_B
);
     // signal mapping
     wire key_left   = ~KEY[1];   
     wire key_right  = ~KEY[0];
     wire key_down   = ~KEY[2];
     wire key_rotate = ~KEY[3];
     
     wire reset_n;  
     assign reset_n = SW[0];

     wire sw_pause;
     assign sw_pause = SW[1];
     // main game module
     HDL_FPGA_Tetris top_game_inst (
          // input 
          .clk_50(CLOCK_50),
          .reset_n(reset_n),
          .button_down(key_down),
          .button_rotate(key_rotate),
          .button_left(key_left),
          .button_right(key_right),
          .sw_pause(),
          // vga out
          .vga_hsync(VGA_HS),
          .vga_vsync(VGA_VS),
          .vga_blank(VGA_BLANK),
          .vga_clk(VGA_CLK),
          .vga_sync(VGA_SYNC),
          .vga_r(VGA_R),
          .vga_g(VGA_G),
          .vga_b(VGA_B)
     );
endmodule