module alu (
    input [7:0] a, b,
    input [2:0] alu_control,
    output reg [7:0] result,
    output reg zero, carry
);

    parameter ADD  = 3'b000,
              SUB  = 3'b001,
              AND  = 3'b010,
              OR   = 3'b011,
              XOR  = 3'b100,
              PASS = 3'b101;

    reg [8:0] temp;

    always @(*) begin
        result = 8'd0;
        carry  = 1'b0;
        temp   = 9'd0;

        case (alu_control)
            ADD: begin
                temp   = {1'b0, a} + {1'b0, b};
                result = temp[7:0];
                carry  = temp[8];
            end

            SUB: begin
                result = a - b;
            end

            AND: begin
                result = a & b;
            end

            OR: begin
                result = a | b;
            end

            XOR: begin
                result = a ^ b;
            end

            PASS: begin
                result = a;
            end

            default: begin
                result = 8'd0;
            end
        endcase

        zero = (result == 8'd0);
    end

endmodule