`include "definitions.vh"

module collision_core (
    input  wire [15:0] piece_bool,                // 4x4 matrix
    input  wire [3:0] piece_x,
    input  wire [4:0] piece_y,
    input  wire [3:0] piece_w,
    input  wire [3:0] piece_h,
    input  wire [`BLOCKS_W-1:0] game_board[`BLOCKS_H-1:0],
    output reg  collide
);
    integer dy, dx;

    always @(*) begin
        collide = 0;

        for (dy = 0; dy < piece_h; dy = dy + 1)
        for (dx = 0; dx < piece_w; dx = dx + 1) begin
            
            // Lấy bit block tại (dy, dx)
            if (piece_bool[(3-dy)*4 + (3-dx)]) begin

                // Kiểm tra board
                if (game_board[piece_y + dy][piece_x + dx])
                    collide = 1;
            end
        end
    end
endmodule

module collision_down (
    input  wire [15:0] piece_bool,
    input  wire [3:0]  piece_w,
    input  wire [3:0]  piece_h,
    input  wire [3:0]  piece_x,
    input  wire [4:0]  piece_y,
    input  wire [`BLOCKS_W-1:0] game_board[`BLOCKS_H-1:0],
    output wire can_down
);

    wire collide;

    collision_core core (
        .piece_bool(piece_bool),
        .piece_x(piece_x),
        .piece_y(piece_y + 1),
        .piece_w(piece_w),
        .piece_h(piece_h),
        .game_board(game_board),
        .collide(collide)
    );

    assign can_down = ~collide;
endmodule

module collision_left (
    input  wire [15:0] piece_bool,
    input  wire [3:0]  piece_w,
    input  wire [3:0]  piece_h,
    input  wire [3:0]  piece_x,
    input  wire [4:0]  piece_y,
    input  wire [`BLOCKS_W-1:0] game_board[`BLOCKS_H-1:0],
    output wire can_left
);

    wire collide;

    collision_core core (
        .piece_bool(piece_bool),
        .piece_x(piece_x - 1),
        .piece_y(piece_y),
        .piece_w(piece_w),
        .piece_h(piece_h),
        .game_board(game_board),
        .collide(collide)
    );

    assign can_left = (piece_x > 0) && ~collide;
endmodule

module collision_right (
    input  wire [15:0] piece_bool,
    input  wire [3:0]  piece_w,
    input  wire [3:0]  piece_h,
    input  wire [3:0]  piece_x,
    input  wire [4:0]  piece_y,
    input  wire [`BLOCKS_W-1:0] game_board[`BLOCKS_H-1:0],
    output wire can_right
);

    wire collide;

    collision_core core (
        .piece_bool(piece_bool),
        .piece_x(piece_x + 1),
        .piece_y(piece_y),
        .piece_w(piece_w),
        .piece_h(piece_h),
        .game_board(game_board),
        .collide(collide)
    );

    assign can_right = (piece_x + piece_w < `BLOCKS_W) && ~collide;
endmodule

module collision_rotate (
    input  wire [15:0] piece_next_bool,
    input  wire [3:0]  piece_next_w,
    input  wire [3:0]  piece_next_h,
    input  wire [3:0]  piece_x,
    input  wire [4:0]  piece_y,
    input  wire [`BLOCKS_W-1:0] game_board[`BLOCKS_H-1:0],
    output wire can_rotate
);

    wire collide;

    collision_core core (
        .piece_bool(piece_next_bool),
        .piece_x(piece_x),
        .piece_y(piece_y),
        .piece_w(piece_next_w),
        .piece_h(piece_next_h),
        .game_board(game_board),
        .collide(collide)
    );

    assign can_rotate = ~collide;
endmodule

// module collision (
//      input  wire [15:0] piece_next_bool,
//      input  wire [3:0]  piece_next_w,
//      input  wire [3:0]  piece_next_h,
//      input  wire [3:0]  piece_x,
//      input  wire [4:0]  piece_y,
//      input  wire [`BLOCKS_W-1:0] game_board[`BLOCKS_H-1:0],

//      output can_down,
//      output can_rotate,
//      output can_move_left,
//      output can_move_right
// );
//      collision_down col_down_inst (
//           .piece_bool(piece_bool[curr_piece][curr_piece_rot]),
//           .piece_h(curr_piece_h),
//           .piece_x(curr_piece_x),
//           .piece_y(curr_piece_y),
//           .game_board(game_board),
//           .can_down(can_down)
//      );

//      collision_down col_down_inst (
//           .piece_bool(piece_bool[curr_piece][curr_piece_rot]),
//           .piece_h(curr_piece_h),
//           .piece_x(curr_piece_x),
//           .piece_y(curr_piece_y),
//           .game_board(game_board),
//           .can_down(can_down)
//      );

//      collision_down col_down_inst (
//           .piece_bool(piece_bool[curr_piece][curr_piece_rot]),
//           .piece_h(curr_piece_h),
//           .piece_x(curr_piece_x),
//           .piece_y(curr_piece_y),
//           .game_board(game_board),
//           .can_down(can_down)
//      );

//      collision_down col_down_inst (
//           .piece_bool(piece_bool[curr_piece][curr_piece_rot]),
//           .piece_h(curr_piece_h),
//           .piece_x(curr_piece_x),
//           .piece_y(curr_piece_y),
//           .game_board(game_board),
//           .can_down(can_down)
//      );

     
// endmodule