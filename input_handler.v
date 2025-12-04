module input_handler (
    input  wire clk,
    input  wire raw_signal,       
    output wire signal          
);

    parameter INITIAL_DELAY = 20; 
    parameter REPEAT_RATE   = 3;   

    reg prev = 1'd0;
    reg [7:0] counter = 8'd0;
    reg repeating = 1'd0;

    wire rising = raw_signal & ~prev;       

    reg out_pulse = 1'd0;

    assign signal = out_pulse;

    always @(posedge clk) begin
        prev <= raw_signal;
        out_pulse <= 1'd0;

        if (rising) begin
            out_pulse <= 1'd1;
            counter <= 8'd0;
            repeating <= 1'd0;

        end else if (raw_signal) begin
            counter <= counter + 8'd1;

            if (!repeating) begin
                if (counter >= INITIAL_DELAY) begin
                    repeating <= 1'd1;
                    counter <= 8'd0;
                    out_pulse <= 1'd1;    
                end
            end else begin
                if (counter >= REPEAT_RATE) begin
                    counter <= 0;
                    out_pulse <= 1;    
                end
            end

        end else begin
            counter <= 8'd0;
            repeating <= 1'd0;
        end
    end
endmodule
