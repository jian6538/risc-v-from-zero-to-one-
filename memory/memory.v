// Data Memory Module for a 32-bit RISC-V Processor

module DataMemory (
    input  wire        clk,
    
    // Control Signals from the main Control Unit
    input  wire        memRead,       // Enables reading (conceptually)
    input  wire        memWrite,      // Enables writing
    
    // Address and Data
    input  wire [31:0] address,       // The address from the ALU result
    input  wire [31:0] writeData,     // Data to be written (from Register File)
    
    // Output
    output wire [31:0] readData       // Data that was read from memory
);

    // Main storage: 1024 slots, each 32 bits wide.
    reg [31:0] memory [0:1023];

    // --- Synchronous Write Logic ---
    // Writing to memory only happens on the rising edge of the clock
    // to ensure stability.
    always @(posedge clk) begin
        // If the memWrite signal is high, perform the write.
        if (memWrite) begin
            // We use address[11:2] to convert the byte address from the ALU
            // into a word index for our memory array (divide by 4).
            memory[address[11:2]] <= writeData;
        end
    end

    // --- Asynchronous Read Logic ---
    // Reading is combinational. The output always reflects the memory
    // content at the current address. The Control Unit will decide
    // whether to actually *use* this data or ignore it.
    assign readData = memory[address[11:2]];

endmodule
