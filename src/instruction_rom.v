module instruction_rom(
	input [7:0] address,
	output reg [15:0] instruction
);
	reg [15:0] rom [0:255];
	integer i;
	
	initial 
	begin
		for(i=0;i<256;i= i+1)
			rom[i] = 16'd0;
	end
	
	always@(*)
	begin
		instruction = rom[address];
	end
	
endmodule