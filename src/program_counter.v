module program_counter (
    input clk,rst,en,jump,
    input [7:0] jump_address,
    output reg [7:0] pc
);
	 
	 always @(posedge clk)
		begin
			if (rst)
				pc <= 8'b0;
			else if(en)
				begin
					if (jump)
						pc <= jump_address;
					else
						pc <= pc + 1'b1;
				end
			else
				pc <= pc;
		end

endmodule