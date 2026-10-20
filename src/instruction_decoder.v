module instruction_decoder (
    input [15:0] instruction,
    output reg  [3:0]  opcode,
    output reg  [2:0]  reg_a, reg_b, reg_dest,
    output reg  [7:0]  extra
);

	always @(*)
	begin
		opcode = instruction[15:12] ;
		reg_dest = instruction[11:9] ;
		reg_a = instruction[8:6] ;
		reg_b = instruction[5:3] ;
		extra = instruction[7:0];
	
		 if (opcode == 4'b1010)
        reg_a = instruction[10:8];
	end

endmodule