`include "definitions.vh"

module vga_controller (
    input 	wire			clk_25,
    input 	wire 			reset_n,
    output 	reg [9:0] 	x,
    output  reg [9:0] 	y,
    output 	reg			hsync,
    output 	reg			vsync,
    output 	reg			active_area,
	 output 	wire 			vga_clk,
    output 	wire 			blank,
    output 	wire 			sync
);

    reg [9:0] h_count;
    reg [9:0] v_count;

    // ======== Horizontal & Vertical counters ========
    always @(posedge clk_25 or negedge reset_n) begin
		  if (!reset_n) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end else begin
            if (h_count == `H_TOTAL - 1) begin
                h_count <= 10'd0;
                if (v_count == `V_TOTAL - 1)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 10'd1;
            end else begin
                h_count <= h_count + 10'd1;
            end
        end
    end
	 
    always @(*) begin
        x = h_count;
        y = v_count;

        // HSYNC (active low)
        if (h_count >= (`H_VISIBLE + `H_FRONT) &&
            h_count < (`H_VISIBLE + `H_FRONT + `H_SYNC))
            hsync = 1'b0;
        else
            hsync = 1'b1;

        // VSYNC (active low)
        if (v_count >= (`V_VISIBLE + `V_FRONT) &&
            v_count < (`V_VISIBLE + `V_FRONT + `V_SYNC))
            vsync = 1'b0;
        else
            vsync = 1'b1;

        // Active area flag
        if (h_count < `H_VISIBLE && v_count < `V_VISIBLE)
            active_area = 1'b1;
        else
            active_area = 1'b0;
    end
	 
	 assign vga_clk = clk_25;
	 assign blank   = active_area;
	 assign sync 	 = 1'b0;
	 
endmodule
