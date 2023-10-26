// Company           :   tud                      
// Author            :   koke22            
// E-Mail            :   <email>                    
//                    			
// Filename          :   alu.v                
// Project Name      :   prz    
// Subproject Name   :   gf28_template    
// Description       :   <short description>            
//
// Create Date       :   Sat May 13 23:03:03 2023 
// Last Change       :   $Date: 2023-06-07 19:40:46 +0200 (Wed, 07 Jun 2023) $
// by                :   $Author: koke22 $                  			
//------------------------------------------------------------
`timescale 1ns/10ps
module alu (
input        [31:0] alu_lhs, 
input        [31:0] alu_rhs,
input		 [ 4:0]	sub_opcode,
output wire         alu_lt, // LHS < RHS
output wire         alu_eq, 
output wire  [31:0] alu_result
	);

reg signed [63:0] temp_result;
reg [31:0] reg_value;
reg alu_lt_reg;
assign alu_eq = alu_lhs == alu_rhs;

always @ * begin
    case (sub_opcode)
    	5'b00000: reg_value = alu_lhs + ~alu_rhs + {{31{1'b0}},1'b1}; //SUB
    	5'b00001: reg_value = alu_lhs + alu_rhs + 32'b0; //ADD
    	5'b01001: reg_value = alu_lhs & alu_rhs; //AND
    	5'b01010: reg_value = alu_lhs | alu_rhs; //OR
    	5'b01100: reg_value = alu_lhs ^ alu_rhs; //XOR
    	5'b10001: begin //SLT
    		reg_value = $signed(alu_lhs) < $signed(alu_rhs); 
    		alu_lt_reg = 1'b1;
    	end
    	5'b10010: begin //SLTU
    		reg_value = ($unsigned(alu_lhs) < $unsigned(alu_rhs)); 
    		alu_lt_reg = 1'b1;
    	end
    	5'b11001: reg_value = alu_lhs >>> alu_rhs; //SRA
    	5'b11010: reg_value = alu_lhs >> alu_rhs; //SRL
    	5'b11100: reg_value = alu_lhs << alu_rhs; //SLL
        5'b01000: reg_value = alu_lhs * alu_rhs; // MUL
        5'b01110: begin
                     temp_result = $signed(alu_lhs) * $signed(alu_rhs); // MULH
                     reg_value = temp_result[63:32];
                  end
        5'b01111: begin // MULHSU
            if (alu_lhs[31] == 1'b1) begin
                temp_result = $signed({{32{1'b1}}, alu_lhs}) * alu_rhs;
            end else begin
                temp_result = $signed(alu_lhs) * $unsigned(alu_rhs);
            end
            reg_value = temp_result [63:32];
        end
        5'b01101: begin // MULHU
            temp_result = $unsigned(alu_lhs) * $unsigned(alu_rhs);
            reg_value = temp_result [63:32];
        end
        5'b11000: begin // DIV
            if (alu_rhs == 0) begin
                reg_value = {32{1'b1}};
            end else if ((alu_lhs == -32'h80000000) && (alu_rhs == -1)) begin
                reg_value = alu_lhs;
            end else begin
                reg_value = alu_lhs / alu_rhs;
            end
        end
        5'b11110: begin // DIVU
            if (alu_rhs == 0) begin
                reg_value = {32{1'b1}};
            end else begin
                reg_value = alu_lhs / alu_rhs;
            end
        end
        5'b10000: begin // REM
            if (alu_rhs == 0) begin
                reg_value = alu_lhs;
            end else if ((alu_lhs == -32'h80000000) && (alu_rhs == -1)) begin
                reg_value = 0;
            end else begin
                reg_value = alu_lhs % alu_rhs;
            end
        end
        5'b10111: begin // REMU
            if (alu_rhs == 0) begin
                reg_value = alu_lhs;
            end else begin
                reg_value = alu_lhs % alu_rhs;
            end
        end
    endcase
end
    //ALU Output assignment
    assign alu_lt = alu_lt_reg;
    assign alu_result = reg_value;

endmodule
