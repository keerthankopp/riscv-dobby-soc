`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nitin Krishna Venkatasan
// 
// Create Date: 11/18/2022 10:50:30 AM
// Design Name: 
// Module Name: compression_decoder

// 
//////////////////////////////////////////////////////////////////////////////////

//invalid compressed instruction any interuppts?
// 27 compressed instructions 


module compression_decoder(
	input [15:0] instr_16,
	output reg [31:0] instr_32);



	always @ * begin
		case ({instr_16[15:13], instr_16[1:0]})
	   
		5'b10001: begin
		    //c.sub
		    if(instr_16[12:10] == 3'b011 && instr_16[6:5] == 2'b00)
		        instr_32 = {7'b0100000, 2'b01, instr_16[4:2], 2'b01, instr_16[9:7], 3'b000, 2'b01, instr_16[9:7], 7'b0110011};
		        
		    else if (instr_16[12:10] == 3'b011 && instr_16[6:5] == 2'b01) //c.xor
		        instr_32 = {7'b0000000, 2'b01, instr_16[4:2], 2'b01, instr_16[9:7], 3'b100, 2'b01, instr_16[9:7], 7'b0110011};
		    else if (instr_16[12:10] == 3'b011 && instr_16[6:5] == 2'b10) //c.or
		        instr_32 = {7'b0000000, 2'b01, instr_16[4:2], 2'b01, instr_16[9:7], 3'b110, 2'b01, instr_16[9:7], 7'b0110011};
		    else if (instr_16[12:10] == 3'b011 && instr_16[6:5] == 2'b11) //c.and
		        instr_32 = {7'b0000000, 2'b01, instr_16[4:2], 2'b01, instr_16[9:7], 3'b111, 2'b01, instr_16[9:7], 7'b0110011};
		    else if (instr_16[11:10] == 2'b10) //c.andi
		        instr_32 = {{7{instr_16[12]}}, instr_16[6:2], 2'b01, instr_16[9:7], 3'b111, 2'b01, instr_16[9:7], 7'b0010011};
		    else if (instr_16[12] == 1'b0 && instr_16[6:2] == 5'b0) 
		        instr_32 = 32'b0;
		    else if (instr_16[11:10] == 2'b00)  //srli
		        instr_32 = {7'b0000000, instr_16[6:2], 2'b01, instr_16[9:7], 3'b101, 2'b01, instr_16[9:7], 7'b0010011};
		    else //srai
		        instr_32 = {7'b0100000, instr_16[6:2], 2'b01, instr_16[9:7], 3'b101, 2'b01, instr_16[9:7], 7'b0010011};
		    end
		      


		//c.addi4spn //invalid when uimm=0
		5'b00000: begin
		            if(instr_16[12:5] != 8'd0)  
		                instr_32 = {2'b00, instr_16[10:7], instr_16[12:11], instr_16[5],instr_16[6], 2'b00, 5'd2, 3'b000, 2'b01, instr_16[4:2], 7'b0010011};
		            else
		                  instr_32 = {32{1'b0}};
		          end 
		          
		5'b01101: begin
		    //c.addi16sp //invalid when uimm=0
		    if(instr_16[11:7] == 5'd2 && instr_16[6:2] != 5'd0)
		        instr_32 = {{3{instr_16[12]}}, instr_16[4], instr_16[3], instr_16[5], instr_16[2], instr_16[6], 4'b0000, 5'd2, 3'b000, 5'd2, 7'b0010011};
		    else //c.lui
		        instr_32 = {{15{instr_16[12]}}, instr_16[6:2], instr_16[11:7], 7'b0110111};
		    end
		                    
		5'b00001: begin
		    //c.nop
		    if(instr_16[12:2] == 11'b0)
		        instr_32 = {25'b0,7'b0010011};
		    else  //c.addi
		        instr_32 = {{7{instr_16[12]}}, instr_16[6:2], instr_16[11:7], 3'b000, instr_16[11:7], 7'b0010011};
		    end
		
		//c.lw
		5'b01000: instr_32 = {5'b00000, instr_16[5], instr_16[12:10], instr_16[6], 2'b00, 2'b01, instr_16[9:7], 3'b010, 2'b01, instr_16[4:2], 7'b0000011};
		//c.li
		5'b01001: instr_32 = {{7{instr_16[12]}}, instr_16[6:2], 5'd0, 3'b000, instr_16[11:7], 7'b0010011};
		// c.lwsp //invalid when rd=x0
		5'b01010: instr_32 = {4'b0000, instr_16[3:2], instr_16[12], instr_16[6:4], 2'b0, 5'd2, 3'b010, instr_16[11:7], 7'b0000011};
	   
		//c.sw
		5'b11000: instr_32 = {5'b00000, instr_16[5], instr_16[12], 2'b01, instr_16[4:2], 2'b01, instr_16[9:7], 3'b010, instr_16[11:10], instr_16[6],2'b00, 7'b0100011};
		//c.slli
		5'b00010: instr_32 = {7'b0000000, instr_16[6:2], instr_16[11:7], 3'b001, instr_16[11:7], 7'b0010011};
		// c.swsp //invalid when rd=x0
		5'b11010: instr_32 = {4'b0000, instr_16[8:7], instr_16[12], instr_16[6:2], 5'd2, 3'b010, instr_16[11:9], 2'b00, 7'b0100011};
		
		//c.jal
		5'b00101: instr_32 = {instr_16[12], instr_16[8], instr_16[10:9], instr_16[6], instr_16[7], instr_16[2], instr_16[11], instr_16[5:3], instr_16[12], {8{instr_16[12]}}, 5'd1, 7'b1101111}; 

		//c.j
		5'b10101: instr_32 = {instr_16[12], instr_16[8], instr_16[10:9], instr_16[6],instr_16[7], instr_16[2], instr_16[11], instr_16[5:3], instr_16[12], {8{instr_16[12]}}, 5'd0, 7'b1101111};
		    
		//c.beqz
		5'b11001: instr_32 = {{4{instr_16[12]}}, instr_16[6], instr_16[5], instr_16[2], 5'd0, 2'b01, instr_16[9:7], 3'b000, instr_16[11], instr_16[10], instr_16[4], instr_16[3], instr_16[12], 7'b1100011};
		  
		//c.bnez
		5'b11101: instr_32 = {{4{instr_16[12]}}, instr_16[6], instr_16[5], instr_16[2], 5'd0, 2'b01, instr_16[9:7], 3'b001, instr_16[11], instr_16[10], instr_16[4], instr_16[3], instr_16[12], 7'b1100011};
		   /*
		5'b10010: begin
		    if (instr_16[6:2] == 5'd0 && instr_16[11:7] != 5'b0) begin 
		        if (instr_16[12] == 1'b1) // c.jalr 
		            instr_32 = {12'b0, instr_16[11:7], 3'b000, 5'd1, 7'b1100111};
		        else  // c.jr
		            instr_32 = {12'b0, instr_16[11:7], 3'b000, 5'd0, 7'b1100111};
		        end 
		        else if (instr_16[11:7] != 5'b0) begin
		            if (instr_16[12] == 1'b0) // c.mv
		                instr_32 = {7'b0000000, instr_16[6:2], 5'd0, 3'b000, instr_16[11:7], 7'b0110011};
		            else
		                instr_32 = 32'd0;
		        end
		    end
		    */
		    
		     5'b10010: begin
		            if (instr_16[6:2] == 5'd0) 
		            begin
		                //c.jalr
		                if (instr_16[12] && instr_16[11:7] != 5'b0)
		                    instr_32 = {12'b0, instr_16[11:7], 3'b000, 5'd1, 7'b1100111};
		                    // c.jr
		                else
		                    instr_32 = {12'b0, instr_16[11:7], 3'b000, 5'd0, 7'b1100111};
		            end 
		            else if (instr_16[11:7] != 5'b0) begin
		                //c.mv
		                if (instr_16[12] == 1'b0)
		                    instr_32 = {7'b0000000, instr_16[6:2], 5'd0, 3'b000, instr_16[11:7], 7'b0110011};
		                else if (instr_16[11:2] == 10'b0) begin //c.ebreak
                        instr_32 = {12'h001,5'h0,3'h0,5'h0,5'h1c,2'h3};
                    	end else begin
		                    //c.add  //invalid when rd or  rs = x0
		                   //$display("here");
		                  instr_32 = {7'b0000000, instr_16[6:2], instr_16[11:7], 3'b000, instr_16[11:7], 7'b0110011};
		                end
						
		           end else
							instr_32 = {32{1'b0}};
		          end
		      default : instr_32 = {32{1'b0}};
		    endcase
		end            
endmodule
