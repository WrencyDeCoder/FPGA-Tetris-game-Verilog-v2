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
`define EMPTY_BLOCK 	3'b000
`define I_BLOCK 		3'b001
`define O_BLOCK 		3'b010
`define T_BLOCK 		3'b011
`define S_BLOCK 		3'b100
`define Z_BLOCK 		3'b101
`define J_BLOCK 		3'b110
`define L_BLOCK 		3'b111

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

// State
`define S_IDLE		3'd0
`define S_PLAY		3'd1
`define S_ADD		3'd2
`define S_CHECK	3'd3
`define S_REMOVE	3'd4
`define S_PAUSE	3'd5

// LFSR seed
`define LFSR_SEED		8'b10101010

// clock
`define GAME_CLOCK_Hz 120
`define GAME_CLOCK_COUNTER_MAX (50_000_000 / `GAME_CLOCK_Hz)

