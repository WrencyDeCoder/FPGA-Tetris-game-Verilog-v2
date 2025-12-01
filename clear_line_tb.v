`timescale 1ns/1ps

module tb_clear_line;

    parameter BLOCKS_W = 10;
    parameter BLOCKS_H = 20;

    // ----- DUT: tạo phiên bản rút gọn để test -----
    reg clk = 0;
    reg reset_n = 1;

    reg [BLOCKS_W-1:0] game_board [0:BLOCKS_H-1];
    wire is_full_line[BLOCKS_H-1:0];
    reg [4:0] index_map [0:BLOCKS_H-1];

    integer i;

    // ----- Generate full/empty row detection -----
    genvar r;
    generate
        for (r = 0; r < BLOCKS_H; r = r + 1) begin : CHECK_LINE
            assign is_full_line[r] = &game_board[r];
        end
    endgenerate

    // ----- TASK: increase_score dummy -----
    task increase_score(input [2:0] x);
    begin
        $display("Score increased by %0d lines", x);
    end
    endtask


    // ---------------------------------------------------------
    // TASK: check_full_line (bản của bạn)
    // ---------------------------------------------------------
    task check_full_line;
          reg [4:0] row;
        integer idx, j;
        reg [2:0] full_line_count;
    begin
        idx = 0;
        full_line_count = 0;

        for (j = 0; j < BLOCKS_H; j = j + 1)
            index_map[j] = 0;

        for (row = BLOCKS_H; row > 0; row = row - 1) begin
            if (~&game_board[row]) begin
                index_map[idx] = row;
                idx = idx + 1;
            end else begin
                full_line_count = full_line_count + 3'd1;
            end
        end

        increase_score(full_line_count);
    end
    endtask


    // ---------------------------------------------------------
    // TASK: rebuild_board (bản của bạn)
    // ---------------------------------------------------------
    task rebuild_board;
        integer i;
        reg [4:0] src_row_idx;
    begin
        for (i = BLOCKS_H - 1; i  >= 0; i = i - 1) begin
            src_row_idx = index_map[BLOCKS_H - i - 1];
            game_board[i] = game_board[src_row_idx];
        end
    end
    endtask


    // ---------------------------------------------------------
    // PRINT BOARD
    // ---------------------------------------------------------
    task print_board;
        integer r;
    begin
        for (r = BLOCKS_H-1; r >= 0; r = r - 1) begin
            $display("[%2d] %b", r, game_board[r]);
        end
        $display("");
    end
    endtask


    // ---------------------------------------------------------
    // TEST SEQUENCE
    // ---------------------------------------------------------
    initial begin
        // --------------------------
        // 1. Tạo dữ liệu test
        // --------------------------
        // clear all
        for (i=0; i<BLOCKS_H; i=i+1)
            game_board[i] = 10'b0000000000;

        // tạo 2 dòng full: row 18 và 16
        game_board[18] = 10'b1111111111;
        game_board[16] = 10'b1111111111;

        // tạo vài dòng có block
        game_board[19] = 10'b1000100001;
        game_board[17] = 10'b0001100000;
        game_board[15] = 10'b0100000100;

        $display("===== BEFORE CHECK =====");
        print_board();

        // --------------------------
        // 2. chạy task check_full_line
        // --------------------------
        check_full_line();

        $display("index_map (rows kept, bottom->top):");
        for (i=0; i<BLOCKS_H; i=i+1) begin
            $display("index_map[%0d] = %0d", i, index_map[i]);
        end
        $display("");

        // --------------------------
        // 3. rebuild board
        // --------------------------
        rebuild_board();

        $display("===== AFTER REBUILD =====");
        print_board();

        $stop;
    end

endmodule
