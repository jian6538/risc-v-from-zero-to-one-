// RiscV_SingleCycle: Top-level module for the single-cycle processor
// This version includes the ALUControl unit for correct R-type instruction decoding.

module RiscV_SingleCycle (
    input wire clk,              // Clock
    input wire rst               // Reset
);

    // --- Internal Wires and Signals ---
    wire [31:0] pc_out;           // Current PC value from the Program Counter
    wire [31:0] pc_next;          // The calculated address for the next instruction
    wire [31:0] instruction;      // Instruction from Instruction Memory
    
    // Decoded instruction fields
    wire [6:0]  opcode;
    wire [4:0]  rd, rs1, rs2;
    wire [2:0]  funct3;
    wire [6:0]  funct7;

    // Control signals from the main Control Unit
    wire        reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch;
    wire [1:0]  alu_op;           // 2-bit general op for ALU Control

    // Specific 4-bit control signal for the ALU
    wire [3:0]  alu_ctrl_signal;

    // Data path signals
    wire [31:0] read_data1, read_data2; // Data from Register File
    wire [31:0] alu_result;       // Result from the ALU
    wire        alu_zero;         // Zero flag from the ALU
    wire [31:0] mem_data;         // Data read from Data Memory
    wire [31:0] write_data;       // Data to be written back to the Register File


    // --- Module Instantiations ---

    // 1. Program Counter: Fetches the next instruction address.
    ProgramCounter pc_unit (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_next),
        .pc_out(pc_out)
    );

    // 2. Instruction Memory: Retrieves the instruction from the given address.
    InstructionMemory instr_mem (
        .addr(pc_out),
        .instruction(instruction)
    );

    // 3. Instruction Decoder: Breaks the instruction into its component fields.
    // NOTE: Now outputs funct3 and funct7 for the ALU Control.
    InstructionDecoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7)
    );

    // 4. Main Control Unit: Generates primary control signals from the opcode.
    ControlUnit control_unit (
        .opcode(opcode),
        .RegWrite(reg_write),
        .ALUSrc(alu_src),
        .MemRead(mem_read),
        .MemWrite(mem_write),
        .MemToReg(mem_to_reg),
        .Branch(branch),
        .ALUOp(alu_op)
    );

    // 5. ALU Control: Translates the main control's ALUOp and instruction's
    //    funct fields into a specific 4-bit signal for the ALU.
    ALUControl alu_control_unit (
        .ALUOp(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(alu_ctrl_signal)
    );

    // 6. Register File: Reads from and writes to the 32 general-purpose registers.
    RegisterFile reg_file (
        .clk(clk),
        .rst(rst),
        .write_enable(reg_write),
        .write_addr(rd),
        .write_data(write_data),
        .read_addr1(rs1),
        .read_data1(read_data1),
        .read_addr2(rs2),
        .read_data2(read_data2)
    );

    // 7. ALU: Performs arithmetic and logical operations.
    // NOTE: Now takes the specific 4-bit control signal.
    ALU alu_unit (
        .operand_a(read_data1),
        .operand_b(alu_src ? instruction[31:20] : read_data2), // MUX for immediate or register
        .ALUControl(alu_ctrl_signal),
        .result(alu_result),
        .z(alu_zero)
    );

    // 8. Data Memory: Handles load and store operations.
    DataMemory data_mem (
        .clk(clk),
        .memRead(mem_read),
        .memWrite(mem_write),
        .address(alu_result),
        .writeData(read_data2),
        .readData(mem_data)
    );


    // --- Combinational Logic for MUXes and PC Next Address ---

    // MUX for selecting the data to write back to the register file.
    assign write_data = (mem_to_reg) ? mem_data : alu_result;

    // Logic for calculating the next PC address.
    // If 'branch' is asserted and the ALU result is zero (for BEQ), take the branch.
    // Otherwise, just go to the next instruction (PC + 4).
    // NOTE: This branch logic is still simplified and needs the Immediate Generator.
    assign pc_next = (branch && alu_zero) ? (pc_out + instruction[31:20]) : (pc_out + 4);

endmodule
