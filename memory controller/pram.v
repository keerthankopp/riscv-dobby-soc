// Company           :   tud                      
// Author            :   paja22            
// E-Mail            :   <email>                    
//                    			
// Filename          :   pram.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sun Jul  9 12:44:35 2023 
// Last Change       :   $Date: 2023-09-13 04:53:30 +0200 (Wed, 13 Sep 2023) $
// by                :   $Author: viro22 $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module pram(
    input clk_i,
    input [1:0]size_select,
    input pram_access,
    input pram_rd_en,
    input pram_wr_en,
    input [31:0] pram_write_data,
    input [15:0] pram_addr,
    output reg pram_read_status,
    output reg [31:0] pram_read_data);

    //SRAM Select 0 to 3
    wire sram0_en, sram1_en, sram2_en, sram3_en;
    
    parameter byte = 2'b00;
    parameter half_word = 2'b01;
    parameter word = 2'b10;
     
    parameter INITFILE0 = "none";
    parameter INITFILE1 = "none";
    parameter INITFILE2 = "none";
    parameter INITFILE3 = "none";
    
    wire [31:0] data_out_32_0, data_out_32_1, data_out_32_2, data_out_32_3;
    reg [31:0] mask;
    reg read_done; //samples pram_read_status; drives it to zero after one cycle
    reg [31:0] data_to_pram;
    
    wire sram0_cs, sram1_cs, sram2_cs, sram3_cs;
    
    assign sram0_cs = pram_access;// & sram0_en;
    assign sram1_cs = pram_access;// & sram1_en;
    assign sram2_cs = pram_access;// & sram2_en;
    assign sram3_cs = pram_access;// & sram3_en;
    
   reg [3:0] pram_addr_reg;

    always @(posedge clk_i)
    begin
        if(pram_access && pram_rd_en && !read_done) begin
            pram_read_status <= 1'b1;
            pram_addr_reg <= pram_addr[3:0];
          
        end else begin
            pram_read_status <= 1'b0;
            
        end
    end
    
    
    always @(posedge clk_i)
    begin
        if(pram_access && pram_rd_en && !pram_read_status)
            read_done <= 1'b1;
        else
            read_done <= 1'b0;
    end
    
   

 
        reg [9:0] sram_0_addr, sram_1_addr, sram_2_addr, sram_3_addr;
 
        always @ * begin
            case(pram_addr[3:0])
            4'b1101: begin
                    sram_0_addr = pram_addr[13:4] + 1;
                    sram_1_addr = pram_addr[13:4];
                    sram_2_addr = pram_addr[13:4];
                    sram_3_addr = pram_addr[13:4];
            end
            4'b1110: begin
                    sram_0_addr = pram_addr[13:4] + 1;
                    sram_1_addr = pram_addr[13:4] + 1;
                    sram_2_addr = pram_addr[13:4];
                    sram_3_addr = pram_addr[13:4];
            end
            4'b1111: begin
                    sram_0_addr = pram_addr[13:4] + 1;
                    sram_1_addr = pram_addr[13:4] + 1;
                    sram_2_addr = pram_addr[13:4] + 1;
                    sram_3_addr = pram_addr[13:4];
            end 
            default: begin
                    sram_0_addr = pram_addr[13:4];
                    sram_1_addr = pram_addr[13:4];
                    sram_2_addr = pram_addr[13:4];
                    sram_3_addr = pram_addr[13:4];
            end           
            endcase
        end
        
        
        reg [31:0] data_to_sram_0, data_to_sram_1, data_to_sram_2, data_to_sram_3;
        always @ * begin
            data_to_sram_0 = 32'b0;
            data_to_sram_1 = 32'b0;
            data_to_sram_2 = 32'b0;
            data_to_sram_3 = 32'b0;
            case(pram_addr[3:0])
            //4'b0000: {data_to_sram_3[7:0], data_to_sram_2[7:0], data_to_sram_1[7:0], data_to_sram_0[7:0]} = pram_write_data;
            4'b0001: {data_to_sram_0[15:8], data_to_sram_3[7:0], data_to_sram_2[7:0], data_to_sram_1[7:0]} = pram_write_data;
            4'b0010: {data_to_sram_1[15:8], data_to_sram_0[15:8], data_to_sram_3[7:0], data_to_sram_2[7:0]} = pram_write_data;
            4'b0011: {data_to_sram_2[15:8], data_to_sram_1[15:8], data_to_sram_0[15:8], data_to_sram_3[7:0]} = pram_write_data;
            4'b0100: {data_to_sram_3[15:8], data_to_sram_2[15:8], data_to_sram_1[15:8], data_to_sram_0[15:8]} = pram_write_data;
            4'b0101: {data_to_sram_0[23:16], data_to_sram_3[15:8], data_to_sram_2[15:8], data_to_sram_1[15:8]} = pram_write_data;
            4'b0110: {data_to_sram_1[23:16], data_to_sram_0[23:16], data_to_sram_3[15:8], data_to_sram_2[15:8]} = pram_write_data;
            4'b0111: {data_to_sram_2[23:16], data_to_sram_1[23:16], data_to_sram_0[23:16], data_to_sram_3[15:8]} = pram_write_data;
            4'b1000: {data_to_sram_3[23:16], data_to_sram_2[23:16], data_to_sram_1[23:16], data_to_sram_0[23:16]} = pram_write_data;
            4'b1001: {data_to_sram_0[31:24], data_to_sram_3[23:16], data_to_sram_2[23:16], data_to_sram_1[23:16]} = pram_write_data;
            4'b1010: {data_to_sram_1[31:24], data_to_sram_0[31:24], data_to_sram_3[23:16], data_to_sram_2[23:16]} = pram_write_data;
            4'b1011: {data_to_sram_2[31:24], data_to_sram_1[31:24], data_to_sram_0[31:24], data_to_sram_3[23:16]} = pram_write_data;
            4'b1100: {data_to_sram_3[31:24], data_to_sram_2[31:24], data_to_sram_1[31:24], data_to_sram_0[31:24]} = pram_write_data;
            4'b1101: {data_to_sram_0[7:0], data_to_sram_3[31:24], data_to_sram_2[31:24], data_to_sram_1[31:24]} = pram_write_data;
            4'b1110: {data_to_sram_1[7:0], data_to_sram_0[7:0], data_to_sram_3[31:24], data_to_sram_2[31:24]} = pram_write_data;
            4'b1111: {data_to_sram_2[7:0], data_to_sram_1[7:0], data_to_sram_0[7:0], data_to_sram_3[31:24]} = pram_write_data;
            default: {data_to_sram_3[7:0], data_to_sram_2[7:0], data_to_sram_1[7:0], data_to_sram_0[7:0]} = pram_write_data;
            endcase       

        end
        
        reg [31:0] mask_0, mask_1, mask_2, mask_3;
        
        always @ * begin
            mask_0 = 32'b0;
            mask_1 = 32'b0;
            mask_2 = 32'b0;
            mask_3 = 32'b0;
            if(pram_access && pram_wr_en) begin
                case(size_select)
                byte: begin
                    case(pram_addr[3:0])
                    //4'b0000: {mask_3[7:0], mask_2[7:0], mask_1[7:0], mask_0[7:0]} = 32'h000000ff;
                    4'b0001: {mask_0[15:8], mask_3[7:0], mask_2[7:0], mask_1[7:0]} = 32'h000000ff;
                    4'b0010: {mask_1[15:8], mask_0[15:8], mask_3[7:0], mask_2[7:0]} = 32'h000000ff;
                    4'b0011: {mask_2[15:8], mask_1[15:8], mask_0[15:8], mask_3[7:0]} = 32'h000000ff;
                    4'b0100: {mask_3[15:8], mask_2[15:8], mask_1[15:8], mask_0[15:8]} = 32'h000000ff;
                    4'b0101: {mask_0[23:16], mask_3[15:8], mask_2[15:8], mask_1[15:8]} = 32'h000000ff;
                    4'b0110: {mask_1[23:16], mask_0[23:16], mask_3[15:8], mask_2[15:8]} = 32'h000000ff;
                    4'b0111: {mask_2[23:16], mask_1[23:16], mask_0[23:16], mask_3[15:8]} = 32'h000000ff;
                    4'b1000: {mask_3[23:16], mask_2[23:16], mask_1[23:16], mask_0[23:16]} = 32'h000000ff;
                    4'b1001: {mask_0[31:24], mask_3[23:16], mask_2[23:16], mask_1[23:16]} = 32'h000000ff;
                    4'b1010: {mask_1[31:24], mask_0[31:24], mask_3[23:16], mask_2[23:16]} = 32'h000000ff;
                    4'b1011: {mask_2[31:24], mask_1[31:24], mask_0[31:24], mask_3[23:16]} = 32'h000000ff;
                    4'b1100: {mask_3[31:24], mask_2[31:24], mask_1[31:24], mask_0[31:24]} = 32'h000000ff;
                    4'b1101: {mask_0[7:0], mask_3[31:24], mask_2[31:24], mask_1[31:24]} = 32'h000000ff;
                    4'b1110: {mask_1[7:0], mask_0[7:0], mask_3[31:24], mask_2[31:24]} = 32'h000000ff;
                    4'b1111: {mask_2[7:0], mask_1[7:0], mask_0[7:0], mask_3[31:24]} = 32'h000000ff;
                    default: {mask_3[7:0], mask_2[7:0], mask_1[7:0], mask_0[7:0]} = 32'h000000ff;
                    endcase
                end
                half_word:begin
                    case(pram_addr[3:0])
                    //4'b0000: {mask_3[7:0], mask_2[7:0], mask_1[7:0], mask_0[7:0]} = 32'h0000ffff;
                    4'b0001: {mask_0[15:8], mask_3[7:0], mask_2[7:0], mask_1[7:0]} = 32'h0000ffff;
                    4'b0010: {mask_1[15:8], mask_0[15:8], mask_3[7:0], mask_2[7:0]} = 32'h0000ffff;
                    4'b0011: {mask_2[15:8], mask_1[15:8], mask_0[15:8], mask_3[7:0]} = 32'h0000ffff;
                    4'b0100: {mask_3[15:8], mask_2[15:8], mask_1[15:8], mask_0[15:8]} = 32'h0000ffff;
                    4'b0101: {mask_0[23:16], mask_3[15:8], mask_2[15:8], mask_1[15:8]} = 32'h0000ffff;
                    4'b0110: {mask_1[23:16], mask_0[23:16], mask_3[15:8], mask_2[15:8]} = 32'h0000ffff;
                    4'b0111: {mask_2[23:16], mask_1[23:16], mask_0[23:16], mask_3[15:8]} = 32'h0000ffff;
                    4'b1000: {mask_3[23:16], mask_2[23:16], mask_1[23:16], mask_0[23:16]} = 32'h0000ffff;
                    4'b1001: {mask_0[31:24], mask_3[23:16], mask_2[23:16], mask_1[23:16]} = 32'h0000ffff;
                    4'b1010: {mask_1[31:24], mask_0[31:24], mask_3[23:16], mask_2[23:16]} = 32'h0000ffff;
                    4'b1011: {mask_2[31:24], mask_1[31:24], mask_0[31:24], mask_3[23:16]} = 32'h0000ffff;
                    4'b1100: {mask_3[31:24], mask_2[31:24], mask_1[31:24], mask_0[31:24]} = 32'h0000ffff;
                    4'b1101: {mask_0[7:0], mask_3[31:24], mask_2[31:24], mask_1[31:24]} = 32'h0000ffff;
                    4'b1110: {mask_1[7:0], mask_0[7:0], mask_3[31:24], mask_2[31:24]} = 32'h0000ffff;
                    4'b1111: {mask_2[7:0], mask_1[7:0], mask_0[7:0], mask_3[31:24]} = 32'h0000ffff;
                    default: {mask_3[7:0], mask_2[7:0], mask_1[7:0], mask_0[7:0]} = 32'h0000ffff;
                    endcase


                end                    
                word: begin
                    case(pram_addr[3:0])
                    //4'b0000: {mask_3[7:0], mask_2[7:0], mask_1[7:0], mask_0[7:0]} = 32'hffffffff;
                    4'b0001: {mask_0[15:8], mask_3[7:0], mask_2[7:0], mask_1[7:0]} = 32'hffffffff;
                    4'b0010: {mask_1[15:8], mask_0[15:8], mask_3[7:0], mask_2[7:0]} = 32'hffffffff;
                    4'b0011: {mask_2[15:8], mask_1[15:8], mask_0[15:8], mask_3[7:0]} = 32'hffffffff;
                    4'b0100: {mask_3[15:8], mask_2[15:8], mask_1[15:8], mask_0[15:8]} = 32'hffffffff;
                    4'b0101: {mask_0[23:16], mask_3[15:8], mask_2[15:8], mask_1[15:8]} = 32'hffffffff;
                    4'b0110: {mask_1[23:16], mask_0[23:16], mask_3[15:8], mask_2[15:8]} = 32'hffffffff;
                    4'b0111: {mask_2[23:16], mask_1[23:16], mask_0[23:16], mask_3[15:8]} = 32'hffffffff;
                    4'b1000: {mask_3[23:16], mask_2[23:16], mask_1[23:16], mask_0[23:16]} = 32'hffffffff;
                    4'b1001: {mask_0[31:24], mask_3[23:16], mask_2[23:16], mask_1[23:16]} = 32'hffffffff;
                    4'b1010: {mask_1[31:24], mask_0[31:24], mask_3[23:16], mask_2[23:16]} = 32'hffffffff;
                    4'b1011: {mask_2[31:24], mask_1[31:24], mask_0[31:24], mask_3[23:16]} = 32'hffffffff;
                    4'b1100: {mask_3[31:24], mask_2[31:24], mask_1[31:24], mask_0[31:24]} = 32'hffffffff;
                    4'b1101: {mask_0[7:0], mask_3[31:24], mask_2[31:24], mask_1[31:24]} = 32'hffffffff;
                    4'b1110: {mask_1[7:0], mask_0[7:0], mask_3[31:24], mask_2[31:24]} = 32'hffffffff;
                    4'b1111: {mask_2[7:0], mask_1[7:0], mask_0[7:0], mask_3[31:24]} = 32'hffffffff;
                    default: {mask_3[7:0], mask_2[7:0], mask_1[7:0], mask_0[7:0]} = 32'hffffffff;
                    endcase

                end
                //default: begin 
                //mask = 32'hff_ff_ff_ff; //not to be used; added only for coverage 
                //end
                endcase
            end
        end
 
        HM_1P_GF28SLP_1024x32_1cr #(.INITFILE (INITFILE0)) HM_1P_GF28SLP_1024x32_1cr_0 (
        .CLK_I  (clk_i),
        .ADDR_I (sram_0_addr),
        .DW_I   (data_to_sram_0),//pram_write_data),
        .BM_I   (mask_0),
        .WE_I   (pram_wr_en),
        .RE_I   (pram_rd_en),
        .CS_I   (sram0_cs),
        .DR_O   (data_out_32_0),
        .DLYL   (2'b00),
        .DLYH   (2'b00),
        .DLYCLK (2'b00)
        );
        
    
         HM_1P_GF28SLP_1024x32_1cr #(.INITFILE (INITFILE1)) HM_1P_GF28SLP_1024x32_1cr_1 (
        .CLK_I  (clk_i),
        .ADDR_I (sram_1_addr),
        .DW_I   (data_to_sram_1),//pram_write_data),
        .BM_I   (mask_1),
        .WE_I   (pram_wr_en),
        .RE_I   (pram_rd_en),
        .CS_I   (sram1_cs),
        .DR_O   (data_out_32_1),
        .DLYL   (2'b00),
        .DLYH   (2'b00),
        .DLYCLK (2'b00)
        );
    
    
         HM_1P_GF28SLP_1024x32_1cr #(.INITFILE (INITFILE2)) HM_1P_GF28SLP_1024x32_1cr_2 (
        .CLK_I  (clk_i),
        .ADDR_I (sram_2_addr),
        .DW_I   (data_to_sram_2),//pram_write_data),
        .BM_I   (mask_2),
        .WE_I   (pram_wr_en),
        .RE_I   (pram_rd_en),
        .CS_I   (sram2_cs),
        .DR_O   (data_out_32_2),
        .DLYL   (2'b00),
        .DLYH   (2'b00),
        .DLYCLK (2'b00)
        );
        
    
         HM_1P_GF28SLP_1024x32_1cr #(.INITFILE (INITFILE3)) HM_1P_GF28SLP_1024x32_1cr_3 (
        .CLK_I  (clk_i),
        .ADDR_I (sram_3_addr),
        .DW_I   (data_to_sram_3),//pram_write_data),
        .BM_I   (mask_3),
        .WE_I   (pram_wr_en),
        .RE_I   (pram_rd_en),
        .CS_I   (sram3_cs),
        .DR_O   (data_out_32_3),
        .DLYL   (2'b00),
        .DLYH   (2'b00),
        .DLYCLK (2'b00)
        );
        
        always @ * begin
            case(pram_addr_reg)
            //4'b0000: pram_read_data = {data_out_32_3[7:0], data_out_32_2[7:0], data_out_32_1[7:0], data_out_32_0[7:0]};
            4'b0001: pram_read_data = {data_out_32_0[15:8], data_out_32_3[7:0], data_out_32_2[7:0], data_out_32_1[7:0]};
            4'b0010: pram_read_data = {data_out_32_1[15:8], data_out_32_0[15:8], data_out_32_3[7:0], data_out_32_2[7:0]};
            4'b0011: pram_read_data = {data_out_32_2[15:8], data_out_32_1[15:8], data_out_32_0[15:8], data_out_32_3[7:0]};
            4'b0100: pram_read_data = {data_out_32_3[15:8], data_out_32_2[15:8], data_out_32_1[15:8], data_out_32_0[15:8]};
            4'b0101: pram_read_data = {data_out_32_0[23:16], data_out_32_3[15:8], data_out_32_2[15:8], data_out_32_1[15:8]};
            4'b0110: pram_read_data = {data_out_32_1[23:16], data_out_32_0[23:16], data_out_32_3[15:8], data_out_32_2[15:8]};
            4'b0111: pram_read_data = {data_out_32_2[23:16], data_out_32_1[23:16], data_out_32_0[23:16], data_out_32_3[15:8]};
            4'b1000: pram_read_data = {data_out_32_3[23:16], data_out_32_2[23:16], data_out_32_1[23:16], data_out_32_0[23:16]};
            4'b1001: pram_read_data = {data_out_32_0[31:24], data_out_32_3[23:16], data_out_32_2[23:16], data_out_32_1[23:16]};
            4'b1010: pram_read_data = {data_out_32_1[31:24], data_out_32_0[31:24], data_out_32_3[23:16], data_out_32_2[23:16]};
            4'b1011: pram_read_data = {data_out_32_2[31:24], data_out_32_1[31:24], data_out_32_0[31:24], data_out_32_3[23:16]};
            4'b1100: pram_read_data = {data_out_32_3[31:24], data_out_32_2[31:24], data_out_32_1[31:24], data_out_32_0[31:24]};
            4'b1101: pram_read_data = {data_out_32_0[7:0], data_out_32_3[31:24], data_out_32_2[31:24], data_out_32_1[31:24]};
            4'b1110: pram_read_data = {data_out_32_1[7:0], data_out_32_0[7:0], data_out_32_3[31:24], data_out_32_2[31:24]};
            4'b1111: pram_read_data = {data_out_32_2[7:0], data_out_32_1[7:0], data_out_32_0[7:0], data_out_32_3[31:24]};
            default: pram_read_data = {data_out_32_3[7:0], data_out_32_2[7:0], data_out_32_1[7:0], data_out_32_0[7:0]};
            
            endcase       
        end
endmodule
