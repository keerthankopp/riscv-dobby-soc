`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nitin Krishna Venkatesan
// 
// Create Date: 01/15/2023 04:22:39 PM
// Design Name: 
// Module Name: ext_mem_1
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

//bidirectional bus or 2 buses?
//can we pass Z as a signal which cant' overwrite contents
//rst?
//say for some reason: data_bus has a write_data of 66, and if expected read is 32 from location, why is the output 102: wrong!!

module per1_ext_memory(
    //from bus controller
    input clk,
    input rst_n,
    input [1:0] size_select,
    //input busy_control,//from tb to tell if slave is busy
    //input ext_mem_1_en,//en based on address
    input [15:0]addr,
    ///inout [31:0]data_bus, //bidirectional bus
    input [31:0]write_data,
    output [31:0]read_data,
    input wr_en,
    input rd_en,
    input [1:0] interrupt,
    
    output reg slave_ready//output when addr is sampled or data is written/read

    );

    parameter DEPTH = 16384 * 4; //2^14 32-bit words can be stored
    
    parameter byte = 2'b00;
    parameter half_word = 2'b01;
    parameter word = 2'b10;
 
    //reg [31:0] ram [0:DEPTH-1];
    reg [7:0] ram [0:DEPTH-1];
    wire ext_mem_1_en = 1;

    reg [15:0] write_addr_reg;
    reg [1:0] size_select_reg;
    reg [31:0] read_data_reg;
    reg write_en;
    
    wire busy_control = !(interrupt[0] || interrupt[1]);
    
    reg loaded;
    always @ * begin
        slave_ready = 1'b0;
        
        if ( (rd_en ==1'b1) && (busy_control)  && ext_mem_1_en) begin // accept write requests in idle state only
            slave_ready = 1'b1;
        end
        else if (  loaded == 1'b1 && (busy_control) && ext_mem_1_en ) begin
            slave_ready = 1'b1;
        end
    end
 
    always @ (posedge clk) begin
        if (!rst_n) begin
            write_addr_reg <= 0;
            size_select_reg <= 0;
            write_en <= 0;
            loaded <= 0;
        end else if(busy_control && ext_mem_1_en && rd_en ==1'b1) begin
            write_addr_reg <= addr;
            size_select_reg <= size_select;
            write_en <= wr_en;   
            loaded <= 1; 
        end else if(busy_control && ext_mem_1_en) begin
            write_addr_reg <= write_addr_reg;
            size_select_reg <= size_select_reg;
            write_en <= write_en;   
            loaded <= 0; 
        end else begin
            write_addr_reg <= write_addr_reg;
            size_select_reg <= size_select_reg;
            write_en <= write_en;    
            loaded <= loaded;
        end
    end
    
    always @ * begin
        read_data_reg = 32'b0;
        if( loaded == 1 && busy_control && ext_mem_1_en) begin
            read_data_reg = {ram[write_addr_reg+3], ram[write_addr_reg+2], ram[write_addr_reg+1], ram[write_addr_reg+0]};
        end
    end
    
    always @(posedge clk) begin
        if(!rst_n) begin
            //$readmemh("factorial.mem", ram);
            $readmemh("ext_mem1.mem", ram);
        end else if( loaded == 1 && busy_control && ext_mem_1_en && write_en) begin
            case(size_select_reg)
                byte: begin
                    ram[write_addr_reg] <= write_data[7:0];
                end
                half_word:
                begin
                    ram[write_addr_reg] <= write_data[7:0];
                    ram[write_addr_reg+1] <= write_data[15:8];
                end
                word: begin
                    ram[write_addr_reg] <= write_data[7:0];
                    ram[write_addr_reg+1] <= write_data[15:8];
                    ram[write_addr_reg+2] <= write_data[23:16];
                    ram[write_addr_reg+3] <= write_data[31:24];
                end
            endcase
        end
    end
    
    assign read_data = busy_control? read_data_reg: 32'b0;


    
    
    
    
endmodule
