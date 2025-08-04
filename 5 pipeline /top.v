// Top-Level Module for a 5-Stage Pipelined RISC-V Processor
// This version provides the full, detailed structure without hazard/forwarding logic.

module RiscV_Pipelined (
    input wire clk,
    input wire rst
);

    // =================================================================================
    // Pipeline Control Signals (for stalling and flushing, to be added later)
    // =================================================================================
    wire pc_write_enable = 1'b1; // Will be controlled by Hazard Unit
    wire if_id_write_enable = 1'b1; // Will be controlled by Hazard Unit
    wire id_ex_clear = 1'b0; // Will be controlled by Hazard Unit for flushing


    // =================================================================================
    // STAGE 1: INSTRUCTION FETCH (IF)
    // =================================================================================
    wire [31:0] pc_if;
    wire [31:0] pc_next_if; // Input to the PC
    wire [31:0] pc_plus_4_if;
    wire [31:0] instruction_if;

    ProgramCounter pc_unit (
        .clk(clk),
        .rst(rst),
        .pc_in(pc_next_if),
        .pc_out(pc_if)
    );

    assign pc_plus_4_if = pc_if + 4;

    InstructionMemory instr_mem (
        .addr(pc_if),
        .instruction(instruction_if)
    );


    // =================================================================================
    // IF/ID Pipeline Register
    // =================================================================================
    reg [31:0] if_id_instruction;
    reg [31:0] if_id_pc_plus_4;

    always @(posedge clk) begin
        if (rst || !if_id_write_enable) begin
            if_id_instruction <= 32'b0;
            if_id_pc_plus_4   <= 32'b0;
        end else begin
            if_id_instruction <= instruction_if;
            if_id_pc_plus_4   <= pc_plus_4_if;
        end
    end


    // =================================================================================
    // STAGE 2: INSTRUCTION DECODE (ID)
    // =================================================================================
    // Unpack signals from IF/ID Register
    wire [31:0] instruction_id = if_id_instruction;
    wire [31:0] pc_plus_4_id   = if_id_pc_plus_4;

    // Decoded fields
    wire [6:0] opcode_id = instruction_id[6:0];
    wire [4:0] rd_id     = instruction_id[11:7];
    wire [2:0] funct3_id = instruction_id[14:12];
    wire [4:0] rs1_id    = instruction_id[19:15];
    wire [4:0] rs2_id    = instruction_id[24:20];
    wire [6:0] funct7_id = instruction_id[31:25];

    // Control Unit
    wire        RegWrite_id, ALUSrc_id, MemRead_id, MemWrite_id, MemToReg_id, Branch_id;
    wire [1:0]  ALUOp_id;
    ControlUnit control_unit (
        .opcode(opcode_id), .RegWrite(RegWrite_id), .ALUSrc(ALUSrc_id), .MemRead(MemRead_id),
        .MemWrite(MemWrite_id), .MemToReg(MemToReg_id), .Branch(Branch_id), .ALUOp(ALUOp_id)
    );

    // Immediate Generator
    wire [31:0] immediate_id;
    ImmediateGenerator imm_gen (.instruction(instruction_id), .immediate(immediate_id));

    // Register File (Read Ports)
    wire [31:0] read_data1_id, read_data2_id;
    // Note: Write port signals come from the WB stage
    RegisterFile reg_file (
        .clk(clk), .rst(rst),
        .read_addr1(rs1_id), .read_data1(read_data1_id),
        .read_addr2(rs2_id), .read_data2(read_data2_id),
        .write_enable(RegWrite_wb), .write_addr(rd_wb), .write_data(write_data_wb)
    );


    // =================================================================================
    // ID/EX Pipeline Register
    // =================================================================================
    reg [31:0] id_ex_pc_plus_4;
    reg [31:0] id_ex_read_data1, id_ex_read_data2;
    reg [31:0] id_ex_immediate;
    reg [4:0]  id_ex_rs1, id_ex_rs2, id_ex_rd;
    reg [2:0]  id_ex_funct3;
    reg [6:0]  id_ex_funct7;
    // Control Signals
    reg        id_ex_RegWrite, id_ex_ALUSrc, id_ex_MemRead, id_ex_MemWrite, id_ex_MemToReg, id_ex_Branch;
    reg [1:0]  id_ex_ALUOp;

    always @(posedge clk) begin
        if (rst || id_ex_clear) begin
            // Clear all signals, effectively injecting a "bubble"
            id_ex_RegWrite <= 0; id_ex_MemRead <= 0; id_ex_MemWrite <= 0;
            id_ex_MemToReg <= 0; id_ex_Branch <= 0; id_ex_ALUSrc <= 0;
            id_ex_pc_plus_4 <= 0; id_ex_read_data1 <= 0; id_ex_read_data2 <= 0;
            id_ex_immediate <= 0; id_ex_rs1 <= 0; id_ex_rs2 <= 0; id_ex_rd <= 0;
            id_ex_funct3 <= 0; id_ex_funct7 <= 0; id_ex_ALUOp <= 0;
        end else begin
            // Pass all data and control signals to the next stage
            id_ex_pc_plus_4  <= pc_plus_4_id;
            id_ex_read_data1 <= read_data1_id;
            id_ex_read_data2 <= read_data2_id;
            id_ex_immediate  <= immediate_id;
            id_ex_rs1        <= rs1_id;
            id_ex_rs2        <= rs2_id;
            id_ex_rd         <= rd_id;
            id_ex_funct3     <= funct3_id;
            id_ex_funct7     <= funct7_id;
            id_ex_RegWrite   <= RegWrite_id;
            id_ex_ALUSrc     <= ALUSrc_id;
            id_ex_MemRead    <= MemRead_id;
            id_ex_MemWrite   <= MemWrite_id;
            id_ex_MemToReg   <= MemToReg_id;
            id_ex_Branch     <= Branch_id;
            id_ex_ALUOp      <= ALUOp_id;
        end
    end


    // =================================================================================
    // STAGE 3: EXECUTE (EX)
    // =================================================================================
    // Unpack signals from ID/EX Register
    wire [31:0] pc_plus_4_ex   = id_ex_pc_plus_4;
    wire [31:0] read_data1_ex  = id_ex_read_data1;
    wire [31:0] read_data2_ex  = id_ex_read_data2;
    wire [31:0] immediate_ex   = id_ex_immediate;
    wire [4:0]  rs1_ex         = id_ex_rs1;
    wire [4:0]  rs2_ex         = id_ex_rs2;
    wire [4:0]  rd_ex          = id_ex_rd;
    wire [2:0]  funct3_ex      = id_ex_funct3;
    wire [6:0]  funct7_ex      = id_ex_funct7;
    wire        RegWrite_ex    = id_ex_RegWrite;
    wire        ALUSrc_ex      = id_ex_ALUSrc;
    wire        MemRead_ex     = id_ex_MemRead;
    wire        MemWrite_ex    = id_ex_MemWrite;
    wire        MemToReg_ex    = id_ex_MemToReg;
    wire        Branch_ex      = id_ex_Branch;
    wire [1:0]  ALUOp_ex       = id_ex_ALUOp;


    // ALU Control
    wire [3:0] alu_control_ex;
    ALUControl alu_control_unit (.ALUOp(ALUOp_ex), .funct3(funct3_ex), .funct7(funct7_ex), .ALUControl(alu_control_ex));

    // ALU Operand MUX
    wire [31:0] alu_operand_b_ex = ALUSrc_ex ? immediate_ex : read_data2_ex;

    // ALU
    wire [31:0] alu_result_ex;
    wire        zero_ex;
    ALU alu_unit (.operand_a(read_data1_ex), .operand_b(alu_operand_b_ex), .ALUControl(alu_control_ex), .result(alu_result_ex), .z(zero_ex));

    // Branch Target Calculation
    wire [31:0] branch_target_ex = id_ex_pc_plus_4 + (immediate_ex << 1); // Simplified, real PC is needed here


    // =================================================================================
    // EX/MEM Pipeline Register
    // =================================================================================
    reg [31:0] ex_mem_alu_result;
    reg [31:0] ex_mem_read_data2;
    reg [4:0]  ex_mem_rd;
    reg        ex_mem_zero;
    // Control Signals
    reg        ex_mem_RegWrite, ex_mem_MemRead, ex_mem_MemWrite, ex_mem_MemToReg, ex_mem_Branch;

    always @(posedge clk) begin
        if (rst) begin 
            ex_mem_alu_result <= 0; ex_mem_read_data2 <= 0; ex_mem_rd <= 0; ex_mem_zero <= 0;
            ex_mem_RegWrite <= 0; ex_mem_MemRead <= 0; ex_mem_MemWrite <= 0;
            ex_mem_MemToReg <= 0; ex_mem_Branch <= 0;
        end
        else begin
            ex_mem_alu_result <= alu_result_ex;
            ex_mem_read_data2 <= read_data2_ex;
            ex_mem_rd         <= rd_ex;
            ex_mem_zero       <= zero_ex;
            ex_mem_RegWrite   <= RegWrite_ex;
            ex_mem_MemRead    <= MemRead_ex;
            ex_mem_MemWrite   <= MemWrite_ex;
            ex_mem_MemToReg   <= MemToReg_ex;
            ex_mem_Branch     <= Branch_ex;
        end
    end


    // =================================================================================
    // STAGE 4: MEMORY (MEM)
    // =================================================================================
    // Unpack signals from EX/MEM Register
    wire [31:0] alu_result_mem = ex_mem_alu_result;
    wire [31:0] read_data2_mem = ex_mem_read_data2;
    wire [4:0]  rd_mem         = ex_mem_rd;
    wire        zero_mem       = ex_mem_zero;
    wire        RegWrite_mem   = ex_mem_RegWrite;
    wire        MemRead_mem    = ex_mem_MemRead;
    wire        MemWrite_mem   = ex_mem_MemWrite;
    wire        MemToReg_mem   = ex_mem_MemToReg;
    wire        Branch_mem     = ex_mem_Branch;

    // Data Memory
    wire [31:0] mem_read_data_mem;
    DataMemory data_mem (
        .clk(clk), .address(alu_result_mem), .writeData(read_data2_mem),
        .memRead(MemRead_mem), .memWrite(MemWrite_mem), .readData(mem_read_data_mem)
    );

    // Branch decision logic
    wire take_branch = Branch_mem & zero_mem;


    // =================================================================================
    // MEM/WB Pipeline Register
    // =================================================================================
    reg [31:0] mem_wb_mem_read_data;
    reg [31:0] mem_wb_alu_result;
    reg [4:0]  mem_wb_rd;
    // Control Signals
    reg        mem_wb_RegWrite, mem_wb_MemToReg;

    always @(posedge clk) begin
        if (rst) begin 
            mem_wb_mem_read_data <= 0; mem_wb_alu_result <= 0; mem_wb_rd <= 0;
            mem_wb_RegWrite <= 0; mem_wb_MemToReg <= 0;
        end
        else begin
            mem_wb_mem_read_data <= mem_read_data_mem;
            mem_wb_alu_result    <= alu_result_mem;
            mem_wb_rd            <= rd_mem;
            mem_wb_RegWrite      <= RegWrite_mem;
            mem_wb_MemToReg      <= MemToReg_mem;
        end
    end


    // =================================================================================
    // STAGE 5: WRITE BACK (WB)
    // =================================================================================
    // Unpack signals from MEM/WB Register
    wire [31:0] mem_read_data_wb = mem_wb_mem_read_data;
    wire [31:0] alu_result_wb  = mem_wb_alu_result;
    wire [4:0]  rd_wb          = mem_wb_rd;
    wire        RegWrite_wb    = mem_wb_RegWrite;
    wire        MemToReg_wb    = mem_wb_MemToReg;

    // Write Back MUX
    wire [31:0] write_data_wb = MemToReg_wb ? mem_read_data_wb : alu_result_wb;
    // The write_data_wb, rd_wb, and RegWrite_wb are wired back to the Register File


    // =================================================================================
    // PC Update Logic
    // =================================================================================
    // MUX to select the next PC value
    assign pc_next_if = take_branch ? branch_target_ex : pc_plus_4_if;

endmodule
