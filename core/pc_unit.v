`timescale 1ns/10ps

module pc_unit (
  input  wire        clk, 
  input  wire        resetn,
  input  wire        ld_dec,
  input  wire        st_dec,
  input  wire        done_pram_load,
  input  wire        mstatus_mie,
  input  wire        halt_ack,
  input  wire        csr_en,
  input  wire [31:0] csr_out,
  input  wire [ 1:0] interrupt_enable,
  input  wire [31:0] imm_pc,
  input  wire [31:0] ls_addr_to_mem,
  input  wire [ 1:0] inst_size,
  input  wire [31:0] rs1_data_top,
  input  wire [31:0] rs2_data_top,
  input  wire        dec_ecall,
  input  wire        dec_mret,
  input  wire        dec_wfi,
  input  wire        jump,
  input  wire [ 3:0] jump_instr_type,
  input  wire       pram_read_status,
  input wire        instr_fetch_en,
  input wire        illegal_instr,
  output wire [31:0] pc_next,
  output wire pc_cannot_increment,
  output reg [1:0] interrupt_ack,
  output reg [31:0] pc_next_to_csr
);

  localparam      BEQ    = 4'b0000;
  localparam      BNE    = 4'b0001;
  localparam      BLT    = 4'b0010;
  localparam      BGE    = 4'b0011;
  localparam      BLTU   = 4'b0100;
  localparam      BGEU   = 4'b0101;
  localparam      JALR   = 4'b0110;
  localparam      JAL    = 4'b0111;


  // PC computation
  // Initial value of Program Counter on Startup
  parameter PC_RESET_VALUE = 32'h0008;

  wire [31:0] pc_imm;
  wire [31:0] pc_offset;
  wire [31:0] jalr_imm;
  reg  [31:0] program_counter;
  wire [31:0] d_pc_offset = {29'b0, inst_size, 1'b0}; 
  reg         pram_load;
  always @(posedge clk) begin
  if(!resetn) begin
    pram_load <= 1;
  end
  else begin
  pram_load <= done_pram_load;
  end
 end
 
  assign jalr_imm  = rs1_data_top + imm_pc;
  assign pc_imm    = imm_pc + pc_next;
  assign pc_offset = d_pc_offset + pc_next;
  
  
  wire ldst_cond = (ld_dec || st_dec);
  wire instr_is_ext;
  assign instr_is_ext = (ls_addr_to_mem[14] || ls_addr_to_mem[15] || ls_addr_to_mem[16]) && ldst_cond;
  wire instr_is_jump;
  assign instr_is_jump = jump && !csr_en;
 
  wire instr_is_pram = !(ls_addr_to_mem[14] || ls_addr_to_mem[15] || ls_addr_to_mem[16]);
  wire instr_is_pram_read;
  assign instr_is_pram_read = (instr_is_pram && ld_dec);
  wire pc_is_ext =  (pc_next[14] || pc_next[15] || pc_next[16]);
  
  wire inc_cond1 = !instr_fetch_en && (!pram_read_status);
  wire inc_cond2 = instr_fetch_en && (pram_read_status);
  wire inc_cond3 = !pram_read_status && !pc_is_ext;
  
  wire pc_ci_temp = (pram_load) ||(instr_fetch_en && (!halt_ack && !pram_read_status) );
  //wire pc_cannot_increment;
  assign pc_cannot_increment = pc_ci_temp || (instr_is_ext && !halt_ack) || (instr_is_pram_read && inc_cond1 ) ||  (instr_is_pram_read && inc_cond2) || (instr_is_pram && inc_cond3); // or instead of and
  
  wire beq_yes = (jump_instr_type==BEQ);
  wire bne_yes = (jump_instr_type==BNE);
  wire blt_yes = (jump_instr_type==BLT);
  wire bge_yes = (jump_instr_type==BGE);
  wire bltu_yes =(jump_instr_type==BLTU);
  wire bgeu_yes =(jump_instr_type==BGEU);
  
  
  wire cond_beq = (rs1_data_top == rs2_data_top)&&beq_yes;
  wire cond_bne = (rs1_data_top != rs2_data_top)&&bne_yes;
  wire cond_blt = (rs1_data_top < rs2_data_top)&&blt_yes;
  wire cond_bge = (rs1_data_top >= rs2_data_top)&&bge_yes;
  wire cond_bltu = ($unsigned(rs1_data_top) < $unsigned(rs2_data_top))&&bltu_yes;
  wire cond_bgeu = ($unsigned(rs1_data_top) >= $unsigned(rs2_data_top))&&bgeu_yes;
  
  wire cond_b1 = cond_beq | cond_bne ;
  wire cond_b2 =  cond_blt |  cond_bge ;
  wire cond_b3 = cond_b1 | cond_b2;
  wire cond_b4 = cond_bltu |  cond_bgeu;
  wire cond_b = cond_b3 | cond_b4;
  
  reg [31:0] pc_value_next;
  
  always @ * begin
    pc_value_next = pc_offset;
    if (dec_ecall) begin
        pc_value_next = 32'h10;
    end else if (dec_mret) begin
        pc_value_next = csr_out;
    end else if (illegal_instr && (pram_read_status || halt_ack)) begin
        pc_value_next = 32'hc;
    end else if (instr_is_jump) begin
        case (jump_instr_type)
          //BEQ:  pc_value_next = cond_beq? pc_imm : pc_offset;
          //BNE:  pc_value_next = cond_bne? pc_imm : pc_offset;
          //BLT:  pc_value_next = cond_blt? pc_imm : pc_offset;  
          //BGE:  pc_value_next = cond_bge? pc_imm : pc_offset;    
          //BLTU: pc_value_next = cond_bltu? pc_imm : pc_offset;  
          //BGEU: pc_value_next = cond_bgeu? pc_imm : pc_offset;    
          JALR: pc_value_next = {jalr_imm[31:1],1'b0};       
          JAL:  pc_value_next = pc_imm;
          default: pc_value_next = cond_b? pc_imm : pc_offset;
        endcase
    
    end else begin
        pc_value_next = pc_offset;
    end
    
  end
  /*
always @ * begin
    pc_next_to_csr = pc_value_next;
  end
  */
always@(posedge clk) begin
    if (!resetn) begin
     //   pc_next_to_csr <= PC_RESET_VALUE;
    //end else if (pc_cannot_increment) begin
    //    pc_next_to_csr <= pc_next_to_csr;
    end else begin
        pc_next_to_csr <= pc_value_next;
    end
  
end
 
  always@(posedge clk) begin
    if (!resetn) begin
        program_counter <= PC_RESET_VALUE;
    end else if (pc_cannot_increment) begin
        program_counter <= program_counter;
        interrupt_ack <= 0;
    end else if (interrupt_enable[0] && mstatus_mie) begin
        program_counter <= 32'h0000;
        interrupt_ack[0] <= 1;
    end else if (interrupt_enable[1] && mstatus_mie) begin
        program_counter <= 32'h0004;
        interrupt_ack[1] <= 1;
    end else if (dec_wfi) begin
        program_counter <= program_counter;
        interrupt_ack <= 0;
    end else begin
        program_counter <= pc_value_next;
        interrupt_ack <= 0;
    end
  
  end
  assign pc_next = program_counter;
  

endmodule
