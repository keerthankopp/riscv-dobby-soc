/*
// Company           :   tud                      
// Author            :   koke22            
// E-Mail            :   <email>                    
//                    			
// Filename          :   riscv_regfile.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Jun  6 17:29:15 2023 
// Last Change       :   $Date: 2023-06-07 19:40:46 +0200 (Wed, 07 Jun 2023) $
// by                :   $Author: koke22 $                  			
//------------------------------------------------------------
`timescale 1ns/10ps

module riscv_regfile(
    input           clk,
    input           resetn,
    input           wen,
    input  [  4:0]  rd0_i,
    input  [ 31:0]  rd0_value_i,
    input  [  4:0]  ra0_i,
    input  [  4:0]  rb0_i,
    output [ 31:0]  ra0_value_o,
    output [ 31:0]  rb0_value_o
);

        reg [31:0]      rf[31:0];       // three ported register file,2 port read and 1 port for write at clk control.

        integer i;
    
        always @ (posedge clk, negedge resetn) begin
            if(!resetn) begin
                for(i=0; i<32; i=i+1) begin
                    rf[i]<=32'h0000;
                end
            end
            else if (wen && rd0_i!=5'd0)  
            rf[rd0_i] <= rd0_value_i;  
        end
*/
        //assign ra0_value_o = /*(ra0_i != 5'd0) ?*/ rf[ra0_i] /*: 0*/;
        //assign rb0_value_o = /*(rb0_i != 5'd0) ?*/ rf[rb0_i] /*: 0*/;

//endmodule
`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10.09.2023 10:24:21
// Design Name: 
// Module Name: reg_mod
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

module riscv_regfile(
    input           clk,
    input           resetn,
    input           wen,
    input  [  4:0]  rd0_i,
    input  [ 31:0]  rd0_value_i,
    input  [  4:0]  ra0_i,
    input  [  4:0]  rb0_i,
    output [ 31:0]  ra0_value_o,
    output [ 31:0]  rb0_value_o
);

    reg [31:0] rf31, rf30, rf29, rf28, rf27, rf26, rf25, rf24, rf23, rf22, rf21, rf20, rf19, rf18, rf17, rf16, rf15, rf14, rf13, rf12, rf11, rf10, rf9, rf8, rf7, rf6, rf5, rf4, rf3, rf2, rf1, rf0;
    //reg hello_what;
    always @ (posedge clk, negedge resetn) begin
        if(!resetn) begin
            rf0 <= 32'h0000; 
            rf1 <= 32'h0000;
            rf2 <= 32'h0000; 
            rf3 <= 32'h0000;
            rf4 <= 32'h0000;
            rf5 <= 32'h0000;
            rf6 <= 32'h0000;
            rf7 <= 32'h0000;
            rf8 <= 32'h0000;
            rf9 <= 32'h0000;
            rf10 <= 32'h0000;
            rf11 <= 32'h0000;
            rf12 <= 32'h0000;
            rf13 <= 32'h0000;
            rf14 <= 32'h0000;
            rf15 <= 32'h0000;
            rf16 <= 32'h0000;
            rf17 <= 32'h0000;
            rf18 <= 32'h0000;
            rf19 <= 32'h0000;
            rf20 <= 32'h0000;
            rf21 <= 32'h0000;
            rf22 <= 32'h0000;
            rf23 <= 32'h0000;
            rf24 <= 32'h0000;
            rf25 <= 32'h0000;
            rf26 <= 32'h0000;
            rf27 <= 32'h0000;
            rf28 <= 32'h0000;
            rf29 <= 32'h0000;
            rf30 <= 32'h0000;
            rf31 <= 32'h0000;
        end
        
        else if (wen && rd0_i!=5'd0)  
            case (rd0_i)
                //5'd0: rf0 <= rd0_value_i;
                5'd1: rf1 <= rd0_value_i;
                5'd2: rf2 <= rd0_value_i;
                5'd3: rf3 <= rd0_value_i;
                5'd4: rf4 <= rd0_value_i;
                5'd5: rf5 <= rd0_value_i;
                5'd6: rf6 <= rd0_value_i;
                5'd7: rf7 <= rd0_value_i;
                5'd8: rf8 <= rd0_value_i;
                5'd9: rf9 <= rd0_value_i;
                5'd10: rf10 <= rd0_value_i;
                5'd11: rf11 <= rd0_value_i;
                5'd12: rf12 <= rd0_value_i;
                5'd13: rf13 <= rd0_value_i;
                5'd14: rf14 <= rd0_value_i;
                5'd15: rf15 <= rd0_value_i;
                5'd16: rf16 <= rd0_value_i;
                5'd17: rf17 <= rd0_value_i;
                5'd18: rf18 <= rd0_value_i;
                5'd19: rf19 <= rd0_value_i;
                5'd20: rf20 <= rd0_value_i;
                5'd21: rf21 <= rd0_value_i;
                5'd22: rf22 <= rd0_value_i;
                5'd23: rf23 <= rd0_value_i;  
                5'd24: rf24 <= rd0_value_i;
                5'd25: rf25 <= rd0_value_i;
                5'd26: rf26 <= rd0_value_i;
                5'd27: rf27 <= rd0_value_i;
                5'd28: rf28 <= rd0_value_i;
                5'd29: rf29 <= rd0_value_i;
                5'd30: rf30 <= rd0_value_i;
                5'd31: rf31 <= rd0_value_i;
            endcase
    end
    wire ra_is_0= (ra0_i==5'd0);
wire ra_is_1= (ra0_i==5'd1);
wire ra_is_2= (ra0_i==5'd2);
wire ra_is_3= (ra0_i==5'd3);
wire ra_is_4= (ra0_i==5'd4);
wire ra_is_5= (ra0_i==5'd5);
wire ra_is_6= (ra0_i==5'd6);
wire ra_is_7= (ra0_i==5'd7);
wire ra_is_8= (ra0_i==5'd8);
wire ra_is_9= (ra0_i==5'd9);
wire ra_is_10= (ra0_i==5'd10);
wire ra_is_11= (ra0_i==5'd11);
wire ra_is_12= (ra0_i==5'd12);
wire ra_is_13= (ra0_i==5'd13);
wire ra_is_14= (ra0_i==5'd14);
wire ra_is_15= (ra0_i==5'd15);
wire ra_is_16= (ra0_i==5'd16);
wire ra_is_17= (ra0_i==5'd17);
wire ra_is_18= (ra0_i==5'd18);
wire ra_is_19= (ra0_i==5'd19);
wire ra_is_20= (ra0_i==5'd20);
wire ra_is_21= (ra0_i==5'd21);
wire ra_is_22= (ra0_i==5'd22);
wire ra_is_23= (ra0_i==5'd23);
wire ra_is_24= (ra0_i==5'd24);
wire ra_is_25= (ra0_i==5'd25);
wire ra_is_26= (ra0_i==5'd26);
wire ra_is_27= (ra0_i==5'd27);
wire ra_is_28= (ra0_i==5'd28);
wire ra_is_29= (ra0_i==5'd29);
wire ra_is_30= (ra0_i==5'd30);
wire ra_is_31= (ra0_i==5'd31);

    wire rb_is_0= (rb0_i==5'd0);
wire rb_is_1= (rb0_i==5'd1);
wire rb_is_2= (rb0_i==5'd2);
wire rb_is_3= (rb0_i==5'd3);
wire rb_is_4= (rb0_i==5'd4);
wire rb_is_5= (rb0_i==5'd5);
wire rb_is_6= (rb0_i==5'd6);
wire rb_is_7= (rb0_i==5'd7);
wire rb_is_8= (rb0_i==5'd8);
wire rb_is_9= (rb0_i==5'd9);
wire rb_is_10= (rb0_i==5'd10);
wire rb_is_11= (rb0_i==5'd11);
wire rb_is_12= (rb0_i==5'd12);
wire rb_is_13= (rb0_i==5'd13);
wire rb_is_14= (rb0_i==5'd14);
wire rb_is_15= (rb0_i==5'd15);
wire rb_is_16= (rb0_i==5'd16);
wire rb_is_17= (rb0_i==5'd17);
wire rb_is_18= (rb0_i==5'd18);
wire rb_is_19= (rb0_i==5'd19);
wire rb_is_20= (rb0_i==5'd20);
wire rb_is_21= (rb0_i==5'd21);
wire rb_is_22= (rb0_i==5'd22);
wire rb_is_23= (rb0_i==5'd23);
wire rb_is_24= (rb0_i==5'd24);
wire rb_is_25= (rb0_i==5'd25);
wire rb_is_26= (rb0_i==5'd26);
wire rb_is_27= (rb0_i==5'd27);
wire rb_is_28= (rb0_i==5'd28);
wire rb_is_29= (rb0_i==5'd29);
wire rb_is_30= (rb0_i==5'd30);
wire rb_is_31= (rb0_i==5'd31);

assign ra0_value_o = (ra_is_0) ? 32'h0000 :
                         (ra_is_1) ? rf1 :
                         (ra_is_2) ? rf2 :
                         (ra_is_3) ? rf3 :
                         (ra_is_4) ? rf4 :
                         (ra_is_5) ? rf5 :
                         (ra_is_6) ? rf6 :
                         (ra_is_7) ? rf7 :
                         (ra_is_8) ? rf8 :
                         (ra_is_9) ? rf9 :
                         (ra_is_10) ? rf10 :
                         (ra_is_11) ? rf11 :
                         (ra_is_12) ? rf12 :
                         (ra_is_13) ? rf13 :
                         (ra_is_14) ? rf14 :
                         (ra_is_15) ? rf15 :
                         (ra_is_16) ? rf16 :
                         (ra_is_17) ? rf17 :
                         (ra_is_18) ? rf18 :
                         (ra_is_19) ? rf19 :
                         (ra_is_20) ? rf20 :
                         (ra_is_21) ? rf21 :
                         (ra_is_22) ? rf22 :
                         (ra_is_23) ? rf23 :
                         (ra_is_24) ? rf24 :
                         (ra_is_25) ? rf25 :
                         (ra_is_26) ? rf26 :
                         (ra_is_27) ? rf27 :
                         (ra_is_28) ? rf28 :
                         (ra_is_29) ? rf29 :
                         (ra_is_30) ? rf30 :
                         (ra_is_31) ? rf31 : 32'h0000;

    
    /*
    assign ra0_value_o = (ra0_i==5'd0) ? 32'h0000 :
                         (ra0_i==5'd1) ? rf1 :
                         (ra0_i==5'd2) ? rf2 :
                         (ra0_i==5'd3) ? rf3 :
                         (ra0_i==5'd4) ? rf4 :
                         (ra0_i==5'd5) ? rf5 :
                         (ra0_i==5'd6) ? rf6 :
                         (ra0_i==5'd7) ? rf7 :
                         (ra0_i==5'd8) ? rf8 :
                         (ra0_i==5'd9) ? rf9 :
                         (ra0_i==5'd10) ? rf10 :
                         (ra0_i==5'd11) ? rf11 :
                         (ra0_i==5'd12) ? rf12 :
                         (ra0_i==5'd13) ? rf13 :
                         (ra0_i==5'd14) ? rf14 :
                         (ra0_i==5'd15) ? rf15 :
                         (ra0_i==5'd16) ? rf16 :
                         (ra0_i==5'd17) ? rf17 :
                         (ra0_i==5'd18) ? rf18 :
                         (ra0_i==5'd19) ? rf19 :
                         (ra0_i==5'd20) ? rf20 :
                         (ra0_i==5'd21) ? rf21 :
                         (ra0_i==5'd22) ? rf22 :
                         (ra0_i==5'd23) ? rf23 :
                         (ra0_i==5'd24) ? rf24 :
                         (ra0_i==5'd25) ? rf25 :
                         (ra0_i==5'd26) ? rf26 :
                         (ra0_i==5'd27) ? rf27 :
                         (ra0_i==5'd28) ? rf28 :
                         (ra0_i==5'd29) ? rf29 :
                         (ra0_i==5'd30) ? rf30 :
                         (ra0_i==5'd31) ? rf31 : 32'h0000;
    */
          
                         
                    assign rb0_value_o = (rb_is_0) ? 32'h0000 :
                         (rb_is_1) ? rf1 :
                         (rb_is_2) ? rf2 :
                         (rb_is_3) ? rf3 :
                         (rb_is_4) ? rf4 :
                         (rb_is_5) ? rf5 :
                         (rb_is_6) ? rf6 :
                         (rb_is_7) ? rf7 :
                         (rb_is_8) ? rf8 :
                         (rb_is_9) ? rf9 :
                         (rb_is_10) ? rf10 :
                         (rb_is_11) ? rf11 :
                         (rb_is_12) ? rf12 :
                         (rb_is_13) ? rf13 :
                         (rb_is_14) ? rf14 :
                         (rb_is_15) ? rf15 :
                         (rb_is_16) ? rf16 :
                         (rb_is_17) ? rf17 :
                         (rb_is_18) ? rf18 :
                         (rb_is_19) ? rf19 :
                         (rb_is_20) ? rf20 :
                         (rb_is_21) ? rf21 :
                         (rb_is_22) ? rf22 :
                         (rb_is_23) ? rf23 :
                         (rb_is_24) ? rf24 :
                         (rb_is_25) ? rf25 :
                         (rb_is_26) ? rf26 :
                         (rb_is_27) ? rf27 :
                         (rb_is_28) ? rf28 :
                         (rb_is_29) ? rf29 :
                         (rb_is_30) ? rf30 :
                         (rb_is_31) ? rf31 : 32'h0000;
/*    
                         
    assign rb0_value_o = (rb0_i==5'd0) ? 32'h0000 :
                         (rb0_i==5'd1) ? rf1 :
                         (rb0_i==5'd2) ? rf2 :
                         (rb0_i==5'd3) ? rf3 :
                         (rb0_i==5'd4) ? rf4 :
                         (rb0_i==5'd5) ? rf5 :
                         (rb0_i==5'd6) ? rf6 :
                         (rb0_i==5'd7) ? rf7 :
                         (rb0_i==5'd8) ? rf8 :
                         (rb0_i==5'd9) ? rf9 :
                         (rb0_i==5'd10) ? rf10 :
                         (rb0_i==5'd11) ? rf11 :
                         (rb0_i==5'd12) ? rf12 :
                         (rb0_i==5'd13) ? rf13 :
                         (rb0_i==5'd14) ? rf14 :
                         (rb0_i==5'd15) ? rf15 :
                         (rb0_i==5'd16) ? rf16 :
                         (rb0_i==5'd17) ? rf17 :
                         (rb0_i==5'd18) ? rf18 :
                         (rb0_i==5'd19) ? rf19 :
                         (rb0_i==5'd20) ? rf20 :
                         (rb0_i==5'd21) ? rf21 :
                         (rb0_i==5'd22) ? rf22 :
                         (rb0_i==5'd23) ? rf23 :
                         (rb0_i==5'd24) ? rf24 :
                         (rb0_i==5'd25) ? rf25 :
                         (rb0_i==5'd26) ? rf26 :
                         (rb0_i==5'd27) ? rf27 :
                         (rb0_i==5'd28) ? rf28 :
                         (rb0_i==5'd29) ? rf29 :
                         (rb0_i==5'd30) ? rf30 :
                         (rb0_i==5'd31) ? rf31 : 32'h0000;
      
        */          
endmodule
