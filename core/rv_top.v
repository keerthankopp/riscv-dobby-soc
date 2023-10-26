`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.07.2023 14:34:28
// Design Name: 
// Module Name: rv_top
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module riscv_top (
  input         wire        clk,
  input         wire        resetn,
  input         wire        halt_ack,
  input         wire        load_when_reset,
  input         wire [31:0] inst2decode, //from memc
  input         wire [31:0] ls_read_data_from_mem,
  input         wire [ 1:0] interrupt_enable_rvtop,
  input         wire        pram_read_status,
  output        reg        instr_fetch_enable_to_mem,
  output        reg        rd_en,
  output        reg        wr_en,
  output        reg        ls_mem_access_to_mem,
  output        reg [ 1:0] inst_size_to_mem,
  //output        reg [31:0] pc_next_to_mem,
  //CHANGED@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
  output         [31:0] pc_next_to_mem,
  output        reg [31:0] ls_addr_to_mem, 
  output        reg [31:0] ls_write_data_to_mem, 
  output         [ 1:0] interrupt_ack_rvtop
);   
wire ls_mem_access_to_mem_temp;
wire instr_fetch_enable_to_mem_temp;
wire rd_en_temp;
wire wr_en_temp;
wire [31:0] ls_write_data_to_mem_temp;
wire [31:0] ls_addr_to_mem_temp;
wire alu_lt_top;
wire alu_eq_top; 
wire wen_top;
wire [31:0] rd0_value_i_top;
wire [31:0] pc_next_to_mem_temp;
wire [ 1:0] inst_size_to_mem_temp;
wire [ 1:0] interrupt_ack_rvtop_temp;
//Internal wires to decoder
wire [31:0] rs1_data_top;
wire [31:0] rs2_data_top;

//Internal wires from decoder
wire [ 4:0] rs1_addr_top;
wire [ 4:0] rs2_addr_top;
wire [ 4:0] rd_addr_top; 
wire [ 4:0] sel_func_unit; //alu/mem/jump/mul/csr
wire        trap;
wire        cfi_top;
wire        ecall_top;
wire        mret_top;
wire        wfi_top;
wire        jump_top;
wire [ 3:0] jump_instr_type_top;
wire [ 1:0] uop_lsu_to_mem_top;
wire [ 1:0] size_to_trim_unit;

//Internal wires to reg_file
wire [31:0] ra0_value_o_top;
wire [31:0] rb0_value_o_top;

//Internal wires to ALU
wire [31:0] op_a_top;
wire [31:0] op_b_top;
wire [ 4:0] sub_opcode_top;
wire [31:0] alu_to_store;
    
// Internal wires to pc_unit
wire        mstatus_mie_top;
wire        ld_dec_top;
wire        st_dec_top;
wire [31:0] imm_pc_to_top;
wire [ 1:0] inst_size_top;
wire [31:0] csr_out_top;

//Internal wires to CSR
wire        d_csr_en_top;
wire [ 2:0] d_csr_instr_top;
wire [11:0] d_csr_addr_top;
wire        d_csr_write_mode_top;
wire [ 4:0] d_csr_code_imm_top;
wire [31:0] d_csr_code_reg_top;
wire [ 1:0] d_sys_instr_top;    
wire        inter_enable_rvtop;
wire        illegal_instr_top;
wire [31:0] instruction_to_decode;
wire w_stop_fetch_to_csr;
wire [31:0] pc_next_to_csr;
    // Instantiate decoder_rv module
  decoder_rv decoder (
    .inst2decode(inst2decode),
    .rs1_data(ra0_value_o_top),
    .rs2_data(rb0_value_o_top),
    .pc_next (pc_next_to_mem),//_temp),
    .rs1_addr(rs1_addr_top),
    .rs2_addr(rs2_addr_top),
    .rd_addr(rd_addr_top),
    .op_a(op_a_top),
    .op_b(op_b_top),
    .sub_opcode(sub_opcode_top),
    .sel_func_unit(sel_func_unit),
    .trap(trap),
    .inst_size(inst_size_to_mem_temp),
    .d_imm_pc_to_top(imm_pc_to_top),
    .cfi(cfi_top),
    .d_ld_dec(ld_dec_top),
    .d_st_dec(st_dec_top),
    .d_csr_en(d_csr_en_top),
    .d_csr_instr(d_csr_instr_top),
    .d_csr_addr(d_csr_addr_top),
    .d_csr_write_mode(d_csr_write_mode_top),
    .d_csr_code_imm(d_csr_code_imm_top),
    .d_csr_code_reg(d_csr_code_reg_top),
    .d_sys_instr(d_sys_instr_top),
    .d_dec_ecall(ecall_top),
    .d_dec_mret(mret_top),
    .d_dec_wfi(wfi_top),
    .d_jump(jump_top),
    .uop_lsu_to_mem(uop_lsu_to_mem_top),
    .d_jump_instr_type(jump_instr_type_top),
    .illegal_instr(illegal_instr_top),
    .instr_out(instruction_to_decode)
  );

  // Instantiate alu module
  alu alu_inst (
    .alu_lhs(op_a_top),
    .alu_rhs(op_b_top),
    .sub_opcode(sub_opcode_top),
    .alu_lt(alu_lt_top),
    .alu_eq(alu_eq_top),
    .alu_result(alu_to_store)
    );
    
    //Instantiate regfile module
  riscv_regfile regfile (
    .clk(clk),
    .resetn(resetn),
    .wen(wen_top),
    .rd0_i(rd_addr_top),
    .rd0_value_i(rd0_value_i_top),
    .ra0_i(rs1_addr_top),
    .rb0_i(rs2_addr_top),
    .ra0_value_o(ra0_value_o_top),
    .rb0_value_o(rb0_value_o_top)
    );
    
    // Instantiate pc_unit module
    pc_unit pc_unit_inst (
    .clk(clk),
    .resetn(resetn),
    .ld_dec(ld_dec_top),
    .st_dec(st_dec_top),
    .done_pram_load(load_when_reset),
    .mstatus_mie(mstatus_mie_top),
    .halt_ack(halt_ack),
    .csr_en(d_csr_en_top),
    .csr_out(csr_out_top),
    .interrupt_enable(interrupt_enable_rvtop),
    .imm_pc(imm_pc_to_top),
    .ls_addr_to_mem(ls_addr_to_mem_temp),
    .inst_size(inst_size_to_mem_temp),
    .rs1_data_top(op_a_top),
    .rs2_data_top(op_b_top),
    .instr_fetch_en(instr_fetch_enable_to_mem),
    .dec_ecall(ecall_top),
    .dec_mret(mret_top),
    .dec_wfi(wfi_top),
    .jump(jump_top),
    .jump_instr_type(jump_instr_type_top),
    //CHANGED@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    .pc_next(pc_next_to_mem),//_temp),
    .pram_read_status(pram_read_status),
    .illegal_instr( illegal_instr_top),
    .pc_cannot_increment(w_stop_fetch_to_csr),
    .interrupt_ack(interrupt_ack_rvtop_temp),
    .pc_next_to_csr(pc_next_to_csr)
  );

  // Instantiate csr module
  csr csr_inst (
    .clk(clk),
    .reset_n(resetn),
    .csr_en((halt_ack || pram_read_status) && d_csr_en_top),
    .csr_instr(d_csr_instr_top),
    .csr_addr(d_csr_addr_top),
    .csr_write_mode(d_csr_write_mode_top),
    .csr_code_imm(d_csr_code_imm_top),
    .csr_code_reg(d_csr_code_reg_top),
    .sys_instr(d_sys_instr_top),
    .ecall_op(ecall_top),
    .mret_op(mret_top),
    .pc(pc_next_to_csr),
    .stop_fetch(w_stop_fetch_to_csr),
    .interrupt(interrupt_enable_rvtop),
    .csr_out(csr_out_top),
    .mstatus_mie(mstatus_mie_top)
  );
/*
  // Instantiate interrupt_control module
  interrupt_control interrupt_control_inst (
    .clk(clk),
    .reset_n(resetn),
    .intr_in(interrupt_enable_rvtop),
    .mie_bit(mstatus_mie_top),
    .intr_en(inter_enable_rvtop),
    .intr_ack(interrupt_ack_rvtop_temp)
  );*/

wire instr_is_jal;
assign instr_is_jal = (jump_instr_type_top == 6) || (jump_instr_type_top == 7);
wire instr_is_c_jal;
assign instr_is_c_jal =(jump_instr_type_top == 10) ||(jump_instr_type_top == 11);

  //control signals to register block
  assign wen_top = ((halt_ack || pram_read_status) && ((ls_mem_access_to_mem && ld_dec_top) || sel_func_unit[0] || sel_func_unit[1] || instr_is_jal || instr_is_c_jal || d_csr_en_top)) ? 1'b1 : 1'b0;
  assign rd0_value_i_top = ld_dec_top ? ls_read_data_from_mem:
                           (instr_is_jal && (inst_size_to_mem_temp==2))? pc_next_to_mem + 4:
                            (instr_is_jal && (inst_size_to_mem_temp==1))? pc_next_to_mem + 2:
                            (d_csr_en_top)? csr_out_top:
                             alu_to_store ;
  
  // Registering control signals
  //assign ls_mem_access_to_mem_temp = /*(pram_read_status || halt_ack)? 1'b0 :*/ cfi_top ? 1'b1 : 1'b0;
  //assign instr_fetch_enable_to_mem_temp =/* (pram_read_status || halt_ack)? 1'b1:*/ cfi_top ? 1'b0 : 1'b1;
  //assign rd_en_temp = (instr_fetch_enable_to_mem_temp | ld_dec_top) ? 1'b1 : 1'b0; 
  //assign wr_en_temp = (st_dec_top) ? 1'b1 : 1'b0; 
  assign size_to_trim_unit = (uop_lsu_to_mem_top == 2'b01) ? 2'b00 :
                             (uop_lsu_to_mem_top == 2'b10) ? 2'b01 :
                             (uop_lsu_to_mem_top == 2'b11) ? 2'b10 : 2'b10;
  
   /*
  assign ls_addr_to_mem_temp = (st_dec_top) ? 
    (ra0_value_o_top + {{27{instruction_to_decode[11]}}, instruction_to_decode[11:7]}) : 
    (ld_dec_top ? (ra0_value_o_top + {{27{instruction_to_decode[31]}}, instruction_to_decode[31:20]}) : 0);
    
    assign ls_addr_to_mem_temp = (st_dec_top) ? 
    (ra0_value_o_top + {{20{instruction_to_decode[31]}},instruction_to_decode[31:25], instruction_to_decode[11:7]}) : 
    (ld_dec_top ? (ra0_value_o_top + {{20{instruction_to_decode[31]}},instruction_to_decode[31:20]}) : 0);
   */
   reg [31:0] ra0_value_o_top_temp;
   reg [31:0] rb0_value_o_top_temp;
   always @(posedge clk) begin
        if(!resetn) begin
            ra0_value_o_top_temp <= 0;
            rb0_value_o_top_temp <= 0;
        end
        if(instr_fetch_enable_to_mem==1'b1 && (pram_read_status==1'b1 || halt_ack==1'b1)) begin
        ra0_value_o_top_temp <= ra0_value_o_top;
        rb0_value_o_top_temp <= rb0_value_o_top;
        end else begin
        ra0_value_o_top_temp <= ra0_value_o_top_temp;
        rb0_value_o_top_temp <= rb0_value_o_top_temp;
        end
   end
   
   
   wire real_condition_for_regfile_val = (instr_fetch_enable_to_mem==1'b1 && (pram_read_status==1'b1 || halt_ack==1'b1));
   wire [31:0] ra0_value_o_top_real = real_condition_for_regfile_val?ra0_value_o_top:ra0_value_o_top_temp  ;
   wire [31:0] rb0_value_o_top_real= real_condition_for_regfile_val?rb0_value_o_top:rb0_value_o_top_temp  ;
   
   assign ls_write_data_to_mem_temp = rb0_value_o_top_real;
   
    wire [4:0] offset_last_5 =    {5{st_dec_top}} & instruction_to_decode[11:7] |
                            {5{ld_dec_top}} & instruction_to_decode[24:20];
    
    wire [31:0] addr_offset = {{20{instruction_to_decode[31]}},instruction_to_decode[31:25], offset_last_5};
    assign ls_addr_to_mem_temp = ra0_value_o_top_real + addr_offset;
    ////////////////////////////////////////////////////////////////////////////////
 
 wire instr_is_ext;
  assign instr_is_ext = (ls_addr_to_mem_temp[14] || ls_addr_to_mem_temp[15] || ls_addr_to_mem_temp[16]);//&& (ld_dec_top || st_dec_top);
 reg pram_load;
 
 reg instr_done;
 //assign hold_control =  
 
 
 always @(posedge clk) begin
  if(!resetn) begin
    pram_load <= 1;
  end
  else begin
  pram_load <= load_when_reset;
  end
 end
 
 
 
    always @(posedge clk) begin
        if(!resetn) begin
            ls_mem_access_to_mem <= 1'b0;
            instr_fetch_enable_to_mem <= 1'b0;
            rd_en <= 1'b0;
            wr_en <= 1'b0;
            ls_write_data_to_mem <= 32'd0;
            ls_addr_to_mem <= 32'd0;
            inst_size_to_mem <= 2'b10;
            instr_done <= 1'b0;
        
        end else if(!instr_is_ext  && st_dec_top ) begin//pram write
            if( pram_read_status && !instr_done) begin
                ls_mem_access_to_mem <= 1'b1;
                instr_fetch_enable_to_mem <= 1'b0;
                rd_en <= 1'b0;
                wr_en <= 1'b1;
                  ls_write_data_to_mem <= ls_write_data_to_mem_temp;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
          
                inst_size_to_mem <= size_to_trim_unit;//inst_size_to_mem_temp;
                instr_done <= 1'b1;
            end else if(!pram_read_status && instr_done && !instr_fetch_enable_to_mem) begin
                ls_mem_access_to_mem <= 1'b0;
                instr_fetch_enable_to_mem <= 1'b1;
                rd_en <= 1'b1;
                wr_en <= 1'b0;
                ls_write_data_to_mem <= ls_write_data_to_mem_temp;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
                inst_size_to_mem <= size_to_trim_unit;//inst_size_to_mem_temp;//check
                instr_done <= 1'b0;
            end else begin
                ls_mem_access_to_mem <= 1'b0;
                instr_fetch_enable_to_mem <= 1'b1;
                rd_en <= 1'b1;
                wr_en <= 1'b0;
                ls_write_data_to_mem <= ls_write_data_to_mem_temp;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
                inst_size_to_mem <= inst_size_to_mem_temp;//check
                instr_done <= 1'b0;
            end
          
          
        end else if(!instr_is_ext  && ld_dec_top ) begin//pram read
          
          if( pram_read_status && !instr_done) begin
                ls_mem_access_to_mem <= 1'b1;
                instr_fetch_enable_to_mem <= 1'b0;
                rd_en <= 1'b1;
                wr_en <= 1'b0;
                  ls_write_data_to_mem <= ls_write_data_to_mem_temp;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
          
                inst_size_to_mem <= size_to_trim_unit;//inst_size_to_mem_temp;
                instr_done <= instr_done;
            end else if(!pram_read_status && !instr_done && !instr_fetch_enable_to_mem) begin
                ls_mem_access_to_mem <= 1'b1;
                instr_fetch_enable_to_mem <= 1'b0;
                rd_en <= 1'b1;
                wr_en <= 1'b0;
                ls_write_data_to_mem <= 32'b0;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
                inst_size_to_mem <= size_to_trim_unit;//inst_size_to_mem_temp;//check
                instr_done <= 1'b1;
            end else begin
                ls_mem_access_to_mem <= 1'b0;
                instr_fetch_enable_to_mem <= 1'b1;
                rd_en <= 1'b1;
                wr_en <= 1'b0;
                ls_write_data_to_mem <= 32'b0;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
                inst_size_to_mem <= inst_size_to_mem_temp;//check
                instr_done <= 1'b0;
            end
        
        end else if(instr_is_ext && ld_dec_top) begin//ext read
          if( !halt_ack && !instr_done) begin
                 ls_mem_access_to_mem <= 1'b1;
                instr_fetch_enable_to_mem <= 1'b0;
                rd_en <= 1'b1;
                wr_en <= 1'b0;
                ls_write_data_to_mem <= ls_write_data_to_mem_temp;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
          
                inst_size_to_mem <= size_to_trim_unit;//inst_size_to_mem_temp;
                instr_done <= instr_done;
            end else if( halt_ack && !instr_done) begin
                ls_mem_access_to_mem <= 1'b0;
                instr_fetch_enable_to_mem <= 1'b1;
                rd_en <= 1'b1;
                wr_en <= 1'b0;
                ls_write_data_to_mem <= 32'b0;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
                inst_size_to_mem <= inst_size_to_mem_temp;//check
                instr_done <= 1'b1;
            end else begin
                ls_mem_access_to_mem <= 1'b0;
                instr_fetch_enable_to_mem <= 1'b1;
                rd_en <= 1'b1;
                wr_en <= 1'b0;
                ls_write_data_to_mem <= 32'b0;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
                inst_size_to_mem <= inst_size_to_mem_temp;//check
                instr_done <= 1'b0;
            end
          
        
        end else if(instr_is_ext && st_dec_top  ) begin//ext write
          if( !halt_ack && !instr_done) begin
                ls_mem_access_to_mem <= 1'b1;
                instr_fetch_enable_to_mem <= 1'b0;
                rd_en <= 1'b0;
                wr_en <= 1'b1;
                ls_write_data_to_mem <= ls_write_data_to_mem_temp;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
          
                inst_size_to_mem <= size_to_trim_unit;//inst_size_to_mem_temp;
                instr_done <= instr_done;
            end else if( halt_ack && !instr_done) begin
                ls_mem_access_to_mem <= 1'b0;
                instr_fetch_enable_to_mem <= 1'b1;
                rd_en <= 1'b1;
                wr_en <= 1'b0;
                ls_write_data_to_mem <= 32'b0;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
                inst_size_to_mem <= inst_size_to_mem_temp;//check
                instr_done <= 1'b1;
            end else begin
                ls_mem_access_to_mem <= 1'b0;
                instr_fetch_enable_to_mem <= 1'b1;
                rd_en <= 1'b1;
                wr_en <= 1'b0;
                ls_write_data_to_mem <= 32'b0;
                ls_addr_to_mem <= ls_addr_to_mem_temp;
                inst_size_to_mem <= inst_size_to_mem_temp;//check
                instr_done <= 1'b0;
            end
          
        end else if ((load_when_reset != pram_load)/* || (instr_is_ext && halt_ack) || ( !instr_is_ext && pram_read_status) && !instr_done*/) begin
            ls_mem_access_to_mem <= 1'b0;
            instr_fetch_enable_to_mem <= 1'b1;
            rd_en <= 1'b1;
            wr_en <= 1'b0;
            ls_write_data_to_mem <= 32'b0;
            ls_addr_to_mem <= ls_addr_to_mem_temp;
            inst_size_to_mem <= inst_size_to_mem_temp;//check
            instr_done <= instr_done;
        end else begin
            ls_mem_access_to_mem <= ls_mem_access_to_mem;
            instr_fetch_enable_to_mem <= instr_fetch_enable_to_mem;
            rd_en <= rd_en;
            wr_en <= wr_en;
            ls_write_data_to_mem <= ls_write_data_to_mem;
            ls_addr_to_mem <= ls_addr_to_mem;
            inst_size_to_mem <= inst_size_to_mem;
            instr_done <= instr_done;
        end
    end
    
    assign interrupt_ack_rvtop = interrupt_ack_rvtop_temp;
  
endmodule
