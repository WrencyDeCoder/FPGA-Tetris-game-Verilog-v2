`include "definitions.vh"

module game_logic_controller (
	input   wire        	clk,
	input   wire        	reset_n,

	//signal
	input   wire        	down_btn,
	input   wire        	right_btn,
	input   wire        	left_btn,
	input   wire        	rotate_btn,
	input   wire 			sw_pause,
	//from VGA
	input   wire			active_area,
	input   wire 	[9:0] 	screen_x,
   input   wire 	[9:0] 	screen_y,
	
	output  reg 	[29:0]   	RGB
);
	//	GAME BOARD 
	reg [`BLOCKS_W-4'd1 : 0] game_board [`BLOCKS_H-5'd1 : 0]; 
	reg [3*`BLOCKS_W-4'd1 : 0] game_board_color [`BLOCKS_H-5'd1 : 0]; 

	//	INPUT HANDLE
	wire down_signal;
	wire right_signal;
	wire left_signal;
	wire rotate_signal;

	input_handler handler_down_inst (
		.clk(clk),
		.raw_signal(down_btn),
		.signal(down_signal)
	);
	input_handler handler_rot_inst (
		.clk(clk),
		.raw_signal(rotate_btn),
		.signal(rotate_signal)
	);
	input_handler handler_right_inst (
		.clk(clk),
		.raw_signal(right_btn),
		.signal(right_signal)
	);
	input_handler handler_left_inst (
		.clk(clk),
		.raw_signal(left_btn),
		.signal(left_signal)
	);


	// RANDOMIZER
	wire [7:0] random;
	wire [1:0] random_rotate;
	assign random_rotate = random[7:6];
	wire [2:0] random_piece;
	assign random_piece  = (random[2:0] == 3'b111) ?  3'b001 : random[2:0];

	randomizer random_inst (
		.clk(clk),
		.LFSR_out(random)
	);

	// FSM STATE
	reg [3:0] state;
	reg [3:0] prev_state;

	// CURRENT & NEXT BLOCK DECODE
	reg 	[2:0]   	curr_piece;
	reg 	[1:0] 	curr_piece_rot;
	reg 	[3:0]   	curr_piece_x;
	reg 	[4:0]   	curr_piece_y; 
	reg 	[2:0]   	next_piece;
	reg 	[1:0] 	next_piece_rot;

	wire [15:0] 	piece_bool 	[7:0][3:0];
	wire [3:0] 	piece_height	[7:0][3:0];
	
	// I piece
	assign piece_bool[0][0] = 16'b1000100010001000; assign piece_height[0][0] = 4'd4;
	assign piece_bool[0][1] = 16'b1111000000000000; assign piece_height[0][1] = 4'd1;
	assign piece_bool[0][2] = 16'b1000100010001000; assign piece_height[0][2] = 4'd4;
	assign piece_bool[0][3] = 16'b1111000000000000; assign piece_height[0][3] = 4'd1;
	// O piece
	assign piece_bool[1][0] = 16'b1100110000000000; assign piece_height[1][0] = 4'd2;
	assign piece_bool[1][1] = 16'b1100110000000000; assign piece_height[1][1] = 4'd2;
	assign piece_bool[1][2] = 16'b1100110000000000; assign piece_height[1][2] = 4'd2;
	assign piece_bool[1][3] = 16'b1100110000000000; assign piece_height[1][3] = 4'd2;
	// T piece
	assign piece_bool[2][0] = 16'b1110010000000000; assign piece_height[2][0] = 4'd2;
	assign piece_bool[2][1] = 16'b0100110001000000; assign piece_height[2][1] = 4'd3;
	assign piece_bool[2][2] = 16'b0100111000000000; assign piece_height[2][2] = 4'd2;
	assign piece_bool[2][3] = 16'b1000110010000000; assign piece_height[2][3] = 4'd3;
	// Z piece
	assign piece_bool[3][0] = 16'b1100011000000000; assign piece_height[3][0] = 4'd2;
	assign piece_bool[3][1] = 16'b0100110010000000; assign piece_height[3][1] = 4'd3;
	assign piece_bool[3][2] = 16'b1100011000000000; assign piece_height[3][2] = 4'd2;
	assign piece_bool[3][3] = 16'b0100110010000000; assign piece_height[3][3] = 4'd3;
	// S piece
	assign piece_bool[4][0] = 16'b0110110000000000; assign piece_height[4][0] = 4'd2;
	assign piece_bool[4][1] = 16'b1000110001000000; assign piece_height[4][1] = 4'd3;
	assign piece_bool[4][2] = 16'b0110110000000000; assign piece_height[4][2] = 4'd2;
	assign piece_bool[4][3] = 16'b1000110001000000; assign piece_height[4][3] = 4'd3;
	// L piece
	assign piece_bool[5][0] = 16'b1000100011000000; assign piece_height[5][0] = 4'd3;
	assign piece_bool[5][1] = 16'b1110100000000000; assign piece_height[5][1] = 4'd2;
	assign piece_bool[5][2] = 16'b1100010001000000; assign piece_height[5][2] = 4'd3;
	assign piece_bool[5][3] = 16'b0010111000000000; assign piece_height[5][3] = 4'd2;
	// J piece
	assign piece_bool[6][0] = 16'b0100010011000000; assign piece_height[6][0] = 4'd3;
	assign piece_bool[6][1] = 16'b1000111000000000; assign piece_height[6][1] = 4'd2;
	assign piece_bool[6][2] = 16'b1100100010000000; assign piece_height[6][2] = 4'd3;
	assign piece_bool[6][3] = 16'b1110001000000000; assign piece_height[6][3] = 4'd2;

	wire [3:0] curr_piece_h;
	assign curr_piece_h = piece_height[curr_piece][curr_piece_rot];
	wire [3:0] curr_piece_w;
	assign curr_piece_w = piece_height[curr_piece][curr_piece_rot + 2'b01];
	
	// CHECK PIECE COLLISION
	wire is_curr_piece_w_ok;
	assign is_curr_piece_w_ok = (curr_piece_x + curr_piece_w < `BLOCKS_W);
	
	wire is_curr_piece_h_ok;
	assign is_curr_piece_h_ok = (curr_piece_y + curr_piece_h < `BLOCKS_H);

	wire is_rot_piece_w_ok;
	assign is_rot_piece_w_ok = (curr_piece_x + curr_piece_h <= `BLOCKS_W);
	
	wire is_rot_piece_h_ok;
	assign is_rot_piece_h_ok = (curr_piece_y + curr_piece_w <= `BLOCKS_H);
	
	wire [3:0] curr_piece_x_shift;
	assign curr_piece_x_shift = (`BLOCKS_W - 4'd1) - curr_piece_x;
	
	wire [3:0] left_piece_x_shift;
	assign left_piece_x_shift = curr_piece_x_shift + 4'd1;
	
	wire [3:0] right_piece_x_shift;
	assign right_piece_x_shift = curr_piece_x_shift - 4'd1;
	
	wire [1:0] test_piece_rot;
	assign test_piece_rot = curr_piece_rot + 2'b01;
	
	wire [4:0] test_piece_y0;
	wire [4:0] test_piece_y1;
	wire [4:0] test_piece_y2;
	wire [4:0] test_piece_y3;
	assign test_piece_y0 = curr_piece_y;
	assign test_piece_y1 = test_piece_y0 + 5'd1;
	assign test_piece_y2 = test_piece_y1 + 5'd1;
	assign test_piece_y3 = test_piece_y2 + 5'd1;
	
	wire can_down;
	assign can_down = is_curr_piece_h_ok &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][15:12]} & ({game_board[curr_piece_y + 1], 3'b0} >> curr_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][11: 8]} & ({game_board[curr_piece_y + 2], 3'b0} >> curr_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][ 7: 4]} & ({game_board[curr_piece_y + 3], 3'b0} >> curr_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][ 3: 0]} & ({game_board[curr_piece_y + 4], 3'b0} >> curr_piece_x_shift))) ;

	wire can_move_left;
	assign can_move_left = (curr_piece_x > 0) &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][15:12]} & ({game_board[test_piece_y0], 3'b000} >> left_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][11: 8]} & ({game_board[test_piece_y1], 3'b000} >> left_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][ 7: 4]} & ({game_board[test_piece_y2], 3'b000} >> left_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][ 3: 0]} & ({game_board[test_piece_y3], 3'b000} >> left_piece_x_shift))) ;

	wire can_move_right;
	assign can_move_right =  is_curr_piece_w_ok &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][15:12]} & ({game_board[test_piece_y0], 3'b000} >> right_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][11: 8]} & ({game_board[test_piece_y1], 3'b000} >> right_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][ 7: 4]} & ({game_board[test_piece_y2], 3'b000} >> right_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][curr_piece_rot][ 3: 0]} & ({game_board[test_piece_y3], 3'b000} >> right_piece_x_shift))) ;

	wire can_rotate;
	assign can_rotate = is_rot_piece_h_ok && is_rot_piece_w_ok &&
							(~|({9'b0, piece_bool[curr_piece][test_piece_rot][15:12]} & ({game_board[test_piece_y0], 3'b000} >> curr_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][test_piece_rot][11: 8]} & ({game_board[test_piece_y1], 3'b000} >> curr_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][test_piece_rot][ 7: 4]} & ({game_board[test_piece_y2], 3'b000} >> curr_piece_x_shift))) &&
							(~|({9'b0, piece_bool[curr_piece][test_piece_rot][ 3: 0]} & ({game_board[test_piece_y3], 3'b000} >> curr_piece_x_shift))) ;
	
	// SCORE
	reg [3:0] score_1, score_2, score_3; // ones, tens, hundred 

	// FALL TIMER
	reg 		 fall_signal;
	reg [9:0] fall_timer;
	localparam FALL_TIMER_MAX = 40;

	// BOOLEAN FLAGS
	wire press_any_key = down_signal | left_signal | right_signal | rotate_signal;
	wire game_over =  |game_board[0];  

	// SCREEN CHECK
	wire inside_board;
	assign inside_board = (screen_x >= `BOARD_OFFSET_X) && (screen_x < `BOARD_OFFSET_X + `BOARD_WIDTH + `GRID_STROKE) &&
								 (screen_y >= `BOARD_OFFSET_Y) && (screen_y < `BOARD_OFFSET_Y + `BOARD_HEIGHT + `GRID_STROKE) ;
	
	wire[9:0] w_mod;
	assign w_mod = ((screen_x - `BOARD_OFFSET_X) % `BLOCK_SIZE);
	wire[9:0] h_mod;
	assign h_mod = ((screen_y - `BOARD_OFFSET_Y) % `BLOCK_SIZE);
	
	wire is_grid;
	assign is_grid = inside_board && ((w_mod < `GRID_STROKE) || (h_mod < `GRID_STROKE));
	
	wire[3:0] w_div;
	assign w_div = ((screen_x - `BOARD_OFFSET_X) / `BLOCK_SIZE);
	wire[4:0] h_div;
	assign h_div = ((screen_y - `BOARD_OFFSET_Y) / `BLOCK_SIZE);
	
	wire is_curr_piece;
	assign is_curr_piece = (w_div >= curr_piece_x) && (w_div < curr_piece_x + 4'd4) && (h_div >= curr_piece_y) && (h_div < curr_piece_y + 4'd4) &&
								  (piece_bool[curr_piece][curr_piece_rot][(5'd3 - (h_div - curr_piece_y) << 2) + (4'd3 - (w_div - curr_piece_x))]) ;
	
	wire is_next_piece;
	assign is_next_piece = (screen_x > `BOARD_OFFSET_X) && (w_div >= 4'd12) && (w_div <= 4'd15) && (h_div >= 5'd1) && (h_div <= 5'd4) &&
								  (piece_bool[next_piece][next_piece_rot][(5'd3 - (h_div - 5'd1) << 2) + (4'd3 - (w_div - 4'd12))]) ;

	wire inside_score_text_area = 
        (screen_x >= `SCORE_TEXT_X) && 
        (screen_x < `SCORE_TEXT_X + (3*`DIGIT_WIDTH + 2*`DIGIT_SPACE) * `DIGIT_SCALE) &&
        (screen_y >= `SCORE_TEXT_Y) && 
        (screen_y < `SCORE_TEXT_Y + `DIGIT_HEIGHT * `DIGIT_SCALE);

	wire is_hundreds = (screen_x < `SCORE_TEXT_X + `DIGIT_WIDTH * `DIGIT_SCALE);
	 
	wire is_tens	= (screen_x < `SCORE_TEXT_X + (2 * `DIGIT_WIDTH + `DIGIT_SPACE) * `DIGIT_SCALE);

	// Score digits (bitmap)
	wire  [79:0] hundreds;
	wire  [79:0] tens;
	wire  [79:0] ones;

	score_digit_rom rom_h (
        .number(score_3),
        .data(hundreds)
    	);

    	score_digit_rom rom_t (
        .number(score_2),
        .data(tens)
    	);

    	score_digit_rom rom_o (
        .number(score_1),
        .data(ones)
	);

	// TASK: get_new_block
	// update current piece, next piece and piece position.
	task get_new_block;
	begin
		curr_piece  		<= next_piece;
		curr_piece_rot 	<= next_piece_rot;
		next_piece 		<= random_piece;
		next_piece_rot 	<= random_rotate;

		curr_piece_x  <= 4'd4;
		curr_piece_y  <= 5'd0;

	end
	endtask

	// TASK: start_game
	task start_game;
		integer i;
	begin
		score_1 <= 0;
		score_2 <= 0;
		score_3 <= 0;

		next_piece  	<= random_piece;
		next_piece_rot <= random_rotate;

		curr_piece   	<= random[4:2];
		curr_piece_rot <= random[6:5];
		curr_piece_x   <= 4'd4;
		curr_piece_y   <= 5'd0;
		
		fall_timer  <= 10'd0;
		
		for (i = 0; i < `BLOCKS_H; i = i + 1) 
		begin
			game_board[i] <= 10'd0;
		end
	end
	endtask

	// MOVEMENT TASKS
	task move_piece;
	begin
		if (fall_signal) begin
			if (!can_down) state <= `S_ADD;
			move_down();
		end

		fall_signal <= 1'b0;
		fall_timer  <= fall_timer + 10'd1;

		if (fall_timer >= FALL_TIMER_MAX) begin
			fall_signal <= 1'b1;
			fall_timer  <= 10'd0;
		end 
		else if (down_signal)
			move_down();
		else if (right_signal)
			move_right();
		else if (left_signal)
			move_left();
		else if (rotate_signal)
			rotate();
	end
	endtask

	task move_right;
	begin
		if (can_move_right)
			curr_piece_x <= curr_piece_x + 4'd1;
	end
	endtask

	task move_left;
	begin
		if (can_move_left)
			curr_piece_x <= curr_piece_x - 4'd1;
	end
	endtask

	task move_down;
	begin
		if (can_down)
			curr_piece_y <= curr_piece_y + 5'd1;
	end
	endtask

	task rotate;
	begin
		if (can_rotate)
			curr_piece_rot <= curr_piece_rot + 2'd1;
	end
	endtask
	
	// TASK: add_to_game_board
	task add_to_game_board;
		integer dy, dx;
		integer board_color_idx;
	begin
		for (dy = 0; dy < 4; dy = dy + 1)
			for (dx = 0; dx < 4; dx = dx + 1)
				if (piece_bool[curr_piece][curr_piece_rot][(3-dy)*4 + dx]) begin
					game_board[curr_piece_y + dy][(`BLOCKS_W - curr_piece_x - 4'd1) - (3'd3 - dx)] <= 1;
				end
	end
	endtask
	
	// TASK: add_to_game_board_color
	task add_to_game_board_color;
		integer dy, dx;
		integer board_color_idx;
	begin
		for (dy = 0; dy < 4; dy = dy + 1)
			for (dx = 0; dx < 4; dx = dx + 1)
				if (piece_bool[curr_piece][curr_piece_rot][(3-dy)*4 + dx]) begin
					board_color_idx = 3*((`BLOCKS_W - curr_piece_x - 4'd1) - (3'd3 - dx));
					game_board_color[curr_piece_y + dy][board_color_idx +: 3] <= curr_piece;
				end
	end
	endtask
	
	// TASK: increase_score
	// note: update difference score with difference line full
	task increase_score;
		input [2:0] num_lines;    
	begin
		case (num_lines)
			3'd1: score_1 = score_1 + 4'd1;  // single
			3'd2: score_1 = score_1 + 4'd3;  // double
			3'd3: score_1 = score_1 + 4'd5;  // triple
			3'd4: score_1 = score_1 + 4'd8;  // Tetris
			default: score_1 = score_1 + 4'd0;
		endcase

		if (score_1 > 4'd9) begin
			score_1 = score_1 - 4'd10;
			score_2 = score_2 + 4'd1;
		end
		
		if (score_2 > 4'd9) begin
			score_2 = 4'd0;
			score_3 = score_3 + 4'd1;
		end
		
		if (score_3 > 4'd9) begin
			score_3 = 4'd0;
		end
	end
	endtask


	// TASK: check_full_line 
	reg [4:0] index_map[`BLOCKS_H-1:0];
	reg [2:0] full_line_count;
	
	task check_full_line;
		integer row, idx, j;
	begin
		idx = 0;
		full_line_count = 3'd0;

		for (j = 0; j < `BLOCKS_H; j = j + 1)
			index_map[j] = 0;

		for (row =  `BLOCKS_H - 1; row >= 0; row = row - 1) begin
			if (~&game_board[row]) begin
				index_map[idx] = row;
				idx = idx + 1;
			end else begin
				full_line_count = full_line_count + 3'd1;
			end
		end
	end
	endtask

	// TASK: rebuild_board 
	task rebuild_board;
		integer i;
		integer src_row_idx;
	begin
		for (i = `BLOCKS_H - 1; i >= 0; i = i - 1) begin
			src_row_idx = index_map[`BLOCKS_H - i - 1];
			game_board[i] = game_board[src_row_idx];
		end
	end
	endtask

	task rebuild_board_color;
		integer i;
		integer src_row_idx;
	begin
		for (i = `BLOCKS_H - 1; i >= 0; i = i - 1) begin
			src_row_idx = index_map[`BLOCKS_H - i - 1];
			game_board_color[i] = game_board_color[src_row_idx];
		end
	end
	endtask

	
	task clear_board;
		integer i;
	begin
		score_1 			= 3'd0;
		score_2 			= 3'd0;
		score_3 			= 3'd0;
		
		next_piece  	= 3'd7;
		next_piece_rot = 2'd0;

		curr_piece   	= 3'd7;
		curr_piece_rot = 2'd0;

		for (i = 0; i < `BLOCKS_H; i = i + 1) 
		begin
			game_board[i] = 10'd0;
			game_board_color[i] = 30'd0;
		end
	end
	endtask

	// INITIAL RESET LOGIC
	integer init_i;
	initial begin
		
		
		state = `S_IDLE;
		fall_timer = 10'd0;
		RGB = 30'd0;
		next_piece  	= 3'd7;
		next_piece_rot = 2'd0;

		curr_piece   	= 3'd7;
		curr_piece_rot = 2'd0;
		curr_piece_x   = 4'd4;
		curr_piece_y   = 5'd0;
		
		for (init_i = 0; init_i < `BLOCKS_H; init_i = init_i + 1) 
		begin
			game_board[init_i] = 10'd0;
		end

	end

	
	//==================================================================
	// MAIN ALWAYS BLOCK (FSM)
	//==================================================================

	always @(posedge clk or negedge reset_n) begin
		if (!reset_n) begin
			state <= `S_IDLE;

			next_piece  	<= 3'd7;
			next_piece_rot <= 2'd0;

			curr_piece   	<= 3'd7;
			curr_piece_rot <= 2'd0;
			curr_piece_x   <= 4'd4;
			curr_piece_y   <= 5'd0;
		end 
		else begin

		case (state)
			`S_IDLE: begin
				if (press_any_key)
					state <= `S_START;
			end

			`S_START: begin
				start_game();
				state <= `S_PLAY;
			end

			`S_PLAY: begin
				if (sw_pause) begin
					prev_state <= `S_PLAY;
					state <= `S_PAUSE;
				end else begin
					move_piece();
				end
			end

			`S_ADD: begin
				add_to_game_board();
				if (game_over)
					state <= `S_OVER;
				else
					state <= `S_ADD_COLOR;
			end

			`S_ADD_COLOR: begin
				add_to_game_board_color();
				state <= `S_CHECK;
			end

			`S_CHECK: begin
				check_full_line();
				state <= `S_REMOVE;
			end

			`S_REMOVE: begin
				rebuild_board();
				state <= `S_RM_COLOR;
			end
			
			`S_RM_COLOR: begin
				rebuild_board_color();
				state <= `S_INC_SCR;
			end

			`S_INC_SCR: begin
				increase_score(full_line_count);
				get_new_block();
				state <= `S_PLAY;
			end

			`S_OVER: begin
				clear_board();
				
				if (press_any_key)
					state <= `S_IDLE;
			end

			`S_PAUSE: begin
				if (!sw_pause)
					state <= prev_state;
			end

			default: state <= `S_IDLE;
		endcase

		end
	end

	// DRAW PIXELS
	function [29:0] get_color;
		input [2:0] block_id;
	begin
		case (block_id)
			3'b000 : get_color = `COLOR_BLOCK_I;
			3'b001 : get_color = `COLOR_BLOCK_O;
			3'b010 : get_color = `COLOR_BLOCK_T;
			3'b011 : get_color = `COLOR_BLOCK_S;
			3'b100 : get_color = `COLOR_BLOCK_Z;
			3'b101 : get_color = `COLOR_BLOCK_J;
			3'b110 : get_color = `COLOR_BLOCK_L;
			default: get_color = `COLOR_BLOCK;
		endcase
	end
	endfunction

	wire inside_game_over_text;
	wire is_game_over_text;
	game_over_text_rom gover_rom (
		.X(screen_x),
		.Y(screen_y),
		.inside_area(inside_game_over_text),
		.is_pixel(is_game_over_text)
	);

	reg draw_pixel;
	reg [9:0] local_x, local_y;
	integer  bit_index, board_idx;
	always @(*) begin
		if (active_area) begin
			if (state == `S_OVER) begin
				RGB = (is_game_over_text) ? `COLOR_TEXT : `COLOR_BG;			
			end
			else if (inside_board) begin

				board_idx = `BLOCKS_W - w_div - 4'd1;

				if (is_grid) RGB = `COLOR_GRID;
				else if (is_curr_piece & !game_over) begin 
					RGB = get_color(curr_piece);
				end
				else if (game_board[h_div][board_idx]) begin
					RGB = get_color(game_board_color[h_div][3*board_idx +: 3]);
				end 
				else RGB = `COLOR_BLOCK;

			end else if (is_next_piece) begin

				RGB = get_color(next_piece);

			end 
			else if (inside_score_text_area) begin

				RGB = `COLOR_BG; 

				local_x = (screen_x - `SCORE_TEXT_X) / `DIGIT_SCALE; 
				local_y = (screen_y - `SCORE_TEXT_Y) / `DIGIT_SCALE; 
				// Hundreds 
				if (is_hundreds) begin 
					bit_index = (local_y * 8) + local_x; 
					if (hundreds[79 - bit_index]) RGB = `COLOR_TEXT; 
				end 
				// Tens 
				else if (is_tens) begin 
					bit_index = (local_y * 8) + (local_x - (`DIGIT_WIDTH + `DIGIT_SPACE)); 
					if (tens[79 - bit_index]) RGB = `COLOR_TEXT; 
				end 
				// Ones 
				else begin 
					bit_index = (local_y * 8) + (local_x - 2 * (`DIGIT_WIDTH + `DIGIT_SPACE)); 
					if (ones[79 - bit_index]) RGB = `COLOR_TEXT;
				end
			end else begin
				RGB = `COLOR_BG;
			end
		end
	end

endmodule