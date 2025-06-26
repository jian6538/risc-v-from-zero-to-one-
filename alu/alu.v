module alu(
	input [31:0] operand_a,
	input [31:0] operand_b,
	input [3:0]  opcode,         // Changed name from 'opcode' to 'alu_control' for clarity, but using yours.
	output reg [31:0] result,  // 'result' must be declared as 'reg'
	output wire z              // 'z' should be a wire
);

// Your defined operation codes
localparam op_add = 4'b0000; //add
localparam op_sub = 4'b0001; //sub
localparam op_sll = 4'b0010; //shift left 
localparam op_slt = 4'b0011; // set on less than 
// NOTE: I've added SLTU as it's part of the base ISA and good practice
localparam op_sltu = 4'b0100; // set on less than unsigned
localparam op_xor = 4'b0101; //xor 
localparam op_or = 4'b0110; //or 
localparam op_and = 4'b0111; //and 
localparam op_srl = 4'b1000; //shift right logical 
localparam op_sra = 4'b1001; //shift right arithmetic 

always @(*) begin 
	case(opcode)
		op_add : result = operand_a + operand_b;
		op_sub : result = operand_a - operand_b;
		
		// The lower 5 bits of operand_b specify the shift amount
		op_sll : result = operand_a << operand_b[4:0]; 
		
		// For signed comparison, we use the $signed() system task
		op_slt : result = ($signed(operand_a) < $signed(operand_b)) ? 32'd1 : 32'd0;
		
		// For unsigned comparison, we do a normal comparison
		op_sltu : result = (operand_a < operand_b) ? 32'd1 : 32'd0;
		
		op_xor : result = operand_a ^ operand_b;
		op_or  : result = operand_a | operand_b;
		op_and : result = operand_a & operand_b;
		
		// The lower 5 bits of operand_b specify the shift amount
		op_srl : result = operand_a >> operand_b[4:0];
		
		// For an arithmetic shift, we must preserve the sign bit
		op_sra : result = $signed(operand_a) >>> operand_b[4:0];

		// A default case is good practice to prevent accidental latches
		default : result = 32'b0; 
	endcase
end

// The zero flag 'z' is set to 1 if the result is exactly 0.
// This is a combinational assignment and sits outside the always block.
assign z = (result == 32'b0);

endmodule
