`timescale 1ns / 1ps

module trim_unit(
    input [1:0]size_select, //from ctrl unit
    input instr_fetch_enable, //from ctrl unit
    
    input [31:0] ls_addr, //from alu
    output [16:0] mod_ls_addr, //modified ld_str addr to ld_str controller 32'b to 17'b
    //inout ls_write_data,
    input [31:0] ls_write_data, //from alu
    output [31:0] mod_ls_write_data, //same as ls_write_Data
    input [31:0] ls_read_data, //from ld str unit
    output reg [31:0] mod_ls_read_data, //to reg file
    
    input [31:0] instr_addr, //from fetch unit: pc addr
    output [16:0] mod_instr_addr, //to pram 
    input [31:0] instr, //from pram and external mem
    output reg [31:0]mod_instr //to decoder 
    );
 
parameter byte = 2'b00;
parameter half_word = 2'b01;
parameter word = 2'b10;
 
assign mod_ls_write_data = ls_write_data;
assign mod_ls_addr = ls_addr[16:0]; 
assign mod_instr_addr = instr_addr[16:0];

always @ *
begin
    if(!instr_fetch_enable)
    begin
        case(size_select)
        byte: mod_ls_read_data = {{24{ls_read_data[7]}}, ls_read_data[7:0]};
        
        half_word: mod_ls_read_data = {{16{ls_read_data[15]}}, ls_read_data[15:0]};
      
        word:
            mod_ls_read_data = ls_read_data;
    
        default:
            mod_ls_read_data = ls_read_data;
        endcase
    end
    else
       mod_ls_read_data = 32'd0;
end
     
always @ *
begin
    if(instr_fetch_enable)
    begin
    mod_instr = instr;
    
    end
    else
        mod_instr = 32'd0;
    end
endmodule


