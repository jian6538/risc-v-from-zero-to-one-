// RiscV_SingleCycle: Final top-level module for the single-cycle processor
// This version includes the ALUControl and ImmediateGenerator for correct decoding.

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

    // Control signals
    wire        reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch;
    wire [1:0]  alu_op;
    wire [3:0]  alu_ctrl_signal;

    // Data path signals
    wire [31:0] read_data1, read_data2;
    wire [31:0] immediate;        // Output from the Immediate Generator
    wire [31:0] alu_input_b;      // Input 'b' to the ALU (from MUX)
    wire [31:0] alu_result;
    wire        alu_zero;
    wire [31:0] mem_data;
    wire [31:0] write_data;


    // --- Module Instantiations ---

    // 1. Program Counter
    ProgramCounter pc_unit (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_next),
        .pc_out(pc_out)
    );

    // 2. Instruction Memory
    InstructionMemory instr_mem (
        .addr(pc_out),
        .instruction(instruction)
    );

    // 3. Instruction Decoder
    InstructionDecoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2),
        .funct3(funct3),
        .funct7(funct7)
    );

    // 4. Main Control Unit
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

    // 5. ALU Control
    ALUControl alu_control_unit (
        .ALUOp(alu_op),
        .funct3(funct3),
        .funct7(funct7),
        .ALUControl(alu_ctrl_signal)
    );

    // 6. Immediate Generator
    ImmediateGenerator imm_gen (
        .instruction(instruction),
        .immediate(immediate)
    );

    // 7. Register File
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

    // MUX for ALU's second operand
    assign alu_input_b = alu_src ? immediate : read_data2;

    // 8. ALU
    ALU alu_unit (
        .operand_a(read_data1),
        .operand_b(alu_input_b),
        .ALUControl(alu_ctrl_signal),
        .result(alu_result),
        .z(alu_zero)
    );

    // 9. Data Memory
    DataMemory data_mem (
        .clk(clk),
        .memRead(mem_read),
        .memWrite(mem_write),
        .address(alu_result),
        .writeData(read_data2),
        .readData(mem_data)
    );

    // --- Combinational Logic for MUXes and PC Next Address ---

    // MUX for write-back data
    assign write_data = mem_to_reg ? mem_data : alu_result;

    // Logic for next PC address (now uses the correct immediate)
    assign pc_next = (branch && alu_zero) ? (pc_out + immediate) : (pc_out + 4);

endmodule
