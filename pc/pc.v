// A Program Counter module for a single-cycle RISC-V processor
// that can be updated with a specific next address for branches and jumps.

module ProgramCounter (
  input  wire        clk,
  input  wire        rst,     // Reset signal to initialize PC to 0
  input  wire [31:0] pc_in,   // The next value for the PC (from branch logic or PC+4)
  output wire [31:0] pc_out   // The current value of the PC
);

  // Internal register to hold the PC value.
  reg [31:0] pc_reg;

  // On the rising edge of the clock, update the PC.
  // If reset is active, the PC is set to 0. Otherwise, it takes the
  // value from the pc_in input.
  always @(posedge clk) begin
    if (rst) begin
      pc_reg <= 32'h00000000;
    end else begin
      pc_reg <= pc_in;
    end
  end

  // Assign the internal register value to the output.
  assign pc_out = pc_reg;

endmodule
