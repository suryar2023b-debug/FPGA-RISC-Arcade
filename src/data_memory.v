module data_memory(
	input clk, rst, mem_read, mem_write,
	input [7:0] address, write_data, 
	output reg [7:0] read_data
);

	reg [7:0] memory [0:255];
	integer i;

	always @(posedge clk)
	begin 
		if (rst)
		begin
			for(i = 0;i<256;i = i+1)
			begin
				memory[i] <= 8'b0;
			end
		end
		else if(mem_write)
			memory[address] <= write_data;
	end
	
	always @(*)
	begin
		if(mem_read)
			read_data = memory[address];
		else
			read_data = 8'b0;
	end

endmodule