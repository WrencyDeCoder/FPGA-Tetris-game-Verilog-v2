`timescale 1ns/1ps

module tb_input_handler;

    reg clk = 0;
    reg down_btn = 0;
    reg rotate_btn = 0;
    reg right_btn = 0;
    reg left_btn = 0;

    wire down_signal;
    wire rotate_signal;
    wire right_signal;
    wire left_signal;


    always #20 clk = ~clk;   // 20ns period = 50MHz

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

    // ===========================
    // Stimulus
    // ===========================
    initial begin
        $display("=== Input Handler Testbench Start ===");

        // Vài chu kỳ chờ ổn định
        #50;

        // ---------- Test DOWN ----------
        $display("[TEST] DOWN button");
        down_btn = 1; #600;
        down_btn = 0; #1000;

        // ---------- Test ROTATE ----------
        $display("[TEST] ROTATE button");
        rotate_btn = 1; #600;
        rotate_btn = 0; #1000;

        // ---------- Test RIGHT ----------
        $display("[TEST] RIGHT button");
        right_btn = 1; #1000;
        right_btn = 0; #1500;

        // ---------- Test LEFT ----------
        $display("[TEST] LEFT button");
        left_btn = 1; #500;
        left_btn = 0; #1000;

        $display("=== Test Done ===");
        $stop;
    end

    // ===========================
    // Monitor
    // ===========================
    initial begin
        $monitor("T=%0t | D:%b R:%b R2:%b L:%b  || out D:%b R:%b R2:%b L:%b",
                 $time,
                 down_btn, rotate_btn, right_btn, left_btn,
                 down_signal, rotate_signal, right_signal, left_signal);
    end

endmodule
