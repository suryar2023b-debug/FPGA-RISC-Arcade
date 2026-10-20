module vga_controller (
    input wire clk,
    input wire rst,

    output reg hsync,
    output reg vsync,
    output wire video_on,

    output reg [9:0] pixel_x,
    output reg [9:0] pixel_y,

    output reg pixel_clk
);

    // VGA timing parameters: 640 x 480 @ 60 Hz
    parameter H_VISIBLE = 640;
    parameter H_FRONT   = 16;
    parameter H_SYNC    = 96;
    parameter H_BACK    = 48;

    parameter V_VISIBLE = 480;
    parameter V_FRONT   = 10;
    parameter V_SYNC    = 2;
    parameter V_BACK    = 33;

    localparam H_TOTAL = H_VISIBLE + H_FRONT + H_SYNC + H_BACK;
    localparam V_TOTAL = V_VISIBLE + V_FRONT + V_SYNC + V_BACK;

    reg [9:0] h_count;
    reg [9:0] v_count;

    // Divide the 50 MHz board clock by 2
    always @(posedge clk) begin
        if (rst)
            pixel_clk <= 1'b0;
        else
            pixel_clk <= ~pixel_clk;
    end

    // Horizontal and vertical pixel counters
    always @(posedge pixel_clk) begin
        if (rst) begin
            h_count <= 10'd0;
            v_count <= 10'd0;
        end
        else begin
            if (h_count == H_TOTAL - 1) begin
                h_count <= 10'd0;

                if (v_count == V_TOTAL - 1)
                    v_count <= 10'd0;
                else
                    v_count <= v_count + 1'b1;
            end
            else begin
                h_count <= h_count + 1'b1;
            end
        end
    end

    // Current pixel coordinates
    always @(*) begin
        pixel_x = h_count;
        pixel_y = v_count;
    end

    // Active video region
    assign video_on =
        (h_count < H_VISIBLE) &&
        (v_count < V_VISIBLE);

    // VGA sync pulses are active low
    always @(*) begin
        hsync = ~((h_count >= H_VISIBLE + H_FRONT) &&
                  (h_count < H_VISIBLE + H_FRONT + H_SYNC));

        vsync = ~((v_count >= V_VISIBLE + V_FRONT) &&
                  (v_count < V_VISIBLE + V_FRONT + V_SYNC));
    end

endmodule