// Company           :   tud                      
// Author            :   paja22            
// E-Mail            :   <email>                    
//                    			
// Filename          :   load_store_controller.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sun Jul  9 08:35:12 2023 
// Last Change       :   $Date: 2023-07-09 11:09:31 +0200 (Sun, 09 Jul 2023) $
// by                :   $Author: paja22 $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module load_store_controller(
    
    input [16:0] ls_addr,  //from trim unit
    input [31:0] ls_write_data,
    input ls_mem_access, //from ctrl is it an access to pram or bus?
    input wr_en, //from ctrl is it a write to pram or bus? 
    input rd_en, //from crl is it a pram read or bus read?
    //input reg_file_wr_en, //can we write data to the reg file; equivalent to rd_en
    output [31:0] ls_read_data, //goes to fetch unit thro trim unit (data read from pram or external bus to register file)
    //output ls_stop_fetch,
    //pram
    output ls_pram_access, //is it a pram access?
    output reg [15:0] ls_pram_addr, // input 32-bit addr to 16-bit addr
    input [31:0] ls_pram_read_data, //from pram
    output reg [31:0] ls_pram_write_data, //to pram
    output reg ls_pram_wr_en, //to pram    
    output reg ls_pram_rd_en, //to pram
    //input ls_pram_read_status, //from pram
    //input ls_pram_write_status, //from pram
    
    //bus
    output ls_bus_access, //is it a bus access?
    output reg [31:0] ls_bus_write_data, //to external bus
    output reg [16:0] ls_bus_addr, //to external bus
    input [31:0] ls_bus_read_data, //from external bus to core
    output reg ls_bus_rd_en, //to bus
    output reg ls_bus_wr_en, //to bus
    //input ls_bus_ack,
    //input ls_bus_fetch_ack
    
    input bus_ack
    );

assign ls_bus_access = (ls_mem_access)? ls_addr[16] || ls_addr[15] || ls_addr[14] : 1'b0; 

//assign ls_bus_access = (ls_mem_access && !bus_ack)? ls_addr[16] || ls_addr[15] || ls_addr[14] : 1'b0; 
assign ls_pram_access = !ls_mem_access? 1'b0 : ((ls_addr[16] == 1'b0) && (ls_addr[15] == 1'b0) && (ls_addr[14] == 1'b0));

wire pram_read = (rd_en && ls_pram_access);
wire pram_write = (wr_en && ls_pram_access);

always @ * //combinational always block use blocking statements
begin
    ls_pram_rd_en = 1'b0; //default values
    ls_pram_addr = 16'd0;
    ls_pram_wr_en = 1'b0;
    ls_pram_write_data = 32'd0;
    ls_bus_rd_en = 1'b0;
    ls_bus_addr = 17'd0;
    ls_bus_wr_en = 1'b0;
    ls_bus_write_data = 32'd0;    
    
    if (pram_read) // read from pram
    begin
       ls_pram_rd_en = 1'b1;
       ls_pram_addr = ls_addr; 
    end
    else if (pram_write) //write to pram
    begin
        ls_pram_wr_en = 1'b1;
        ls_pram_addr = ls_addr;
        ls_pram_write_data = ls_write_data;
    end
    else if (rd_en && ls_bus_access) //read from external bus
    begin
       ls_bus_rd_en = 1'b1;
       ls_bus_addr = ls_addr;
    end
    else if (wr_en && ls_bus_access) //write to external bus
    begin
        ls_bus_wr_en = 1'b1;
        ls_bus_addr = ls_addr;
        ls_bus_write_data = ls_write_data;
    end
end

assign ls_read_data = (ls_bus_rd_en)? ls_bus_read_data : ls_pram_read_data;
//assign ls_read_data = (ls_mem_access && rd_en)? ls_bus_read_data : ls_pram_read_data;
//assign ls_stop_fetch = (ls_bus_access && !ls_bus_ack) || (ls_pram_access && !(ls_pram_read_status || ls_pram_write_status)); // = 1'b1 --> ld_str not complete
endmodule

