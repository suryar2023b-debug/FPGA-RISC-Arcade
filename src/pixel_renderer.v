module pixel_renderer (

    input [9:0] pixel_x, pixel_y,
    input video_on,
    input [1:0] game_mode,
    input [7:0] ball_x, ball_y, paddle1_x, paddle2_x, score1, score2, brick_state,
    output reg [7:0] red, green, blue
	 
);
	
	    // Convert screen coordinates to the 256 x 192 game area
    wire [10:0] scaled_x, scaled_y;
    wire [7:0] game_x, game_y;

    assign scaled_x = (pixel_x * 2) / 5;
    assign scaled_y = (pixel_y * 2) / 5;

    assign game_x = scaled_x[7:0];
    assign game_y = scaled_y[7:0];

    reg is_brick;
    integer i;

    always @(*) begin
        // Default: black background
        red   = 8'd0;
        green = 8'd0;
        blue  = 8'd0;
        is_brick = 1'b0;

        // Draw only inside the visible screen
        if (video_on) begin

            // HOME SCREEN: simple coloured geometric design
            if (game_mode == 2'b00) begin
                if ((game_x >= 8'd60 && game_x < 8'd196) &&
                    (game_y >= 8'd35 && game_y < 8'd55)) begin
                    red = 8'd0;
                    green = 8'd180;
                    blue = 8'd255;
                end
                else if ((game_x >= 8'd60 && game_x < 8'd196) &&
                         (game_y >= 8'd75 && game_y < 8'd95)) begin
                    red = 8'd255;
                    green = 8'd255;
                    blue = 8'd255;
                end
            end

            // PONG MODE
            else if (game_mode == 2'b01) begin

                // Left paddle: fixed X, paddle1_x controls Y
                if ((game_x >= 8'd8 && game_x < 8'd12) &&
                    (game_y >= paddle1_x &&
                     game_y < paddle1_x + 8'd24)) begin
                    red = 8'd0;
                    green = 8'd255;
                    blue = 8'd0;
                end

                // Right paddle: fixed X, paddle2_x controls Y
                else if ((game_x >= 8'd244 && game_x < 8'd248) &&
                         (game_y >= paddle2_x &&
                          game_y < paddle2_x + 8'd24)) begin
                    red = 8'd0;
                    green = 8'd180;
                    blue = 8'd255;
                end

                // Ball
                else if ((game_x >= ball_x &&
                          game_x < ball_x + 8'd4) &&
                         (game_y >= ball_y &&
                          game_y < ball_y + 8'd4)) begin
                    red = 8'd255;
                    green = 8'd255;
                    blue = 8'd255;
                end
            end

            // BREAKOUT MODE
            else if (game_mode == 2'b10) begin

                // Eight bricks across the top
                for (i = 0; i < 8; i = i + 1) begin
                    if (brick_state[i] &&
                        (game_x >= (10 + i * 30)) &&
                        (game_x <  (10 + i * 30 + 27)) &&
                        (game_y >= 8'd20 && game_y < 8'd28))
                        is_brick = 1'b1;
                end

                if (is_brick) begin
                    red = 8'd255;
                    green = 8'd100;
                    blue = 8'd0;
                end

                // Bottom paddle; paddle1_x controls horizontal position
                else if ((game_x >= paddle1_x &&
                          game_x < paddle1_x + 8'd30) &&
                         (game_y >= 8'd176 && game_y < 8'd180)) begin
                    red = 8'd0;
                    green = 8'd255;
                    blue = 8'd255;
                end

                // Ball
                else if ((game_x >= ball_x &&
                          game_x < ball_x + 8'd4) &&
                         (game_y >= ball_y &&
                          game_y < ball_y + 8'd4)) begin
                    red = 8'd255;
                    green = 8'd255;
                    blue = 8'd255;
                end
            end
        end
    end
	
endmodule