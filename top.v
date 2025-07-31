module RiscV_SingleCycle (
    input wire clk,              // Clock
    input wire rst               // Reset (optional, useful for clearing registers)
);

    // Signals
    wire [31:0] instruction;      // Instruction from Instruction Memory
    wire [6:0] opcode;            // Instruction opcode
    wire [4:0] rd, rs1, rs2;      // Register addresses
    wire [31:0] read_data1, read_data2; // Register file output
    wire [31:0] alu_result;       // ALU result
    wire [31:0] mem_data;         // Data from Data Memory (for load)
    wire [31:0] write_data;       // Data to write to the Register File
    wire [31:0] pc_next;          // Next Program Counter value
    wire reg_write, alu_src, mem_read, mem_write, mem_to_reg, branch, zero;
    wire [1:0] alu_op;            // ALU control signals

    // Modules
    ProgramCounter pc (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_next),
        .pc_out(pc)
    );

    InstructionMemory instr_mem (
        .addr(pc),
        .instruction(instruction)
    );

    // Instruction Decoder
    InstructionDecoder decoder (
        .instruction(instruction),
        .opcode(opcode),
        .rd(rd),
        .rs1(rs1),
        .rs2(rs2)
    );

    // Control Unit
    ControlUnit control (
        .opcode(opcode),
        .reg_write(reg_write),
        .alu_src(alu_src),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .mem_to_reg(mem_to_reg),
        .branch(branch),
        .alu_op(alu_op)
    );

    // Register File
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

    // ALU
    ALU alu (
        .a(read_data1),
        .b(alu_src ? instruction[31:20] : read_data2), // ALU src can be immediate or register
        .alu_op(alu_op),
        .result(alu_result),
        .zero(zero)
    );

    // Data Memory (for load/store instructions)
    DataMemory data_mem (
        .clk(clk),
        .mem_read(mem_read),
        .mem_write(mem_write),
        .address(alu_result),
        .write_data(read_data2),
        .read_data(mem_data)
    );

    // Branch Logic for next PC value (based on branch instruction)
    assign pc_next = branch && zero ? (pc + instruction[31:20]) : (pc + 4); // For simplicity, we assume branch is always taken for BEQ

    // Mux for Write-back data selection (ALU result or Data Memory result)
    assign write_data = (mem_to_reg) ? mem_data : alu_result;

endmodule
