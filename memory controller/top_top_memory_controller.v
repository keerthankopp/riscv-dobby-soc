`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06/13/2023 08:22:19 PM
// Design Name: 
// Module Name: toppppp_mem_ctrl
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

module top_top_memory_controller(
    input IRQ0,
    input clk_i,
    input rst_n,
    input busy_control,
    
    input [1:0]size_select, //from ctrl unit
    
    input instr_fetch_enable, //from ctrl unit
    input [31:0] instr_addr, //from fetch unit: pc addr
    output [31:0] instruction, //to decoder  
 
    input ls_mem_access, //from ctrl is it an access to pram or bus?
    input [31:0] ls_addr, //from execution unit
    input [31:0] ls_write_data, //from execution unit
    output [31:0] ls_read_data, //from ld str unit from bus/pram
       
    input wr_en, //from ctrl is it a write to pram or bus? 
    input rd_en,

    //output ls_stop_fetch,
    
    output bus_ack_pc_updation,
    output load_when_reset,
    output pram_read_status
    );
    
    
    wire w_BUS_EN ,w_BUS_WE, w_BUS_RDY;
    wire [1:0] w_BUS_SIZE;
    wire [15:0] w_BUS_ADDR;
    wire [31:0] w_BUS_WRITE_DATA,w_BUS_READ_DATA;
    
top_memory_controller top_mem_ctrl_instance(
    
    .IRQ0(IRQ0), //from core to init controller
    .clk_i(clk_i), //TO CORE
    .rst_n(rst_n), //TO CORE
    .size_select(size_select), //from ctrl unit
    
    .instr_fetch_enable(instr_fetch_enable), //from core to mem ctrl
    .instr_addr(instr_addr), //from fetch unit: pc addr
    .instruction(instruction), // from memory bus/pram to decoder  
 
    .ls_mem_access(ls_mem_access), //from core is it an access to pram or bus?
    .ls_addr(ls_addr), //from execution unit
    .ls_write_data(ls_write_data), //from execution unit
    .ls_read_data(ls_read_data), //from ld str unit from bus/pram
       
    .wr_en(wr_en), //from ctrl is it a write to pram or bus? 
    .rd_en(rd_en),

    //.ls_stop_fetch(ls_stop_fetch),   
    
    // to external
    .O_BUS_EN(w_BUS_EN),
    .O_BUS_WE(w_BUS_WE),
    .I_BUS_RDY(w_BUS_RDY),
    .O_BUS_SIZE(w_BUS_SIZE),
    .O_BUS_ADDR(w_BUS_ADDR),
    .O_BUS_WRITE_DATA(w_BUS_WRITE_DATA),
    .I_BUS_READ_DATA(w_BUS_READ_DATA),
    
    .bus_ack_pc_updation(bus_ack_pc_updation),
    .load_when_reset(load_when_reset),
    .pram_read_status(pram_read_status)
    );
    
    
per1_ext_memory external_memory_ins(
    //from bus controller
    .clk(clk_i),
    .rst_n(rst_n),
    .busy_control(busy_control),
    .size_select(w_BUS_SIZE),
    .ext_mem_1_en(1'b1), 
    .addr(w_BUS_ADDR),
    ///inout [31:0]data_bus, //bidirectional bus
    .write_data(w_BUS_WRITE_DATA),
    .read_data(w_BUS_READ_DATA),
    .wr_en(w_BUS_WE),
    .rd_en(w_BUS_EN),
    
    //to bus controller
    //output reg wr_status,
    //output reg rd_status,
    .slave_ready(w_BUS_RDY)
    );
endmodule

