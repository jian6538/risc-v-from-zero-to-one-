// Code your design here
// alu.v
module alu(
  input  [31:0] A,
  input  [31:0] B,
  input  [3:0]  ALUControl,
  output reg [31:0]  Result,
  output        Zero
);

  // Define what each ALUControl code means. This makes the code readable.
  localparam ALU_ADD  = 4'b0000;
  localparam ALU_SUB  = 4'b0001;
  localparam ALU_AND  = 4'b0010;
  localparam ALU_OR   = 4'b0011;
  localparam ALU_SLT  = 4'b0100; // Set on Less Than

  // This `always` block is combinational. It re-calculates whenever an input changes.
  always @(*) begin
    case (ALUControl)
      ALU_ADD:  Result = A + B;
      ALU_SUB:  Result = A - B;
      ALU_AND:  Result = A & B;
      ALU_OR:   Result = A | B;
      ALU_SLT:  Result = ($signed(A) < $signed(B)) ? 32'd1 : 32'd0;
      default: Result = 32'hdeadbeef; // Should not happen
    endcase
  end

  // The 'Zero' flag is useful for branches. It's 1 if the result is all zeros.
  assign Zero = (Result == 32'd0);

endmodule
