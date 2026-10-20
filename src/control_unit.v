module control_unit(
	
	input [3:0] opcode,
	input zero_flag_alu,
	
	output reg [2:0] alu_control,
	output reg reg_write, alu_src, mem_read, mem_write, pc_jump, halt
	
);

	parameter 	LDI = 4'b0001,
					ADD = 4'b0010,	
					SUB = 4'b0011,
					AND = 4'b0100,
					OR = 4'b0101,
					XOR = 4'b0110,
					JMP = 4'b0111,
					BZ = 4'b1000,
					LD = 4'b1001,
					ST = 4'b1010,
					HALT = 4'b1011;
					
	 always @(*)
	 begin
	 
		alu_control = 3'b0;
		reg_write = 1'b0; 
		alu_src = 1'b0; 
		mem_read = 1'b0; 
		mem_write = 1'b0;
		pc_jump = 1'b0; 
		halt = 1'b0;
		
		case(opcode)
		
			LDI:
			begin
				alu_control = 3'b101;
				reg_write = 1'b1; 
				alu_src = 1'b1; 
			end
			
			ADD:
			begin
				alu_control = 3'b000;
				reg_write = 1'b1; 
			end
			
			SUB:
			begin
				alu_control = 3'b001;
				reg_write = 1'b1; 
			end
			
			AND:
			begin
				alu_control = 3'b010;
				reg_write = 1'b1; 
			end
			
			OR:
			begin
				alu_control = 3'b011;
				reg_write = 1'b1;
			end
			
			XOR:
			begin
				alu_control = 3'b100;
				reg_write = 1'b1; 
			end
			
			JMP:
			begin 
				pc_jump = 1'b1; 
			end
			
			BZ:
			begin
				pc_jump = (zero_flag_alu == 1) ? 1'b1 : 1'b0;
			end
			
			LD:
			begin
				reg_write = 1'b1;  
				mem_read = 1'b1; 
			end
			
			ST:
			begin 
				mem_write = 1'b1;
			end
			
			HALT:
			begin
				halt = 1'b1;
			end
			
			default:
			begin
				alu_control = 3'b0;
				reg_write = 1'b0; 
				alu_src = 1'b0; 
				mem_read = 1'b0; 
				mem_write = 1'b0;
				pc_jump = 1'b0; 
				halt = 1'b0;
			end
		
		endcase
		
	 end

endmodule