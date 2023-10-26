// Company           :   tud                      
// Author            :   koke22            
// E-Mail            :   <email>                    
//                    			
// Filename          :   decoder_rv.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Jun  6 10:08:42 2023 
// Last Change       :   $Date: 2023-06-07 19:40:46 +0200 (Wed, 07 Jun 2023) $
// by                :   $Author: koke22 $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module decoder_rv( 
input  wire [31:0] inst2decode, 
input  wire [31:0] rs1_data,
input  wire [31:0] rs2_data,
input  wire [31:0] pc_next,
output wire [ 4:0] rs1_addr,
output wire [ 4:0] rs2_addr,
output wire [ 4:0] rd_addr, 
output wire [31:0] op_a,  
output wire [31:0] op_b, 
output wire [ 4:0] sub_opcode, 
output wire [ 4:0] sel_func_unit, //alu/mem/jump/mul/csr
output wire        trap, 
output wire [ 1:0] inst_size,
output wire [31:0] d_imm_pc_to_top,
output wire        cfi,
output wire        d_ld_dec,
output wire        d_st_dec,
output wire        d_csr_en,
output wire [ 2:0] d_csr_instr,
output wire [11:0] d_csr_addr,
output wire        d_csr_write_mode,
output wire [ 4:0] d_csr_code_imm,
output wire [31:0] d_csr_code_reg,
output wire [ 1:0] d_sys_instr,
output wire        d_dec_ecall,
output wire        d_dec_mret,
output wire        d_dec_wfi,
output wire        d_jump,
output wire [ 1:0] uop_lsu_to_mem,
output wire [ 3:0] d_jump_instr_type,
output wire         illegal_instr,
output wire [31:0] instr_out
);

//params
localparam SFU_ALU     = 0;
localparam SFU_MUL     = 1;
localparam SFU_LSI     = 2;
localparam SFU_CFI     = 3;
localparam SFU_CSR     = 4;

localparam ALU_ADD      = {2'b00, 3'b001};
localparam ALU_SUB      = {2'b00, 3'b000};
localparam ALU_AND      = {2'b01, 3'b001};
localparam ALU_OR       = {2'b01, 3'b010};
localparam ALU_XOR      = {2'b01, 3'b100};
localparam ALU_SLT      = {2'b10, 3'b001};
localparam ALU_SLTU     = {2'b10, 3'b010};
localparam ALU_SRA      = {2'b11, 3'b001};
localparam ALU_SRL      = {2'b11, 3'b010};
localparam ALU_SLL      = {2'b11, 3'b100};

localparam CFI_BEQ      = {2'b00, 3'b001};
localparam CFI_BGE      = {2'b00, 3'b010};
localparam CFI_BGEU     = {2'b00, 3'b011};
localparam CFI_BLT      = {2'b00, 3'b100};
localparam CFI_BLTU     = {2'b00, 3'b101};
localparam CFI_BNE      = {2'b00, 3'b110};
localparam CFI_EBREAK   = {2'b01, 3'b001};
localparam CFI_ECALL    = {2'b01, 3'b010};
localparam CFI_MRET     = {2'b01, 3'b100};
localparam CFI_JALI     = {2'b10, 3'b010};
localparam CFI_JALR     = {2'b10, 3'b100};

localparam LSI_SIGNED   = 0;
localparam LSI_LOAD     = 3;
localparam LSI_STORE    = 4;
localparam LSI_BYTE     = 2'b01;
localparam LSI_HALF     = 2'b10;
localparam LSI_WORD     = 2'b11;

localparam MUL_DIV      = {2'b11, 3'b000};
localparam MUL_DIVU     = {2'b11, 3'b110}; //changed from 11001 to 01110
localparam MUL_MUL      = {2'b01, 3'b000};
localparam MUL_MULH     = {2'b01, 3'b110}; //mul upper half changed from 01100 to 01110
localparam MUL_MULHSU   = {2'b01, 3'b111}; //mul half sign/uns
localparam MUL_MULHU    = {2'b01, 3'b101}; //mul upper half unsigned
localparam MUL_REM      = {2'b10, 3'b000}; //remainder
localparam MUL_REMU     = {2'b10, 3'b111}; //remainder unsigned

localparam CSR_READ     = 4;
localparam CSR_WRITE    = 3;
localparam CSR_SET      = 2;
localparam CSR_CLEAR    = 1;
localparam CSR_SWAP     = 0;


//operand register sources

localparam OPR_A_RS1 = 0;  // Operand A sources RS1
localparam OPR_A_PC  = 1;  // Operand A sources PC
localparam OPR_A_CSRI= 2;  // Operand A sources CSR mask immediate

localparam OPR_B_RS2 = 3;  // Operand B sources RS2
localparam OPR_B_IMM = 4;  // Operand B sources immediate

localparam OPR_C_RS2 = 5;  // Operand C sources RS2
localparam OPR_C_CSRA= 6;  // Operand C sources CSR address immediate
localparam OPR_C_PCIM= 7;  // Operand C sources PC+immediate


//decoder wires

wire [ 4:0] d_rd_addr; 
wire [31:0] d_op_a; 
wire [31:0] d_op_b;
wire [31:0] d_imm; 
wire [ 4:0] d_sub_opcode; 
wire [ 4:0] d_sel_func_unit;
wire [ 1:0] d_inst_size; 
wire [ 7:0] d_opr_src; 


wire [31:0] instr_32;    
compression_decoder c_dec(
.instr_16(inst2decode[15:0]),
.instr_32(instr_32));
    

wire instr_is_compressed;
assign instr_is_compressed = (inst2decode[1:0] != 2'b11);
wire instr_is_normal = (inst2decode[1:0] == 2'b11);
wire [31:0] instruction_to_decode;
assign instruction_to_decode = {32{instr_is_compressed}} &  instr_32 |
                                {32{instr_is_normal}} & inst2decode;

assign instr_out = instruction_to_decode;

//individual instruction decoding
wire dec_lui        =instruction_to_decode[6:2] == 5'h0D &&instruction_to_decode[1:0] == 2'd3;
wire dec_auipc      =instruction_to_decode[6:2] == 5'h05 &&instruction_to_decode[1:0] == 2'd3;
wire dec_jal        =instruction_to_decode[6:2] == 5'h1b &&instruction_to_decode[1:0] == 2'd3;
wire dec_jalr       =instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h19 &&instruction_to_decode[1:0] == 2'd3;
wire dec_beq        =instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h18 &&instruction_to_decode[1:0] == 2'd3;
wire dec_bne        =instruction_to_decode[14:12] == 3'd1 &&instruction_to_decode[6:2] == 5'h18 &&instruction_to_decode[1:0] == 2'd3;
wire dec_blt        =instruction_to_decode[14:12] == 3'd4 &&instruction_to_decode[6:2] == 5'h18 &&instruction_to_decode[1:0] == 2'd3;
wire dec_bge        =instruction_to_decode[14:12] == 3'd5 &&instruction_to_decode[6:2] == 5'h18 &&instruction_to_decode[1:0] == 2'd3;
wire dec_bltu       =instruction_to_decode[14:12] == 3'd6 &&instruction_to_decode[6:2] == 5'h18 &&instruction_to_decode[1:0] == 2'd3;
wire dec_bgeu       =instruction_to_decode[14:12] == 3'd7 &&instruction_to_decode[6:2] == 5'h18 &&instruction_to_decode[1:0] == 2'd3;
wire dec_lb         =instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h00 &&instruction_to_decode[1:0] == 2'd3;
wire dec_lh         =instruction_to_decode[14:12] == 3'd1 &&instruction_to_decode[6:2] == 5'h00 &&instruction_to_decode[1:0] == 2'd3;
wire dec_lw         =instruction_to_decode[14:12] == 3'd2 &&instruction_to_decode[6:2] == 5'h00 &&instruction_to_decode[1:0] == 2'd3;
wire dec_lbu        =instruction_to_decode[14:12] == 3'd4 &&instruction_to_decode[6:2] == 5'h00 &&instruction_to_decode[1:0] == 2'd3;
wire dec_lhu        =instruction_to_decode[14:12] == 3'd5 &&instruction_to_decode[6:2] == 5'h00 &&instruction_to_decode[1:0] == 2'd3;
wire dec_sb         =instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h08 &&instruction_to_decode[1:0] == 2'd3;
wire dec_sh         =instruction_to_decode[14:12] == 3'd1 &&instruction_to_decode[6:2] == 5'h08 &&instruction_to_decode[1:0] == 2'd3;
wire dec_sw         =instruction_to_decode[14:12] == 3'd2 &&instruction_to_decode[6:2] == 5'h08 &&instruction_to_decode[1:0] == 2'd3;
wire dec_addi       =instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h04 &&instruction_to_decode[1:0] == 2'd3;
wire dec_slti       =instruction_to_decode[14:12] == 3'd2 &&instruction_to_decode[6:2] == 5'h04 &&instruction_to_decode[1:0] == 2'd3;
wire dec_sltiu      =instruction_to_decode[14:12] == 3'd3 &&instruction_to_decode[6:2] == 5'h04 &&instruction_to_decode[1:0] == 2'd3;
wire dec_xori       =instruction_to_decode[14:12] == 3'd4 &&instruction_to_decode[6:2] == 5'h04 &&instruction_to_decode[1:0] == 2'd3;
wire dec_ori        =instruction_to_decode[14:12] == 3'd6 &&instruction_to_decode[6:2] == 5'h04 &&instruction_to_decode[1:0] == 2'd3;
wire dec_andi       =instruction_to_decode[14:12] == 3'd7 &&instruction_to_decode[6:2] == 5'h04 &&instruction_to_decode[1:0] == 2'd3;
wire dec_slli       =instruction_to_decode[31:27] == 5'd0 &&instruction_to_decode[14:12] == 3'd1 &&instruction_to_decode[6:2] == 5'h04 &&instruction_to_decode[1:0] == 2'd3;
wire dec_srli       =instruction_to_decode[31:27] == 5'd0 &&instruction_to_decode[14:12] == 3'd5 &&instruction_to_decode[6:2] == 5'h04 &&instruction_to_decode[1:0] == 2'd3;
wire dec_srai       =instruction_to_decode[31:27] == 5'd8 &&instruction_to_decode[14:12] == 3'd5 &&instruction_to_decode[6:2] == 5'h04 &&instruction_to_decode[1:0] == 2'd3;
wire dec_add        =instruction_to_decode[31:25] == 7'd0 &&instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_sub        =instruction_to_decode[31:25] == 7'd32 &&instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_sll        =instruction_to_decode[31:25] == 7'd0 &&instruction_to_decode[14:12] == 3'd1 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_slt        =instruction_to_decode[31:25] == 7'd0 &&instruction_to_decode[14:12] == 3'd2 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_sltu       =instruction_to_decode[31:25] == 7'd0 &&instruction_to_decode[14:12] == 3'd3 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_xor        =instruction_to_decode[31:25] == 7'd0 &&instruction_to_decode[14:12] == 3'd4 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_srl        =instruction_to_decode[31:25] == 7'd0 &&instruction_to_decode[14:12] == 3'd5 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_sra        =instruction_to_decode[31:25] == 7'd32 &&instruction_to_decode[14:12] == 3'd5 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_or         =instruction_to_decode[31:25] == 7'd0 &&instruction_to_decode[14:12] == 3'd6 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_and        =instruction_to_decode[31:25] == 7'd0 &&instruction_to_decode[14:12] == 3'd7 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_fence      =instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h03 &&instruction_to_decode[1:0] == 2'd3;
wire dec_fence_i    =instruction_to_decode[14:12] == 3'd1 &&instruction_to_decode[6:2] == 5'h03 &&instruction_to_decode[1:0] == 2'd3;
wire dec_mul        =instruction_to_decode[31:25] == 7'd1 &&instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_mulh       =instruction_to_decode[31:25] == 7'd1 &&instruction_to_decode[14:12] == 3'd1 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_mulhsu     =instruction_to_decode[31:25] == 7'd1 &&instruction_to_decode[14:12] == 3'd2 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_mulhu      =instruction_to_decode[31:25] == 7'd1 &&instruction_to_decode[14:12] == 3'd3 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_div        =instruction_to_decode[31:25] == 7'd1 &&instruction_to_decode[14:12] == 3'd4 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_divu       =instruction_to_decode[31:25] == 7'd1 &&instruction_to_decode[14:12] == 3'd5 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_rem        =instruction_to_decode[31:25] == 7'd1 &&instruction_to_decode[14:12] == 3'd6 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_remu       =instruction_to_decode[31:25] == 7'd1 &&instruction_to_decode[14:12] == 3'd7 &&instruction_to_decode[6:2] == 5'h0C &&instruction_to_decode[1:0] == 2'd3;
wire dec_ecall      =instruction_to_decode[11:7] == 5'd0 &&instruction_to_decode[19:15] == 5'd0 &&instruction_to_decode[31:20] == 12'h000 &&instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h1C &&instruction_to_decode[1:0] == 2'd3;
wire dec_ebreak     =instruction_to_decode[11:7] == 5'd0 &&instruction_to_decode[19:15] == 5'd0 &&instruction_to_decode[31:20] == 12'h001 &&instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h1C &&instruction_to_decode[1:0] == 2'd3;
wire dec_mret       =instruction_to_decode[11:7] == 5'd0 &&instruction_to_decode[19:15] == 5'd0 &&instruction_to_decode[31:20] == 12'h302 &&instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h1C &&instruction_to_decode[1:0] == 2'd3;
wire dec_wfi        =instruction_to_decode[11:7] == 5'd0 &&instruction_to_decode[19:15] == 5'd0 &&instruction_to_decode[31:20] == 12'h105 &&instruction_to_decode[14:12] == 3'd0 &&instruction_to_decode[6:2] == 5'h1C &&instruction_to_decode[1:0] == 2'd3;
wire dec_csrrw      =instruction_to_decode[14:12] == 3'd1 &&instruction_to_decode[6:2] == 5'h1C &&instruction_to_decode[1:0] == 2'd3;
wire dec_csrrs      =instruction_to_decode[14:12] == 3'd2 &&instruction_to_decode[6:2] == 5'h1C &&instruction_to_decode[1:0] == 2'd3;
wire dec_csrrc      =instruction_to_decode[14:12] == 3'd3 &&instruction_to_decode[6:2] == 5'h1C &&instruction_to_decode[1:0] == 2'd3;
wire dec_csrrwi     =instruction_to_decode[14:12] == 3'd5 &&instruction_to_decode[6:2] == 5'h1C &&instruction_to_decode[1:0] == 2'd3;
wire dec_csrrsi     =instruction_to_decode[14:12] == 3'd6 &&instruction_to_decode[6:2] == 5'h1C &&instruction_to_decode[1:0] == 2'd3;
wire dec_csrrci     =instruction_to_decode[14:12] == 3'd7 &&instruction_to_decode[6:2] == 5'h1C &&instruction_to_decode[1:0] == 2'd3;
wire invalid_instr = !( dec_lui       ||dec_auipc     ||dec_jal
||dec_jalr      ||dec_beq       ||dec_bne       ||dec_blt       ||dec_bge
||dec_bltu      ||dec_bgeu      ||dec_lb        ||dec_lh        ||dec_lw
||dec_lbu       ||dec_lhu       ||dec_sb        ||dec_sh        ||dec_sw
||dec_addi      ||dec_slti      ||dec_sltiu     ||dec_xori      ||dec_ori
||dec_andi      ||dec_slli      ||dec_srli      ||dec_srai      ||dec_add
||dec_sub       ||dec_sll       ||dec_slt       ||dec_sltu      ||dec_xor
||dec_srl       ||dec_sra       ||dec_or        ||dec_and       ||dec_fence
||dec_fence_i   ||dec_mul       ||dec_mulh      ||dec_mulhsu    ||dec_mulhu
||dec_div       ||dec_divu      ||dec_rem       ||dec_remu      
||dec_ecall     ||dec_ebreak    ||dec_mret      ||dec_wfi
||dec_csrrw     ||dec_csrrs     ||dec_csrrc     ||dec_csrrwi    ||dec_csrrsi
||dec_csrrci );

// Functional Unit Decoding / Selection

assign d_sel_func_unit[SFU_ALU] = 
    dec_add        || dec_addi        || dec_auipc      || dec_sub        || 
    dec_and        || dec_andi        || dec_lui        || dec_or         || 
    dec_ori        || dec_xor         || dec_xori       || dec_slt        || 
    dec_slti       || dec_sltu        || dec_sltiu      || dec_sra        || 
    dec_srai       || dec_srl         || dec_srli       || dec_sll        || 
    dec_slli;

assign d_sel_func_unit[SFU_MUL] = 
    dec_div        || dec_divu       || dec_mul        || dec_mulh       ||
    dec_mulhsu     || dec_mulhu      || dec_rem        || dec_remu       ;

assign d_sel_func_unit[SFU_CFI] = 
    dec_beq        || dec_bge        || dec_bgeu       ||
    dec_blt        || dec_bltu       || dec_bne        || 
    dec_ebreak     || dec_ecall      || dec_jal        ||
    dec_jalr       || dec_mret;

assign d_sel_func_unit[SFU_LSI] = 
    dec_lb         || dec_lbu       || dec_lh          || dec_lhu        ||
    dec_lw         || dec_sb        || dec_sh          || dec_sw;

assign d_sel_func_unit[SFU_CSR] =
    dec_csrrc      || dec_csrrci     || dec_csrrs      || dec_csrrsi     ||
    dec_csrrw      || dec_csrrwi;

assign cfi = 
    dec_lb         || dec_lbu        ||  
    dec_lhu        || dec_lw         || dec_sb         || dec_sh         || 
    dec_sw         || dec_lh;
    

wire [4:0] dec_rs1_32 = instruction_to_decode[19:15];
wire [4:0] dec_rs2_32 = instruction_to_decode[24:20];
wire [4:0] dec_rd_32  = instruction_to_decode[11: 7];
wire       instr_32bit= instruction_to_decode[1:0] == 2'b11;

assign     d_inst_size[0]  = instr_is_compressed;//instr_16bit;
assign     d_inst_size[1]  = !instr_is_compressed;//instr_32bit;

// sub opcode 
wire [4:0] uop_alu = 
    {5{dec_add       }} & ALU_ADD   |
    {5{dec_addi      }} & ALU_ADD   |
    {5{dec_auipc     }} & ALU_ADD   |
    {5{dec_sub       }} & ALU_SUB   |
    {5{dec_and       }} & ALU_AND   |
    {5{dec_andi      }} & ALU_AND   |
    {5{dec_lui       }} & ALU_OR    |
    {5{dec_or        }} & ALU_OR    |
    {5{dec_ori       }} & ALU_OR    |
    {5{dec_xor       }} & ALU_XOR   |
    {5{dec_xori      }} & ALU_XOR   |
    {5{dec_slt       }} & ALU_SLT   |
    {5{dec_slti      }} & ALU_SLT   |
    {5{dec_sltu      }} & ALU_SLTU  |
    {5{dec_sltiu     }} & ALU_SLTU  |
    {5{dec_sra       }} & ALU_SRA   |
    {5{dec_srai      }} & ALU_SRA   |
    {5{dec_srl       }} & ALU_SRL   |
    {5{dec_srli      }} & ALU_SRL   |
    {5{dec_sll       }} & ALU_SLL   |
    {5{dec_slli      }} & ALU_SLL ;

wire [4:0] uop_cfu =
    {5{dec_beq       }} & CFI_BEQ   |
    {5{dec_bge       }} & CFI_BGE   |
    {5{dec_bgeu      }} & CFI_BGEU  |
    {5{dec_blt       }} & CFI_BLT   |
    {5{dec_bltu      }} & CFI_BLTU  |
    {5{dec_bne       }} & CFI_BNE   |
    {5{dec_ebreak    }} & CFI_EBREAK|
    {5{dec_ecall     }} & CFI_ECALL |
    {5{dec_jal       }} & CFI_JALI  |
    {5{dec_jalr      }} & CFI_JALR  |
    {5{dec_mret      }} & CFI_MRET  ;

wire [4:0] uop_lsu;

wire [1:0] lsu_width = 
    {2{dec_lb        }} & LSI_BYTE |
    {2{dec_lbu       }} & LSI_BYTE |
    {2{dec_lh        }} & LSI_HALF |
    {2{dec_lhu       }} & LSI_HALF |
    {2{dec_lw        }} & LSI_WORD |
    {2{dec_sb        }} & LSI_BYTE |
    {2{dec_sh        }} & LSI_HALF |
    {2{dec_sw        }} & LSI_WORD ;


assign uop_lsu[2:1]      = lsu_width;
assign uop_lsu_to_mem = lsu_width;
assign uop_lsu[LSI_LOAD] = 
    dec_lb     ||
    dec_lbu    ||
    dec_lh     ||
    dec_lhu    ||
    dec_lw;

assign uop_lsu[LSI_STORE] = 
    dec_sb     ||
    dec_sh     ||
    dec_sw ;

assign uop_lsu[LSI_SIGNED] = 
    dec_lb     ||
    dec_lh     ; 

wire [4:0] uop_mul = 
    {5{dec_div   }} & MUL_DIV    |
    {5{dec_divu  }} & MUL_DIVU   |
    {5{dec_mul   }} & MUL_MUL    |
    {5{dec_mulh  }} & MUL_MULH   |
    {5{dec_mulhsu}} & MUL_MULHSU |
    {5{dec_mulhu }} & MUL_MULHU  |
    {5{dec_rem   }} & MUL_REM    |
    {5{dec_remu  }} & MUL_REMU   ;

wire [4:0] uop_csr;

wire       csr_op = dec_csrrc  || dec_csrrci || dec_csrrs  || dec_csrrsi || 
					dec_csrrw  || dec_csrrwi ;

wire csr_no_write = ((dec_csrrs  || dec_csrrc ) && dec_rs1_32 == 0) ||
                    ((dec_csrrsi || dec_csrrci) && dec_rs1_32 == 0) ;

wire csr_no_read  = (dec_csrrw || dec_csrrwi) && dec_rd_32 == 0;

assign uop_csr[CSR_READ ] = csr_op && !csr_no_read ;
assign uop_csr[CSR_WRITE] = csr_op && !csr_no_write;
assign uop_csr[CSR_SET  ] = dec_csrrs || dec_csrrsi ;
assign uop_csr[CSR_CLEAR] = dec_csrrc || dec_csrrci ;
assign uop_csr[CSR_SWAP ] = dec_csrrw || dec_csrrwi ;

assign rs1_addr = dec_rs1_32;
assign rs2_addr = dec_rs2_32;

wire lsu_no_rd = uop_lsu[LSI_STORE] && d_sel_func_unit[SFU_LSI];
wire cfu_no_rd = (uop_cfu!=CFI_JALI && uop_cfu!=CFI_JALR) &&
                d_sel_func_unit[SFU_CFI];

// Destination register address 
assign d_rd_addr    = 
                 lsu_no_rd || cfu_no_rd ? 0  :
                 {5{instr_32bit && |d_sel_func_unit}} & dec_rd_32 ;

// Immediate Decoding

wire [31:0] imm32_i = {{20{instruction_to_decode[31]}}, instruction_to_decode[31:20]};

wire [11:0] imm_csr_a = instruction_to_decode[31:20];

wire [31:0] imm32_s = {{20{instruction_to_decode[31]}}, instruction_to_decode[31:25], instruction_to_decode[11:7]};

wire [31:0] imm32_b = {{19{instruction_to_decode[31]}},instruction_to_decode[31],instruction_to_decode[7],instruction_to_decode[30:25],instruction_to_decode[11:8],1'b0};

wire [31:0] imm32_u = {instruction_to_decode[31:12], 12'b0};

wire [31:0] imm32_j = {{11{instruction_to_decode[31]}},instruction_to_decode[31],instruction_to_decode[19:12],instruction_to_decode[20],instruction_to_decode[30:21],1'b0};

wire [31:0] imm_addi16sp = {{23{instruction_to_decode[12]}},instruction_to_decode[4:3],instruction_to_decode[5],instruction_to_decode[2],instruction_to_decode[6],4'b0};

wire [31:0] imm_addi4spn = {22'b0, instruction_to_decode[10:7],instruction_to_decode[12:11],instruction_to_decode[5],instruction_to_decode[6],2'b00};

wire use_imm32_i = dec_andi || dec_slti   || dec_jalr   || dec_lb     ||
                   dec_lbu  || dec_lh     || dec_lhu    || dec_lw     ||
                   dec_ori  || dec_sltiu  || dec_xori   || dec_addi   ; 
wire use_imm32_j = dec_jal  ;
wire use_imm32_s = dec_sb   || dec_sh     || dec_sw     ;
wire use_imm32_u = dec_auipc|| dec_lui    ;
wire use_imm32_b = dec_beq  || dec_bge    || dec_bgeu   || dec_blt    ||
                   dec_bltu || dec_bne  ;
wire use_imm_csr = dec_csrrc || dec_csrrs || dec_csrrw;
wire use_imm_csri= dec_csrrci || dec_csrrsi || dec_csrrwi;
wire use_imm_shfi= dec_slli || dec_srli || dec_srai;

wire use_pc_imm  = use_imm32_b  || use_imm32_j ;

// Immediate which will be added to the program counter
wire [31:0] d_imm_pc = 
    {32{use_imm32_b   }} & imm32_b      |
    {32{use_imm32_j   }} & imm32_j      |
    {32{use_imm32_u   }} & imm32_u ;

assign d_imm = 
                           d_imm_pc     |
    {32{use_imm32_i   }} & imm32_i      |
    {32{use_imm32_s   }} & imm32_s      |
    {32{use_imm_csri  }} & {imm_csr_a, 15'b0, instruction_to_decode[19:15]} |
    {32{use_imm_csr   }} & {imm_csr_a, 20'b0} |
    {32{dec_fence_i   }} & 32'd4        |
    {32{use_imm_shfi  }} & {27'b0, instruction_to_decode[24:20]} ;

// Operand Sourcing.

assign d_opr_src[OPR_A_RS1 ] = // RS1
    dec_add        || dec_addi       || dec_sub           || dec_and        || 
    dec_andi       || dec_or         || dec_ori           || dec_xor        || 
    dec_xori       || dec_slt        || dec_slti          || dec_sltu       || 
    dec_sltiu      || dec_sra        || dec_srai          || dec_srl        ||
    dec_srli       || dec_sll        || dec_slli          || dec_beq        || 
    dec_bge        || dec_bgeu       || dec_blt           || dec_bltu       || 
    dec_bne        || dec_jalr       || dec_lb            || dec_lbu        || 
    dec_lh         || dec_lhu        || dec_lw            || dec_sb         || 
    dec_sh         || dec_sw         || dec_csrrc         || dec_csrrs      || 
    dec_csrrw      || dec_div        || dec_divu          || dec_mul        || 
    dec_mulh       || dec_mulhsu     || dec_mulhu         || dec_rem        || 
    dec_remu ;

assign d_opr_src[OPR_A_PC  ] = //PC+immediate
    dec_auipc       ;

assign d_opr_src[OPR_A_CSRI] = //CSR mask immediate
    dec_csrrci     || dec_csrrsi     || dec_csrrwi     ;


assign d_opr_src[OPR_B_RS2 ] = //RS2
    dec_add        || dec_sub        || dec_and           || dec_or         || 
    dec_xor        || dec_slt        || dec_sltu          || dec_sra        || 
    dec_srl        || dec_sll        || dec_beq           || dec_bge        ||
    dec_bgeu       || dec_blt        || dec_bltu          || dec_bne        || 
    dec_div        || dec_divu       || dec_mul           || dec_mulh       || 
    dec_mulhsu     || dec_mulhu      || dec_rem           || dec_remu ;

assign d_opr_src[OPR_B_IMM ] = //immediate
    dec_addi       || dec_andi       || dec_lui           || dec_ori        ||
    dec_xori       || dec_slti       || dec_sltiu         || dec_srai       || 
    dec_srli       || dec_slli       || dec_auipc         || dec_jalr       || 
    dec_lb         || dec_lbu        || dec_lh            || dec_lhu        || 
    dec_lw         || dec_sb         || dec_sh            || dec_sw ;


assign d_opr_src[OPR_C_RS2 ] = //RS2
   dec_sb          || dec_sh         || dec_sw;

assign d_opr_src[OPR_C_CSRA] = //CSR address immediate
    dec_csrrc      || dec_csrrci     || dec_csrrs      || dec_csrrsi     ||
    dec_csrrw      || dec_csrrwi      ;

assign d_opr_src[OPR_C_PCIM] = //PC+immediate
    dec_beq        || dec_bge        || dec_bgeu       || dec_blt        || 
    dec_bltu       || dec_bne        || dec_jal ;

wire [31:0] csr_addr = {20'b0, d_imm[31:20]};
wire [31:0] csr_imm  = {27'b0, rs1_addr    };

// Operand A sourcing
wire opra_src_rs1  = d_opr_src[OPR_A_RS1 ];
wire opra_src_pc   = d_opr_src[OPR_A_PC  ];
wire opra_src_csri = d_opr_src[OPR_A_CSRI];

assign d_op_a = 
    {32{opra_src_rs1    }} & rs1_data   |
    {32{opra_src_pc     }} & pc_next    | 
    {32{opra_src_csri   }} & csr_imm ;

// Operand B sourcing
wire oprb_src_rs2  = d_opr_src[OPR_B_RS2 ];
wire oprb_src_imm  = d_opr_src[OPR_B_IMM ];

assign d_op_b =
    {32{oprb_src_rs2    }} & rs2_data   |
    {32{oprb_src_imm    }} & d_imm       ;

assign d_sub_opcode = uop_alu | uop_mul; 

assign {rd_addr, op_a, op_b, sub_opcode, sel_func_unit, trap} = 
    {d_rd_addr, d_op_a, d_op_b, d_sub_opcode, d_sel_func_unit, 1'b0};
assign inst_size = (pc_next==32'h00000008)? 2'h2 : d_inst_size;
assign d_imm_pc_to_top = d_imm_pc;

//Control signals for CSR unit
assign d_csr_en = (dec_csrrc || dec_csrrci || dec_csrrs || dec_csrrsi ||
                  dec_csrrw  || dec_csrrwi || dec_ecall || dec_ebreak ||
                  dec_mret   || dec_wfi) ? 1'b1 : 1'b0;

assign d_jump =   dec_beq    || dec_bge    || dec_bgeu  ||
    			  dec_blt    || dec_bltu   || dec_bne   || 
    			  dec_ebreak || dec_ecall  || dec_jal   ||
    			  dec_jalr   || dec_mret       ;

assign d_csr_instr = instruction_to_decode[14:12];
assign d_csr_addr = dec_mret ? 12'h341: imm_csr_a;
assign d_csr_write_mode = (dec_csrrci || dec_csrrwi || dec_csrrsi) ? 1'b1 : 1'b0;
assign d_csr_code_imm = rs1_addr;
assign d_csr_code_reg = rs1_data;
assign d_sys_instr = (d_dec_mret) ? 2'b11 : 2'b00;

assign d_ld_dec = ( dec_lb || dec_lh || dec_lw || dec_lbu || dec_lhu ) ? 1'b1 : 1'b0;
assign d_st_dec = ( dec_sb || dec_sh || dec_sw ) ? 1'b1 : 1'b0;

assign d_dec_ecall = dec_ecall || dec_ebreak;
assign d_dec_mret = dec_mret;
assign d_dec_wfi = dec_wfi;

assign d_jump_instr_type =  (dec_beq)  ? 4'b0000
                          : (dec_bne)  ? 4'b0001
                          : (dec_blt)  ? 4'b0010
                          : (dec_bge)  ? 4'b0011
                          : (dec_bltu) ? 4'b0100
                          : (dec_bgeu) ? 4'b0101
                          : (dec_jalr) ? 4'b0110
                          : (dec_jal)  ? 4'b0111
                          : 4'b1111;
                          
assign illegal_instr = invalid_instr;

endmodule
