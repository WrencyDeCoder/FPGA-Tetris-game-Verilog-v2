 // Horizontal timing (line)
`define H_VISIBLE 640
`define H_FRONT   16
`define H_SYNC    96
`define H_BACK    48
`define H_TOTAL   800

 // Vertical timing (frame)
`define V_VISIBLE 480
`define V_FRONT   10
`define V_SYNC    2
`define V_BACK    33
`define V_TOTAL   525

// The type of each block	
`define I_BLOCK 		3'b000
`define O_BLOCK 		3'b001
`define T_BLOCK 		3'b010
`define S_BLOCK 		3'b011
`define Z_BLOCK 		3'b100
`define J_BLOCK 		3'b101
`define L_BLOCK 		3'b110
`define EMPTY_BLOCK     3'b111
// Color mapping
	 // --- Background and Grid ---
`define COLOR_BG          {10'h060, 10'h0A0, 10'h140} // bright blue background
`define COLOR_GRID        {10'h1A0, 10'h1D0, 10'h250} // light bluish-gray grid

    // --- Tetromino Blocks ---
`define COLOR_BLOCK       {10'h2FF, 10'h2FF, 10'h2FF} // general bright block
`define COLOR_BLOCK_I     {10'h080, 10'h3FF, 10'h3FF} // bright cyan
`define COLOR_BLOCK_J     {10'h060, 10'h080, 10'h3FF} // vivid blue
`define COLOR_BLOCK_L     {10'h3FF, 10'h240, 10'h060} // warm orange with blue harmony
`define COLOR_BLOCK_O     {10'h3FF, 10'h3FF, 10'h080} // soft yellow
`define COLOR_BLOCK_S     {10'h080, 10'h3FF, 10'h120} // fresh green
`define COLOR_BLOCK_T     {10'h2A0, 10'h080, 10'h3FF} // bright purple-blue
`define COLOR_BLOCK_Z     {10'h3FF, 10'h080, 10'h080} // soft red with blue undertone
`define COLOR_BLOCK_LOCK  {10'h080, 10'h080, 10'h080}

    // --- Text and Effects ---
`define COLOR_TEXT        {10'h3FF, 10'h3FF, 10'h3FF} // pure white


// Game board define
`define BLOCKS_W 			4'd10 // How many blocks wide the game board is
`define BLOCKS_H 			5'd22 // How many blocks high the game board is
`define BLOCK_SIZE		20 // How many pixels wide/high each block is
`define BOARD_WIDTH 		(`BLOCKS_W * `BLOCK_SIZE)  // Width of the game board in pixels
`define BOARD_HEIGHT 	(`BLOCKS_H * `BLOCK_SIZE) // Height of the game board in pixels
`define BOARD_OFFSET_X	220
`define BOARD_OFFSET_Y	20
`define GRID_STROKE	 	2
`define SCORE_TEXT_X    440
`define SCORE_TEXT_Y    380
`define DIGIT_WIDTH     8
`define DIGIT_HEIGHT    10 
`define DIGIT_SPACE     1
`define DIGIT_SCALE     3

// State
`define S_IDLE		4'd0
`define S_START		4'd1
`define S_PLAY		4'd2
`define S_ADD		4'd3
`define S_ADD_COLOR	4'd4
`define S_CHECK	    4'd5
`define S_REMOVE	4'd6
`define S_RM_COLOR	4'd7
`define S_OVER	    4'd8
`define S_INC_SCR   4'd9
`define S_PAUSE	    4'd10

// LFSR seed
`define LFSR_SEED		8'b10111010

// clock
`define GAME_CLOCK_Hz 60
`define GAME_CLOCK_COUNTER_MAX (50_000_000 / `GAME_CLOCK_Hz)

