module game_io (

    input wire clk, rst, io_write,
    input [7:0] io_wdata, io_addr,
    input [1:0] game_mode,
    input [3:0] controls,

    output reg [7:0] io_rdata, ball_x, ball_y,paddle1_x, paddle2_x, score1, score2, brick_state
);

    // CPU reads game registers through this multiplexer
    always @(*) begin
        case (io_addr)
            8'hF0: io_rdata = {6'b0, game_mode};
            8'hF1: io_rdata = {4'b0, controls};
            8'hF2: io_rdata = ball_x;
            8'hF3: io_rdata = ball_y;
            8'hF4: io_rdata = paddle1_x;
            8'hF5: io_rdata = paddle2_x;
            8'hF6: io_rdata = score1;
            8'hF7: io_rdata = score2;
            8'hF8: io_rdata = brick_state;
            default: io_rdata = 8'h00;
        endcase
    end

    // CPU writes game-state registers on the rising clock edge
    always @(posedge clk) begin
        if (rst) begin
            ball_x     <= 8'h00;
            ball_y     <= 8'h00;
            paddle1_x  <= 8'h00;
            paddle2_x  <= 8'h00;
            score1     <= 8'h00;
            score2     <= 8'h00;
            brick_state <= 8'h00;
        end
        else if (io_write) begin
            case (io_addr)
                8'hF2: ball_x      <= io_wdata;
                8'hF3: ball_y      <= io_wdata;
                8'hF4: paddle1_x   <= io_wdata;
                8'hF5: paddle2_x   <= io_wdata;
                8'hF6: score1      <= io_wdata;
                8'hF7: score2      <= io_wdata;
                8'hF8: brick_state <= io_wdata;
                default: ;  // Ignore writes to other addresses
            endcase
        end
    end

endmodule