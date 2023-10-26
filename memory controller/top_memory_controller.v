`timescale 1ns / 1ps

module top_memory_controller(
    
    input IRQ0, //from core to init controller
    input clk_i, 
    input rst_n, 
    input [1:0]size_select, //from ctrl unit
    
    input instr_fetch_enable, //from core to mem ctrl
    input [31:0] instr_addr, //from fetch unit: pc addr
    output [31:0] instruction, // from memory bus/pram to decoder  
 
    input ls_mem_access, //from core is it an access to pram or bus?
    input [31:0] ls_addr, //from execution unit
    input [31:0] ls_write_data, //from execution unit
    output [31:0] ls_read_data, //from ld str unit from bus/pram
       
    input wr_en, //from ctrl is it a write to pram or bus? 
    input rd_en,

    //output ls_stop_fetch,   
    
    // to external
    output bus_en_o,
    output bus_we_o,
    input bus_rdy_i,
    output [1:0] bus_size_o,
    output [15:0] bus_addr_o,
    output [31:0] bus_write_data_o,
    input [31:0] bus_read_data_i,
    
    output bus_ack_pc_updation,
    output load_when_reset,
    output pram_read_status
    );
    
wire w_pram_access;
wire [15:0] w_pram_addr;
wire [31:0] w_pram_read_data, w_pram_write_data;
wire w_pram_wr_en, w_pram_rd_en;
wire [1:0] w_pram_size_select;


wire w_bus_access;
wire [15:0] w_bus_addr;
wire [31:0] w_bus_read_data, w_bus_write_data;
wire w_bus_wr_en, w_bus_rd_en;
wire [1:0] w_bus_size_select;

wire [15:0]addr_counter;
wire w_bus_ack;
wire [15:0] w_pram_load_addr;
//wire w_pram_loaded;

reg [31:0] reg_instruction, reg_instruction_address;
wire [31:0] w_instruction;//instruction coming from pram/bus
wire condition_to_hold_instruction, instr_half_aligned;

always @ (posedge clk_i) begin
    if(!rst_n) begin
        reg_instruction <= 32'b0;
    end else if((pram_read_status || bus_ack_pc_updation) && instr_fetch_enable) begin
        reg_instruction <= w_instruction;
    end else begin
        reg_instruction <= reg_instruction;
    end
end

assign bus_ack_pc_updation = w_bus_ack;

memory_controller mem_ctrl_in1(
    .size_select(size_select), //from ctrl unit
    .instr_fetch_enable(instr_fetch_enable), //from ctrl unit
    .instr_addr(instr_addr), //from fetch unit: pc addr
    .instruction(w_instruction), //to decoder  
       
    .ls_addr(ls_addr), //from alu
    .ls_write_data(ls_write_data), //from alu
    .ls_read_data(ls_read_data), //from ld str unit from bus/pram
    
    .ls_mem_access(ls_mem_access), //from ctrl is it an access to pram or bus?
    .wr_en(wr_en), //from ctrl is it a write to pram or bus? 
    .rd_en(rd_en), //from crl is it a pram read or bus read?
    
    //.ls_stop_fetch(ls_stop_fetch),
   
    //pram
    .pram_access(w_pram_access), //is it a pram access?
    .pram_addr(w_pram_addr), // input 32-bit addr to 16-bit addr
    .pram_read_data(w_pram_read_data), //from pram
    .pram_write_data(w_pram_write_data), //to pram
    .pram_wr_en(w_pram_wr_en), //to pram    
    .pram_rd_en(w_pram_rd_en), //to pram
    //input pram_read_status, //from pram
    //input pram_write_status, //from pram
    .pram_size_select(w_pram_size_select),
    
    //bus
    .bus_access(w_bus_access), //is it a bus access?
    .bus_write_data(w_bus_write_data), //to external bus
    .bus_addr(w_bus_addr), //to external bus
    .bus_read_data(w_bus_read_data), //from external bus to core
    .bus_rd_en(w_bus_rd_en), //to bus
    .bus_wr_en(w_bus_wr_en), //to bus
    .bus_size_select(w_bus_size_select),

    .addr_counter(addr_counter), //from init
    .load_when_reset(load_when_reset), //from init controller, facilitates selection between fetch and load-store
    .bus_ack(w_bus_ack),
    .pram_load_addr(w_pram_load_addr),
    //.pram_loaded(w_pram_loaded)
    .bus_access_so_hold_instruction(condition_to_hold_instruction)
    );

pram pram_in1(
    .clk_i(clk_i),
    .size_select(w_pram_size_select),
    .pram_access(w_pram_access),
    .pram_rd_en(w_pram_rd_en),
    .pram_wr_en(w_pram_wr_en),
    .pram_write_data(w_pram_write_data),
    .pram_addr(w_pram_addr),
    .pram_read_data(w_pram_read_data),
    .pram_read_status(pram_read_status)
    );
    
    
bus_controller bus_controller_in(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .size_select_i(w_bus_size_select),
    .bus_access_i(w_bus_access), //from mem controller
    .wr_en_i(w_bus_wr_en),
    .rd_en_i(w_bus_rd_en),
    .write_data_i(w_bus_write_data),
    .read_data_o(w_bus_read_data),
    .addr_i(w_bus_addr), //not 17?


    .bus_en_o(bus_en_o),
    .bus_we_o(bus_we_o),
    .bus_rdy_i(bus_rdy_i),
    .bus_size_o(bus_size_o),
    .bus_addr_o(bus_addr_o),
    .bus_write_data_o(bus_write_data_o),
    .bus_read_data_i(bus_read_data_i),
    
    .bus_ack(w_bus_ack)
);

  init_controller init_controller_in1(
    .clk_i(clk_i),
    .rst_n(rst_n),
    .IRQ0(IRQ0), //interrupt
    .bus_ack(w_bus_ack),
    .addr_counter(addr_counter),
    .load_when_reset(load_when_reset), //to mem controller; facilitates selection between fetch and load-store
    .pram_load_addr(w_pram_load_addr)
    //.pram_loaded(w_pram_loaded)
    ); 
    
    //assign instruction = (condition_to_hold_instruction || !instr_fetch_enable)? reg_instruction: w_instruction;
     assign instruction = (instr_fetch_enable && (pram_read_status || bus_ack_pc_updation))? w_instruction: reg_instruction;
endmodule
