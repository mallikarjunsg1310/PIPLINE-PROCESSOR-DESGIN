module pipeline_processor(
    input clk,
    input reset,
    output[15:0] result1,
    output[15:0] result4,
    output[15:0] result5
);
    // Internal Registers for Pipeline Stages
    reg [15:0] IF_ID_instr;
    reg [15:0] ID_EX_A, ID_EX_B, ID_EX_imm;
    reg [2:0]  ID_EX_rd, ID_EX_opcode;
    reg [15:0] EX_WB_res;
    reg [2:0]  EX_WB_rd;

    // Simplified Memories & Register File
    reg [15:0] instr_mem [0:15]; // Instruction Memory
    reg [15:0] data_mem  [0:15]; // Data Memory for LOAD
    reg [15:0] reg_file  [0:7];  // 8 General Purpose Registers
    assign result1 = reg_file[1];
    assign result4 = reg_file[4];
    assign result5 = reg_file[5];
    reg [3:0]  pc;
integer i;
initial begin
 for(i = 0;i < 8;i = i + 1)
   reg_file[i] = 0;
 for(i = 0;i < 16;i = i + 1)
     data_mem[i] = 0;
end 

    // --- STAGE 1: INSTRUCTION FETCH (IF) ---
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            IF_ID_instr <= 0;
        end else begin
            IF_ID_instr <= instr_mem[pc];
            pc <= pc + 1;
        end
    end

    // --- STAGE 2: INSTRUCTION DECODE (ID) ---
    always @(posedge clk) begin
        ID_EX_opcode <= IF_ID_instr[15:13]; // Opcode
        ID_EX_rd     <= IF_ID_instr[12:10]; // Destination Reg
        ID_EX_A      <= reg_file[IF_ID_instr[9:7]]; // Source Reg 1
        ID_EX_B      <= reg_file[IF_ID_instr[6:4]]; // Source Reg 2
        ID_EX_imm    <= IF_ID_instr[6:0];   // Immediate for LOAD
    end

    // --- STAGE 3: EXECUTE (EX) ---
    always @(posedge clk) begin
        EX_WB_rd <= ID_EX_rd;
        case(ID_EX_opcode)
            3'b000: EX_WB_res <= ID_EX_A + ID_EX_B;       // ADD
            3'b001: EX_WB_res <= ID_EX_A - ID_EX_B;       // SUB
            3'b010: EX_WB_res <= data_mem[ID_EX_imm];     // LOAD
            default: EX_WB_res <= 0;
        endcase
    end

    // --- STAGE 4: WRITE BACK (WB) ---
    always @(posedge clk) begin
        if (!reset)
            reg_file[EX_WB_rd] <= EX_WB_res;
    end
endmodule
