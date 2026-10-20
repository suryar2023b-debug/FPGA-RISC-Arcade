module RISC_Arcade (
    // Clock and switches
    input  wire        CLOCK_50,
    input  wire [9:0]  SW,
    input  wire [3:0]  KEY,

    // VGA interface
    output wire        VGA_CLK,
    output wire        VGA_HS,
    output wire        VGA_VS,
    output wire        VGA_BLANK_N,
    output wire        VGA_SYNC_N,
    output wire [7:0]  VGA_R,
    output wire [7:0]  VGA_G,
    output wire [7:0]  VGA_B,

    // Seven-segment displays
    output wire [6:0]  HEX0,
    output wire [6:0]  HEX1,
    output wire [6:0]  HEX2,
    output wire [6:0]  HEX3,
    output wire [6:0]  HEX4,
    output wire [6:0]  HEX5
);

    // =========================================================
    // 1. RESET, GAME MODE AND CONTROLS
    // =========================================================

    wire rst;
    wire [1:0] game_mode;
    wire [3:0] controls;

    assign rst       = SW[9];
    assign game_mode = SW[1:0];

    assign controls = SW[5:2];

    // =========================================================
    // 2. CPU MEMORY-MAPPED I/O BUS
    // =========================================================

    wire [7:0] cpu_io_addr;
    wire [7:0] cpu_io_wdata;
    wire [7:0] cpu_io_rdata;
    wire       cpu_io_write;
    wire       cpu_halt;

    cpu cpu_inst (
        .clk       (CLOCK_50),
        .rst       (rst),
        .io_rdata  (cpu_io_rdata),
        .io_addr   (cpu_io_addr),
        .io_wdata  (cpu_io_wdata),
        .halt      (cpu_halt),
        .io_write  (cpu_io_write)
    );

    // CPU-facing memory-mapped peripheral.
    // The address map is defined in game_io.v.
    wire [7:0] io_ball_x;
    wire [7:0] io_ball_y;
    wire [7:0] io_paddle1_x;
    wire [7:0] io_paddle2_x;
    wire [7:0] io_score1;
    wire [7:0] io_score2;
    wire [7:0] io_brick_state;

    game_io game_io_inst (
        .clk         (CLOCK_50),
        .rst         (rst),
        .io_addr     (cpu_io_addr),
        .io_write    (cpu_io_write),
        .io_wdata    (cpu_io_wdata),
        .game_mode   (game_mode),
        .controls    (controls),
        .io_rdata    (cpu_io_rdata),
        .ball_x      (io_ball_x),
        .ball_y      (io_ball_y),
        .paddle1_x   (io_paddle1_x),
        .paddle2_x   (io_paddle2_x),
        .score1      (io_score1),
        .score2      (io_score2),
        .brick_state (io_brick_state)
    );

    // =========================================================
    // 3. GAME ENGINE
    // =========================================================

    wire [7:0] ball_x;
    wire [7:0] ball_y;
    wire [7:0] paddle1_x;
    wire [7:0] paddle2_x;
    wire [7:0] score1;
    wire [7:0] score2;
    wire [7:0] brick_state;

    game_engine game_engine_inst (
        .clk         (CLOCK_50),
        .rst         (rst),
        .game_mode   (game_mode),
        .controls    (controls),
        .ball_x      (ball_x),
        .ball_y      (ball_y),
        .paddle1_x   (paddle1_x),
        .paddle2_x   (paddle2_x),
        .score1      (score1),
        .score2      (score2),
        .brick_state (brick_state)
    );

    // =========================================================
    // 4. VGA TIMING CONTROLLER
    // =========================================================

    wire video_on;
    wire [9:0] pixel_x;
    wire [9:0] pixel_y;
    wire pixel_clk;

    vga_controller vga_inst (
        .clk      (CLOCK_50),
        .rst      (rst),
        .hsync    (VGA_HS),
        .vsync    (VGA_VS),
        .video_on (video_on),
        .pixel_x  (pixel_x),
        .pixel_y  (pixel_y),
        .pixel_clk(pixel_clk)
    );

    assign VGA_CLK     = pixel_clk;
    assign VGA_BLANK_N = video_on;
    assign VGA_SYNC_N  = 1'b0;

    // =========================================================
    // 5. PIXEL RENDERER
    // =========================================================

    wire [7:0] red;
    wire [7:0] green;
    wire [7:0] blue;

    pixel_renderer renderer_inst (
        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y),
        .video_on   (video_on),
        .game_mode  (game_mode),
        .ball_x     (ball_x),
        .ball_y     (ball_y),
        .paddle1_x  (paddle1_x),
        .paddle2_x  (paddle2_x),
        .score1     (score1),
        .score2     (score2),
        .brick_state(brick_state),
        .red        (red),
        .green      (green),
        .blue       (blue)
    );

    assign VGA_R = red;
    assign VGA_G = green;
    assign VGA_B = blue;

    // =========================================================
    // 6. SEVEN-SEGMENT SCORE DISPLAYS
    // =========================================================
    // Scores are displayed in hexadecimal:
    // HEX1:HEX0 = Player 1 score
    // HEX3:HEX2 = Player 2 score
    // HEX4 and HEX5 show the game mode.

    function [6:0] hex_to_7seg;
        input [3:0] value;
        begin
            // Active-low segments: {g,f,e,d,c,b,a}
            case (value)
                4'h0: hex_to_7seg = 7'b1000000;
                4'h1: hex_to_7seg = 7'b1111001;
                4'h2: hex_to_7seg = 7'b0100100;
                4'h3: hex_to_7seg = 7'b0110000;
                4'h4: hex_to_7seg = 7'b0011001;
                4'h5: hex_to_7seg = 7'b0010010;
                4'h6: hex_to_7seg = 7'b0000010;
                4'h7: hex_to_7seg = 7'b1111000;
                4'h8: hex_to_7seg = 7'b0000000;
                4'h9: hex_to_7seg = 7'b0010000;
                4'hA: hex_to_7seg = 7'b0001000;
                4'hB: hex_to_7seg = 7'b0000011;
                4'hC: hex_to_7seg = 7'b1000110;
                4'hD: hex_to_7seg = 7'b0100001;
                4'hE: hex_to_7seg = 7'b0000110;
                4'hF: hex_to_7seg = 7'b0001110;
                default: hex_to_7seg = 7'b1111111;
            endcase
        end
    endfunction

    assign HEX0 = hex_to_7seg(score1[3:0]);
    assign HEX1 = hex_to_7seg(score1[7:4]);

    assign HEX2 = hex_to_7seg(score2[3:0]);
    assign HEX3 = hex_to_7seg(score2[7:4]);

    assign HEX4 = hex_to_7seg({2'b00, game_mode});
    assign HEX5 = 7'b1111111;

endmodule