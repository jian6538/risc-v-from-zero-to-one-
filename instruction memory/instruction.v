// instr_mem.v
module instr_mem(
  input      [31:0] addr,
  output reg [31:0] instruction
);
  // Declare a memory array: 256 entries, each 32 bits wide.
  // This supports up to 256 instructions.
  reg [31:0] mem[0:255];

  // Pre-load the memory from a hex file at the start of the simulation.
  initial begin
    $readmemh("program.mem", mem);
  end

  // Asynchronous read. The 'addr' is shifted right by 2 because memory is
  // byte-addressed, but our array is word-addressed (32-bit words).
  always @(*) begin
    instruction = mem[addr >> 2];
  end

endmodule
