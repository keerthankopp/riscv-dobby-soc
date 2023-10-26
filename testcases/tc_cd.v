// Company           :   tud                      
// Author            :   veni22            
// E-Mail            :   <email>                    
//                    			
// Filename          :   compression_decoder.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Tue Sep 12 16:50:24 2023 
// Last Change       :   $Date$
// by                :   $Author$                  			
//------------------------------------------------------------

//Fill in testcase specific pattern generation
initial begin

	#1;
    //c.add
    instr_16 = 16'b1001001010101010;
    #10; // Wait for 10 time units
    $display("c.add",32'b00000000101000101000001010110011 == instr_32);
  
    //c.addi
    instr_16 = 16'b0000000010111101;
    #10; // Wait for 10 time units
    $display("c.addi",32'b00000000111100001000000010010011 == instr_32);
    
    //c.addi16sp
    instr_16 = 16'b0110000100010001;
    #10; // Wait for 10 time units
    $display("c.addi16spn",32'b00010000000000010000000100010011 == instr_32);
    
    //c.addi4spn
    instr_16 = 16'b0000100000001000;
    #10; // Wait for 10 time units
    $display("c.addi4spn",32'b00000001000000010000010100010011 == instr_32);
    
    //c.sub
    instr_16 = 16'b1000111010001001;
    #10; // Wait for 10 time units
    $display("c.sub",32'b01000000101001101000011010110011 == instr_32);
  
    //c.and
    instr_16 = 16'b1000111011101001;
    #10; // Wait for 10 time units
    $display("c.and",32'b00000000101001101111011010110011 == instr_32);
    
    //c.andi
    instr_16 = 16'b1000101011000001;
    #10; // Wait for 10 time units
    $display("c.andi",32'b00000001000001101111011010010011 == instr_32);
    
    //c.or
    instr_16 = 16'b1000111011001001;
    #10; // Wait for 10 time units
    $display("c.or",32'b00000000101001101110011010110011 == instr_32);
    
    //c.xor 
     instr_16 = 16'b1000111010101001;
    #10; // Wait for 10 time units
    $display("c.xor",32'b00000000101001101100011010110011 == instr_32);
   
   //c.mv  
    instr_16 = 16'b1000001100010110;
    #10; // Wait for 10 time units
    $display("c.mv",32'b00000000010100000000001100110011 == instr_32);
     
    //c.li
    instr_16 = 16'b0100000011000001;
    #10; // Wait for 10 time units
    $display("c.li",32'b00000001000000000000000010010011 == instr_32);
    
    //c.lui
    instr_16 = 16'b0110000011000001;
    #10; // Wait for 10 time units
    $display("c.lui",32'b00000000000000010000000010110111 == instr_32);
    
    
    //c.lw
    instr_16 = 16'b0100100110010100;
    #10; // Wait for 10 time units
    $display("c.lw",32'b 00000001000001011010011010000011 == instr_32);
    
    
    //c;lwsp
    instr_16 = 16'b0100000111000010;
    #10; // Wait for 10 time units
    $display("c.lwsp",32'b00000001000000010010000110000011 == instr_32);
    
    //c.sw
    instr_16 = 16'b1100100110010100;
    #10; // Wait for 10 time units
    $display("c.sw",32'b00000000110101011010100000100011 == instr_32);
    
    //c.swsp
    instr_16 = 16'b1100100000001110;
    #10; // Wait for 10 time units
    $display("c.swsp",32'b00000000001100010010100000100011 == instr_32);
    
    
    //c.slli
    instr_16 = 16'b0000000111000010;
    #10; // Wait for 10 time units
    $display("c.slli",32'b00000001000000011001000110010011 == instr_32);
    
    
    //c.srai
    instr_16 = 16'b1000010111000001;
    #10; // Wait for 10 time units
    $display("c.srai",32'b01000001000001011101010110010011 == instr_32);
    
    
    //c.srli
    instr_16 = 16'b1000000111000001;
    #10; // Wait for 10 time units
    $display("c.srli",32'b00000001000001011101010110010011 == instr_32);
    
    
    //c.bqez
    instr_16 = 16'b1100100110000001;
    #10; // Wait for 10 time units
    $display("c.bqez",32'b00000000000001011000100001100011  == instr_32);
    
    
    //c.bnez
    instr_16 = 16'b1110100110000001;
    #10; // Wait for 10 time units
    $display("c.bnez",32'b00000000000001011001100001100011 == instr_32);
    
    
    //c.j
    instr_16 = 16'b1010100000000001;
    #10; // Wait for 10 time units
    $display("c.j", 32'b00000001000000000000000001101111 == instr_32);
    
    //c.jr
    instr_16 = 16'b1000000110000010;
    #10; // Wait for 10 time units
    $display("c.jr", 32'b00000000000000011000000001100111 == instr_32);
    
    
    //c.jal
    instr_16 = 16'b0010100000000001;
    #10; // Wait for 10 time units
    $display("c.jal", 32'b00000001000000000000000011101111 == instr_32);
    
    
    //c.jalr
    instr_16 = 16'b1001000110000010;
    #10; // Wait for 10 time units
    $display("c.jalr", 32'b00000000000000011000000011100111 == instr_32);
    
    
    //c.nop
    instr_16 = 16'b0000000000000001;
    #10; // Wait for 10 time units
    $display("c.nop", 32'b00000000000000000000000000010011 == instr_32);
  	
	//invalid compressed instr
	instr_16 = 16'h3000;
    $finish;
end
