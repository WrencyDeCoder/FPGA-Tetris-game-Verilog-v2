//======================================================
// game_over_text_rom.v
//======================================================
module game_over_text_rom (
	input  wire [9:0] X,
	input  wire [9:0] Y,
	
	output wire inside_area,
	output reg  is_pixel
);

    localparam integer TEXT_W = 104;
	localparam integer TEXT_H = 11;
	
    localparam integer MSG_X = 180;
    localparam integer MSG_Y = 180;

    localparam [1144:0] text_bitmap = {
        8'h0F,     8'hC0,     8'h00,     8'h00,     8'h00,     8'h00,     8'h00,     8'h7F,     8'h00,     8'h00,     8'h00,     8'h00,     8'h00,   // row 0
        8'h38,     8'hE0,     8'h00,     8'h00,     8'h00,     8'h00,     8'h01,     8'hC3,     8'h80,     8'h00,     8'h00,     8'h00,     8'h00,   // row 1
        8'h70,     8'h00,     8'h00,     8'h00,     8'h00,     8'h00,     8'h01,     8'hC3,     8'h80,     8'h00,     8'h00,     8'h00,     8'h00,   // row 2
        8'h70,     8'h00,     8'h00,     8'h00,     8'h00,     8'h00,     8'h01,     8'hC3,     8'h80,     8'h00,     8'h00,     8'h00,     8'h00,   // row 3
        8'h70,     8'h01,     8'hFC,     8'h7F,     8'hC1,     8'hFC,     8'h01,     8'hC3,     8'h9C,     8'h38,     8'h7F,     8'h1C,     8'hF0,   // row 4
        8'h77,     8'hE0,     8'h0E,     8'h76,     8'hE7,     8'h0E,     8'h01,     8'hC3,     8'h9C,     8'h39,     8'hC3,     8'h9F,     8'h00,   // row 5
        8'h70,     8'hE0,     8'h0E,     8'h72,     8'hE7,     8'h0E,     8'h01,     8'hC3,     8'h9C,     8'h39,     8'hC3,     8'h9C,     8'h00,   // row 6
        8'h70,     8'hE1,     8'hFE,     8'h72,     8'hE7,     8'hFE,     8'h01,     8'hC3,     8'h9C,     8'h39,     8'hFF,     8'h9C,     8'h00,   // row 7
        8'h38,     8'hE7,     8'h0E,     8'h72,     8'hE7,     8'h00,     8'h01,     8'hC3,     8'h8E,     8'h71,     8'hC0,     8'h1C,     8'h00,   // row 8
        8'h08,     8'hE1,     8'h0E,     8'h72,     8'hE1,     8'h00,     8'h00,     8'h43,     8'h0E,     8'h70,     8'h40,     8'h1C,     8'h00,   // row 9
        8'h0F,     8'hE1,     8'hFE,     8'h72,     8'hE1,     8'hFC,     8'h00,     8'h7F,     8'h03,     8'hC0,     8'h7F,     8'h1C,     8'h00   // row 10
    };

    // -------------------------------------------
    // Inside display area
    // -------------------------------------------
    assign inside_area =
        (X >= MSG_X) && (X < MSG_X + TEXT_W*3) &&
        (Y >= MSG_Y) && (Y < MSG_Y + TEXT_H*3);

    // -------------------------------------------
    // Pixel fetch
    // -------------------------------------------

    integer row, col, bit_index;

    always @(*) begin
        if (inside_area) begin
            row = (Y - MSG_Y)/3;          
            col = (X - MSG_X)/3;         

            bit_index = (TEXT_H-row-1) * TEXT_W + (TEXT_W-1-col);

            is_pixel = text_bitmap[bit_index];

        end else begin
            is_pixel = 1'b0;
        end
    end

endmodule
