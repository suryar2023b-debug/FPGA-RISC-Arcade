module game_engine (
    input wire clk,
    input wire rst,
    input wire [1:0] game_mode,
    input wire [3:0] controls,

    output reg [7:0] ball_x,
    output reg [7:0] ball_y,
    output reg [7:0] paddle1_x,
    output reg [7:0] paddle2_x,
    output reg [7:0] score1,
    output reg [7:0] score2,
    output reg [7:0] brick_state
);

    // 50 MHz clock / 1,000,000 = 50 game updates per second
    reg [19:0] tick_count;
    wire game_tick = (tick_count == 20'd999999);

    reg ball_right;
    reg ball_down;

    integer i;
    reg brick_hit;

    always @(posedge clk) begin
        if (rst) begin
            tick_count  <= 0;

            ball_x      <= 120;
            ball_y      <= 90;
            ball_right  <= 1'b1;
            ball_down   <= 1'b1;

            paddle1_x   <= 80;
            paddle2_x   <= 80;

            score1      <= 0;
            score2      <= 0;
            brick_state <= 8'hFF;

        end else begin

            // Game update timer
            if (game_tick)
                tick_count <= 0;
            else
                tick_count <= tick_count + 1'b1;

            if (game_tick && game_mode == 2'b01) begin
                // =================================================
                // PONG
                // =================================================

                // Move left paddle vertically
                if (controls[0] && paddle1_x > 0)
                    paddle1_x <= paddle1_x - 1'b1;
                else if (controls[1] && paddle1_x < 167)
                    paddle1_x <= paddle1_x + 1'b1;

                // Move right paddle vertically
                if (controls[2] && paddle2_x > 0)
                    paddle2_x <= paddle2_x - 1'b1;
                else if (controls[3] && paddle2_x < 167)
                    paddle2_x <= paddle2_x + 1'b1;

                // Vertical wall bounce
                if (ball_down) begin
                    if (ball_y >= 187) begin
                        ball_down <= 1'b0;
                        ball_y <= ball_y - 1'b1;
                    end else begin
                        ball_y <= ball_y + 1'b1;
                    end
                end else begin
                    if (ball_y <= 1) begin
                        ball_down <= 1'b1;
                        ball_y <= ball_y + 1'b1;
                    end else begin
                        ball_y <= ball_y - 1'b1;
                    end
                end

                // LEFT side:
                // At the paddle, either bounce or award Player 2.
                if (!ball_right && ball_x <= 13) begin
                    if (ball_y >= paddle1_x &&
                        ball_y <= paddle1_x + 24) begin
                        ball_right <= 1'b1;
                        ball_x <= 14;
                    end else if (ball_x <= 1) begin
                        score2 <= score2 + 1'b1;
                        ball_x <= 120;
                        ball_y <= 90;
                        ball_right <= 1'b1;
                        ball_down <= 1'b1;
                    end else begin
                        ball_x <= ball_x - 1'b1;
                    end
                end

                // RIGHT side:
                // At the paddle, either bounce or award Player 1.
                else if (ball_right && ball_x >= 243) begin
                    if (ball_y >= paddle2_x &&
                        ball_y <= paddle2_x + 24) begin
                        ball_right <= 1'b0;
                        ball_x <= 242;
                    end else if (ball_x >= 254) begin
                        score1 <= score1 + 1'b1;
                        ball_x <= 120;
                        ball_y <= 90;
                        ball_right <= 1'b0;
                        ball_down <= 1'b1;
                    end else begin
                        ball_x <= ball_x + 1'b1;
                    end
                end

                // Ball is away from either paddle
                else begin
                    if (ball_right)
                        ball_x <= ball_x + 1'b1;
                    else
                        ball_x <= ball_x - 1'b1;
                end
            end

            if (game_tick && game_mode == 2'b10) begin
                // =================================================
                // BREAKOUT
                // =================================================

                // Move bottom paddle horizontally
                if (controls[0] && paddle1_x > 0)
                    paddle1_x <= paddle1_x - 1'b1;
                else if (controls[1] && paddle1_x < 225)
                    paddle1_x <= paddle1_x + 1'b1;

                brick_hit = 1'b0;

                // Horizontal wall bounce
                if (ball_right) begin
                    if (ball_x >= 251) begin
                        ball_right <= 1'b0;
                        ball_x <= ball_x - 1'b1;
                    end else begin
                        ball_x <= ball_x + 1'b1;
                    end
                end else begin
                    if (ball_x == 0) begin
                        ball_right <= 1'b1;
                        ball_x <= ball_x + 1'b1;
                    end else begin
                        ball_x <= ball_x - 1'b1;
                    end
                end

                // Vertical movement and top-wall bounce
                if (ball_down) begin
                    if (ball_y >= 187) begin
                        ball_down <= 1'b0;
                        ball_y <= ball_y - 1'b1;
                    end else begin
                        ball_y <= ball_y + 1'b1;
                    end
                end else begin
                    if (ball_y <= 1) begin
                        ball_down <= 1'b1;
                        ball_y <= ball_y + 1'b1;
                    end else begin
                        ball_y <= ball_y - 1'b1;
                    end
                end

                // Bounce from the paddle when travelling downward
                if (ball_down &&
                    ball_y >= 171 && ball_y <= 180 &&
                    ball_x + 3 >= paddle1_x &&
                    ball_x <= paddle1_x + 30) begin
                    ball_down <= 1'b0;
                    ball_y <= 170;
                end

                // Brick collision: remove at most one brick per tick
                // Only detect a collision while the ball moves upward.
                if (!ball_down &&
                    ball_y >= 20 && ball_y <= 28) begin
                    for (i = 0; i < 8; i = i + 1) begin
                        if (!brick_hit &&
                            brick_state[i] &&
                            ball_x + 3 >= (10 + i * 30) &&
                            ball_x < (10 + i * 30 + 27)) begin

                            brick_state[i] <= 1'b0;
                            ball_down <= 1'b1;
                            ball_y <= 29;
                            score1 <= score1 + 1'b1;
                            brick_hit = 1'b1;
                        end
                    end
                end

                // Ball missed the paddle: restart the ball.
                // No point is awarded for this event.
                if (ball_y >= 187) begin
						  brick_state <= 8'hFF;
                    ball_x <= 120;
                    ball_y <= 90;
                    ball_right <= 1'b1;
                    ball_down <= 1'b1;
						  score1 <= 0;
						  score2 <= 0;
                end

                // When all bricks are gone, restore them for a new round.
                if (brick_state == 8'h00) begin
                    brick_state <= 8'hFF;
                    ball_x <= 120;
                    ball_y <= 90;
                    ball_right <= 1'b1;
                    ball_down <= 1'b1;
						  score1 <= 0;
						  score2 <= 0;
                end
            end
        end
    end

endmodule