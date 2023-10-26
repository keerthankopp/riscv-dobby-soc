// Company           :   tud                      
// Author            :   veni22           
// E-Mail            :   <email>                    
//                    			
// Filename          :   bus_controller.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sun Jul  9 08:39:18 2023 
// Last Change       :   $Date: 2023-07-23 12:48:52 +0200 (Sun, 23 Jul 2023) $
// by                :   $Author: veni22 $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module bus_controller(
    input clk_i,
    input rst_n,
   
    input [1:0] size_select_i,
    input bus_access_i, //from mem controller
    input wr_en_i,
    input rd_en_i,
    input [31:0] write_data_i, //from mem ctrl 
    output [31:0] read_data_o, //to mem ctrl
    input [15:0] addr_i, 
    
    output bus_en_o,
    output bus_we_o,
    input bus_rdy_i,
    output [1:0] bus_size_o,
    output [15:0] bus_addr_o,
    output [31:0] bus_write_data_o,
    input [31:0] bus_read_data_i,    
    output  bus_ack
    
    );
    
        
    //master signals
    reg reg_access; //bus access
    reg reg_wr_en; 
    reg [15:0] reg_addr;
    reg [31:0] reg_write_data; //from mem ctrl to peripheral
    reg [1:0] reg_size_select;
    reg [31:0] reg_read_data;
    
    reg ctrl_on_bus;
    reg data_on_bus;
    reg ack_from_bus;

    always @(posedge clk_i  or negedge rst_n)
    begin
        if(!rst_n)
        begin
            reg_access <= 1'b0;
            reg_wr_en <= 1'b0;
            reg_addr <= 16'd0;
            reg_write_data <= 32'd0;
            reg_read_data <= 32'b0;
            reg_size_select <= 2'b00;
            ctrl_on_bus <= 1'b0;
            data_on_bus <= 1'b0;
            ack_from_bus <= 1'b0;
        end
        else if(bus_access_i == 1'b0)// && bus_ack)
        begin
                reg_access <= 1'b0;
                reg_wr_en <= 1'b0;
                reg_addr <= 16'd0;
                reg_write_data <= 32'd0;
                reg_read_data <= 32'b0;
                reg_size_select <= 2'b00;    
                ack_from_bus <= 1'b0;   
        end
        else if(bus_access_i && !ctrl_on_bus && !data_on_bus) // & !ack_from_bus 
        begin
                reg_access <= bus_access_i;
                reg_wr_en <= wr_en_i;
                reg_addr <= addr_i;
                reg_size_select <= size_select_i;
                reg_write_data <= 32'b0;
                
                ctrl_on_bus <= 1'b1;
                ack_from_bus <= 1'b0;
        
                //$display("ctrl on bus");

        end
        else if (bus_rdy_i && ctrl_on_bus && wr_en_i) /// & bus_ack) //when  data is to be written to peripheral 
        begin
                reg_access <= 1'b0;
                reg_wr_en <= 1'b0;
                reg_addr <= 16'b0;
                reg_size_select <= 2'b00;
                reg_write_data <= write_data_i;
                reg_read_data <= 32'b0;
                
                ctrl_on_bus <= 1'b0;
                data_on_bus <= 1'b1;
                //$display("data on bus");

        end 
        else if (bus_rdy_i && ctrl_on_bus && rd_en_i) /// & bus_ack) //when  data is to be written to peripheral 
        begin
                reg_access <= 1'b0;
                reg_wr_en <= 1'b0;
                reg_addr <= 16'b0;
                reg_size_select <= 2'b00;
                reg_write_data <= 32'b0;
                //reg_read_data <= I_BUS_READ_DATA;
                reg_read_data <= 32'b0;
                ctrl_on_bus <= 1'b0;
                data_on_bus <= 1'b1;
                //$display(" waiting for data on bus");

        end
        else if (ctrl_on_bus && !data_on_bus)
        begin
                reg_access <= bus_access_i;
                reg_wr_en <= wr_en_i;
                reg_addr <= addr_i;
                reg_size_select <= size_select_i;
                //$display("ctrl on bus");
                ctrl_on_bus <= 1'b1;
        end
        /*
        else if (bus_rdy_i && data_on_bus)
        begin
                reg_write_data <= 32'b0;
                reg_read_data <= bus_read_data_i;
                data_on_bus <= 1'b0;
                ack_from_bus <= 1'b1;
                $display("done");
        end
        */
        else if (bus_rdy_i && data_on_bus && wr_en_i)
        begin
                reg_write_data <= 32'b0;
                reg_read_data <= 32'b0;
                data_on_bus <= 1'b0;
                ack_from_bus <= 1'b1;
                //$display("write done");
        end
        else if (bus_rdy_i && data_on_bus && rd_en_i)
        begin
                reg_write_data <= 32'b0;
                reg_read_data <= bus_read_data_i;
                data_on_bus <= 1'b0;
                ack_from_bus <= 1'b1;
                //$display("read done");
        end
        else if (!bus_rdy_i && data_on_bus)
        begin
                reg_write_data <= reg_write_data;
                //reg_read_data <= 32'b0;
                data_on_bus <= 1'b1;
                ack_from_bus <= 1'b0;
                //$display("data still on bus even when bus is not ready");
        end
        else
        begin
                //$display("else executed");
                reg_access <= reg_access;
                reg_wr_en <= reg_wr_en;
                reg_addr <= reg_addr;
                reg_write_data <= reg_write_data;
                reg_read_data <= reg_read_data;
                
                ctrl_on_bus <= ctrl_on_bus;
                data_on_bus <= data_on_bus;
                ack_from_bus <=ack_from_bus;
        
        end
     end    

    
//to peripheral
assign bus_en_o = reg_access;
assign bus_we_o = reg_wr_en;
assign bus_addr_o = reg_addr;
assign bus_size_o = reg_size_select;
assign bus_write_data_o = reg_write_data;

//to mem ctrl
assign read_data_o = (ack_from_bus)? reg_read_data: 0;
assign bus_ack = ack_from_bus ;
endmodule

