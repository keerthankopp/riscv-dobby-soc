// Company           :   tud                      
// Author            :   paja22            
// E-Mail            :   <email>                    
//                    			
// Filename          :   memory_controller.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sun Jul  9 08:48:34 2023 
// Last Change       :   $Date: 2023-08-29 22:25:28 +0200 (Tue, 29 Aug 2023) $
// by                :   $Author: koke22 $                  			
//------------------------------------------------------------
`timescale 1ns/10ps


module memory_controller(
    input [1:0]size_select, 
    input instr_fetch_enable, 
    input [31:0] instr_addr, 
    output [31:0] instruction,  
       
    input [31:0] ls_addr, 
    input [31:0] ls_write_data, 
    output [31:0] ls_read_data, 
      
    input ls_mem_access, 
    input wr_en,  
    input rd_en, 
    
    //pram
    output pram_access, 
    output [15:0] pram_addr, 
    input [31:0] pram_read_data, 
    output [31:0] pram_write_data, 
    output pram_wr_en,     
    output pram_rd_en, 
    output [1:0]pram_size_select,
    
    //bus
    output bus_access, 
    output [31:0] bus_write_data, 
    output [15:0] bus_addr, 
    input [31:0] bus_read_data, 
    output bus_rd_en, 
    output bus_wr_en, 
    output [1:0]bus_size_select,
    input bus_ack, 
    
    input [15:0] addr_counter, 
    input load_when_reset, 
    input [15:0] pram_load_addr,  
    output bus_access_so_hold_instruction
    );
    
    wire [16:0]w_ls_addr;
    wire [31:0]w_ls_write_data;
    wire [31:0]w_ls_read_data;
    wire [16:0]w_instr_addr;
    wire [31:0]w_pram_read_instruction;
    wire [31:0] w_bus_read_instruction;
    wire [31:0] w_instr; 

    wire w_ls_pram_access;
    wire [15:0] w_ls_pram_addr;
    wire [31:0] w_ls_pram_read_data;
    wire [31:0] w_ls_pram_write_data;
    wire w_ls_pram_wr_en;
    wire w_ls_pram_rd_en;
    
    wire w_ls_bus_access;
    wire [16:0] w_ls_bus_addr;
    wire [31:0] w_ls_bus_read_data;
    wire [31:0] w_ls_bus_write_data;
    wire w_ls_bus_wr_en;
    wire w_ls_bus_rd_en;
    
    wire pram_instr_fetch;
    wire bus_instr_fetch;
    
    assign bus_instr_fetch = (instr_fetch_enable)? w_instr_addr[14] || w_instr_addr[15] || w_instr_addr[16] : 1'b0;
    assign pram_instr_fetch = (instr_fetch_enable)? !bus_instr_fetch : 1'b0; 
    
    trim_unit trim_unit_i (
    .size_select(size_select), 
    .instr_fetch_enable(instr_fetch_enable), 
    
    .ls_addr(ls_addr), 
    .mod_ls_addr(w_ls_addr), 
    .ls_write_data(ls_write_data), 
    .mod_ls_write_data(w_ls_write_data),
    .ls_read_data(w_ls_read_data), 
    .mod_ls_read_data(ls_read_data), 
  
    .instr_addr(instr_addr), 
    .mod_instr_addr(w_instr_addr),
    .instr(w_instr),
    .mod_instr(instruction)
    );
    
    load_store_controller load_store_controller_i(
    .ls_addr(w_ls_addr),  
    .ls_write_data(w_ls_write_data),
    .ls_mem_access(ls_mem_access), 
    .wr_en(wr_en),  
    .rd_en(rd_en), 
    .ls_read_data(w_ls_read_data), 

    //pram
    .ls_pram_access(w_ls_pram_access),
    .ls_pram_addr(w_ls_pram_addr), 
    .ls_pram_read_data(w_ls_pram_read_data),
    .ls_pram_write_data(w_ls_pram_write_data),
    .ls_pram_wr_en(w_ls_pram_wr_en),    
    .ls_pram_rd_en(w_ls_pram_rd_en), 

    
    //bus
    .ls_bus_access(w_ls_bus_access),
    .ls_bus_write_data(w_ls_bus_write_data), 
    .ls_bus_addr(w_ls_bus_addr), 
    .ls_bus_read_data(w_ls_bus_read_data), 
    .ls_bus_rd_en(w_ls_bus_rd_en), 
    .ls_bus_wr_en(w_ls_bus_wr_en), 
    .bus_ack(bus_ack)
    ); 
    
     
    wire pram_addr_cond =  (instr_fetch_enable && pram_instr_fetch && !ls_mem_access);
    wire pram_write_data_cond = (ls_mem_access && w_ls_pram_wr_en && !w_ls_pram_rd_en); 
    wire w_ls_pram_read_data_cond = (!instr_fetch_enable && ls_mem_access && w_ls_pram_rd_en);
    wire w_pram_read_instruction_cond = (pram_instr_fetch && !ls_mem_access && rd_en && !w_ls_pram_rd_en);
     
    assign pram_access = (load_when_reset)? bus_ack : (pram_instr_fetch && !ls_mem_access)? 1'b1 : w_ls_pram_access;
    assign pram_addr = (load_when_reset)? (pram_load_addr) : pram_addr_cond ? w_instr_addr : w_ls_pram_addr;
    assign pram_write_data = (load_when_reset)? w_bus_read_instruction : pram_write_data_cond? w_ls_pram_write_data : 32'd0;
    assign w_ls_pram_read_data = w_ls_pram_read_data_cond? pram_read_data : 32'd0;
    assign w_pram_read_instruction = w_pram_read_instruction_cond? pram_read_data : 32'd0;
    assign pram_wr_en = (load_when_reset) ? 1'b1 : (ls_mem_access)? w_ls_pram_wr_en : 1'b0;
    assign pram_rd_en = (load_when_reset)? 1'b0: (ls_mem_access)? w_ls_pram_rd_en : (pram_instr_fetch)? 1'b1 : 1'b0;
    assign pram_size_select = (load_when_reset)? 2'b10 : size_select;

    wire bus_addr_cond = (bus_instr_fetch && !ls_mem_access);
    wire bus_write_data_cond = (ls_mem_access && w_ls_bus_wr_en);
    wire w_ls_bus_read_data_cond = (ls_mem_access && w_ls_bus_rd_en && !bus_instr_fetch && bus_ack);
    wire w_bus_read_instruction_cond = (bus_instr_fetch && !ls_mem_access);

    assign bus_access = (load_when_reset)? !bus_ack : (bus_instr_fetch && !ls_mem_access && !bus_ack)? 1'b1 : !bus_ack & w_ls_bus_access; 
    assign bus_write_data = (load_when_reset)? 32'd0 : bus_write_data_cond ? w_ls_bus_write_data: 32'd0; 
    assign w_ls_bus_read_data = (load_when_reset)? 32'd0: w_ls_bus_read_data_cond? bus_read_data: 32'd0;  
    assign w_bus_read_instruction = (load_when_reset)? bus_read_data : w_bus_read_instruction_cond? bus_read_data : 32'd0;
    assign bus_addr = (load_when_reset)? addr_counter : bus_addr_cond ? w_instr_addr : w_ls_bus_addr;    
    assign bus_rd_en = (load_when_reset)? 1'b1 : (ls_mem_access && !bus_instr_fetch)? w_ls_bus_rd_en: (bus_instr_fetch)? 1'b1: 1'b0; 
    assign bus_wr_en =  (load_when_reset)? 1'b0 : (ls_mem_access && !bus_instr_fetch)? w_ls_bus_wr_en: 1'b0; 
    assign bus_size_select = (load_when_reset)? 2'b10 : size_select;
    
    wire w_instr_cond_1 = (instr_fetch_enable && pram_instr_fetch);
    wire w_instr_cond_2 = (bus_ack && bus_instr_fetch);
   
    assign w_instr = w_instr_cond_1? w_pram_read_instruction : w_instr_cond_2 ? w_bus_read_instruction: 32'd0;
    assign bus_access_so_hold_instruction = w_ls_bus_access || bus_instr_fetch;
endmodule
