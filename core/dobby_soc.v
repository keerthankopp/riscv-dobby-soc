`timescale 1ns / 1ps

module dobby_soc(
    input clk_i,
    input a_reset_l_i,
    output bus_en_o,
    output bus_we_o,
    input bus_rdy_i,
    output [1:0] bus_size_o,
    output [15:0] bus_addr_o,
    output [31:0] bus_write_data_o,
    input [31:0] bus_read_data_i,
    input [1:0] intr_h_i, //from external interface to mem ctrk
    output [1:0] intr_ack_o //from mem ctrl to external 

    );
    
    
    wire clk_sys,resetn_sys,rd_en_sys, wr_en_sys,fetch_en_sys,mem_access_sys, bus_ack_pc_updation_sys, load_when_reset_sys, pram_read_status_sys;
    wire [31:0] instruction_sys, pc_sys; 
    wire [1:0] interrupt_sys,  size_sel_sys;
    wire [31:0] write_data_sys, write_addr_sys,ls_read_data_sys;
    
    
    reg irq0_reg;
    reg [31:0] next_instruction, ls_read_data_next;
    reg bus_ack_next, load_when_reset_next;
    
    
    
riscv_top core_dut(
  .clk(clk_i), 
  .resetn(a_reset_l_i), 
  .halt_ack(bus_ack_pc_updation_sys),
  .load_when_reset(load_when_reset_sys),//?
  //removing register
  //.inst2decode(next_instruction),
  .inst2decode(instruction_sys),
  
    .pram_read_status(pram_read_status_sys),
  .ls_read_data_from_mem(ls_read_data_sys),
  
  .interrupt_enable_rvtop(intr_h_i),
  .instr_fetch_enable_to_mem(fetch_en_sys),
  .rd_en(rd_en_sys),
  .wr_en(wr_en_sys),
  .ls_mem_access_to_mem(mem_access_sys),
  .inst_size_to_mem(size_sel_sys), 
  .pc_next_to_mem(pc_sys),
  .ls_addr_to_mem(write_addr_sys),
  .ls_write_data_to_mem(write_data_sys),
  .interrupt_ack_rvtop(intr_ack_o)
  
  
  
);

 top_memory_controller mc_dut(
    
    .IRQ0(irq0_reg), //from core to init controller
    .clk_i(clk_i), //TO CORE
    .rst_n(a_reset_l_i), //TO CORE
    .size_select(size_sel_sys), //from ctrl unit
    
    .instr_fetch_enable(fetch_en_sys), //from core to mem ctrl
    .instr_addr(pc_sys), //from fetch unit: pc addr
    .instruction(instruction_sys), // from memory bus/pram to decoder  
 
    .ls_mem_access(mem_access_sys), //from core is it an access to pram or bus?
    .ls_addr(write_addr_sys), //from execution unit
    .ls_write_data(write_data_sys), //from execution unit
    .ls_read_data(ls_read_data_sys), //from ld str unit from bus/pram
       
    .wr_en(wr_en_sys), //from ctrl is it a write to pram or bus? 
    .rd_en(rd_en_sys),
    
    .pram_read_status(pram_read_status_sys),

    
    // to external 
    .bus_en_o(bus_en_o),
    .bus_we_o(bus_we_o),
    .bus_rdy_i(bus_rdy_i),
    .bus_size_o(bus_size_o),
    .bus_addr_o(bus_addr_o),
    .bus_write_data_o(bus_write_data_o),
    .bus_read_data_i(bus_read_data_i),
    .bus_ack_pc_updation(bus_ack_pc_updation_sys),
    .load_when_reset(load_when_reset_sys)
    );


always @(posedge clk_i) begin
    if(a_reset_l_i == 0) begin
        irq0_reg <= 0;
    end else begin
        irq0_reg <= intr_h_i[0];
    end
    
end



endmodule
