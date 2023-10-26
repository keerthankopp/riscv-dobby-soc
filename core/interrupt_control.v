// Company           :   tud                      
// Author            :   paja22            
// E-Mail            :   <email>                    
//                    			
// Filename          :   intr_ctrl.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Jun  6 17:21:34 2023 
// Last Change       :   $Date: 2023-07-09 14:31:20 +0200 (Sun, 09 Jul 2023) $
// by                :   $Author: viro22 $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module interrupt_control(
    input clk,
    input reset_n,
	input [1:0] intr_in,
	input mie_bit,
	//input stop_fetch,
	//input jump,
	
	output intr_en,
	output reg [1:0] intr_ack
    );
   
    
   	assign int_en = (intr_in[0] || intr_in[1]) ;

   	always @(posedge clk) begin

   	if(!reset_n)
   		intr_ack <= 2'b00;
   	else if(intr_in[0] && mie_bit)// && !stop_fetch)// && !jump)
   		intr_ack[0] <=1'b1;
   	else if (intr_in[1] && mie_bit)// && !stop_fetch)// && !jump)
   		intr_ack[1] <=1'b1;
   	else
   		intr_ack <= 2'b00;	

   	end

    
endmodule

