module cpu(
	input clk, rst,
	input [7:0] io_rdata,
	output [7:0] io_addr, io_wdata,
	output halt, io_write
);

	wire [7:0] pc, jump_address, load_data;
	wire [15:0] instruction;
	wire [3:0] opcode;
	wire [7:0] extra, read_data_a, read_data_b, alu_result, memory_data, write_back_data, alu_operand_b;
	wire [2:0] alu_control,reg_dest, reg_a, reg_b;
	wire reg_write, alu_src, mem_read, mem_write, pc_jump, zero_flag, alu_carry;
	reg  zero_flag_reg;
	
	program_counter ps1(.clk(clk), .rst(rst), .en(~halt), 
								.jump(pc_jump), .jump_address(jump_address), .pc(pc));
								
	instruction_rom rom1(.address(pc),.instruction(instruction));
	
	instruction_decoder deco1(.instruction(instruction),.opcode(opcode),
										.reg_a(reg_a), .reg_b(reg_b), .reg_dest(reg_dest),
										.extra(extra));
										
	control_unit cu1(.opcode(opcode), .zero_flag_alu(zero_flag_reg),.alu_control(alu_control),
						.reg_write(reg_write), .alu_src(alu_src), .mem_read(mem_read), 
						.mem_write(mem_write), .pc_jump(pc_jump), .halt(halt));
						
	register_file rf1(.clk(clk), .rst(rst), .write_en(reg_write),
							.read_addr_a(reg_a), .read_addr_b(reg_b), .write_addr(reg_dest),
							.write_data(write_back_data), .read_data_a(read_data_a),
							.read_data_b(read_data_b));
							
	assign alu_operand_b = (alu_src == 1'b1) ? extra : read_data_b;
							
	alu al1(.a(read_data_a), .b(alu_operand_b), .alu_control(alu_control), 
				.result(alu_result), .zero(zero_flag), .carry(alu_carry));
				
	data_memory dm1( .clk(clk), .rst(rst), .mem_read(mem_read && (extra < 8'hF0)), 
					.mem_write(mem_write && (extra < 8'hF0)), .address(extra), 
					.write_data(read_data_a), .read_data(memory_data));
	
	assign load_data = (extra >= 8'hF0) ? io_rdata : memory_data;
					
	assign jump_address = extra;

	assign write_back_data =
		 (opcode == 4'b0001) ? extra :
		 (opcode == 4'b1001) ? load_data :
									  alu_result;
									  
	always @(posedge clk) begin
		 if (rst)
			  zero_flag_reg <= 1'b0;
		 else if (opcode >= 4'b0010 && opcode <= 4'b0110)
			  zero_flag_reg <= zero_flag;
	end
	
	assign io_addr  = extra;
	assign io_wdata = read_data_a;
	assign io_write = mem_write && (extra >= 8'hF0);
	
		
endmodule