`timescale 1ns/1ns

module HDL_FPGA_Tetris_tb;

    reg clk_50;
    reg reset_n;

    reg button_down;
    reg button_rotate;
    reg button_left;
    reg button_right;

    wire vga_hsync, vga_vsync, vga_blank, vga_sync, vga_clk;
    wire [9:0] vga_r, vga_g, vga_b;

    // Instantiate DUT
    HDL_FPGA_Tetris uut (
        .clk_50(clk_50),
        .reset_n(reset_n),
        .button_down(button_down),
        .button_rotate(button_rotate),
        .button_left(button_left),
        .button_right(button_right),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .vga_blank(vga_blank),
        .vga_sync(vga_sync),
		.vga_clk(vga_clk),
        .vga_r(vga_r),
        .vga_g(vga_g),
        .vga_b(vga_b)
    );

	 
    // CLOCK GENERATION: 50 MHz
    initial begin
        clk_50 = 0;
        forever #10 clk_50 = ~clk_50; // 20 ns = 50 MHz
        forever #250_500 button_right = ~button_right;
    end

    initial begin
        reset_n = 0;
        button_down   = 0;
        button_rotate = 0;
        button_left   = 0;
        button_right  = 0;

        #200;
        reset_n = 1;
    end

    integer f;
    integer frame_id;
    initial begin
        frame_id = 0;

        // Chờ reset xong
        #2000000;

        repeat (50) begin
            capture_frame(frame_id);
            frame_id = frame_id + 1;
            #(50_000_000);   // 0.5 giây
        end

        $display("Simulation finished. Frames saved.");
        $stop;
    end


    // ------------------------------------------------------------
    // TASK: Capture VGA frame to file
    //
    // File format: hex dump of pixels {R,G,B}
    // ------------------------------------------------------------
    // ------------------------------------------------------------
// TASK: Capture VGA frame using real vsync/hsync
// ------------------------------------------------------------
reg [1023:0] filename;
task capture_frame;
    input integer id;

    integer f;
    integer x_cnt, y_cnt;

    begin
		  if (f)
            $fclose(f);
				
		  $sformat(filename, "frame_%0d.hex", id);
					 
        f = $fopen(filename, "w");
        if (!f) begin
            $display("ERROR: Cannot open output file!");
            $stop;
        end

        $display("Waiting for VSYNC start...");
        // Chờ cạnh xuống VSYNC = bắt đầu frame mới
        @(negedge vga_vsync);
			
        $display("Capturing frame %0d ...", id);

        y_cnt = 0;
		  
        while (y_cnt < 480) begin
			@(negedge vga_hsync);
            x_cnt = 0;
            while (x_cnt < 640) begin
                @(posedge clk_50);
					 @(posedge clk_50);
                if (vga_blank) begin
                    $fwrite(f, "%02h%02h%02h\n",
                        vga_r[9:2],
                        vga_g[9:2],
                        vga_b[9:2]
                    );
                    x_cnt = x_cnt + 1;
                end
            end

            y_cnt = y_cnt + 1;
        end
		  
        $fclose(f);
        $display("Frame %0d saved.", id);
    end
endtask


endmodule
