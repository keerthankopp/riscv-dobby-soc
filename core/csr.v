`timescale 1ns / 1ps



module csr (

		input         clk,
		input         reset_n,		
		
		input         csr_en,	
		input [2:0]   csr_instr,
		input [11:0]  csr_addr,
		
		input         csr_write_mode,
		input [4:0]   csr_code_imm,
		input [31:0]  csr_code_reg,
		input [1:0]   sys_instr,
		
		
		input [31:0]  pc,
		//input         jump,
		input [1:0]   interrupt,
		input         stop_fetch,
		input     ecall_op,
		input     mret_op,	
		
		output    [31:0] 	csr_out,
		output        mstatus_mie	
	
	    );
	    
	    
    wire [31:0]    csr_write_data = csr_write_mode? {27'b0,csr_code_imm} : csr_code_reg;

    //registers
    
    reg [31:0] mcause_reg;
    reg [31:0] mstatus_reg;
    reg [31:0] mepc_reg;
    
    //conditions
    wire interrupt_valid_temp = (interrupt[0]||interrupt[1]) && mstatus_reg[3];
    wire interrupt_valid = interrupt_valid_temp && !stop_fetch;// && !jump;
    wire csrrw_op = csr_en && (csr_instr == 3'b001 || csr_instr == 3'b101);
    wire csrrs_op = csr_en && (csr_instr == 3'b010 || csr_instr == 3'b110);
    wire csrrc_op = csr_en && (csr_instr == 3'b011 || csr_instr == 3'b111);
    wire op_valid = /*interrupt_valid || mret_op ||ecall_op ||*/ csrrw_op || csrrs_op || csrrc_op;
    
    //MISA - info on supported ISA
    wire [31:0] misa_reg = 32'b010000000000000000001000100000100;//check
    wire misa_sel = csr_addr == 12'h301;
    
    //mtvec - reset pc
    wire [31:0] mtvec_reg = 32'b0;
    wire mtvec_sel = csr_addr == 12'h305;
    
    //mstatus
    wire mstatus_sel = csr_addr == 12'h300;
    wire [31:0] mstatus_next =  interrupt_valid?    32'h00001880://check
                                mret_op?    32'h00001888://check
                                (mstatus_sel && csrrw_op)? csr_write_data:
                                (mstatus_sel && csrrs_op)? (mstatus_reg | csr_write_data):
                                (mstatus_sel && csrrc_op)? (mstatus_reg & (~csr_write_data)):
                                mstatus_reg;
    wire mstatus_valid = (op_valid || interrupt_valid_temp || mret_op)    ;                        
    always @(posedge clk) begin
        if(!reset_n) begin
            mstatus_reg <= 32'h00001888;//check
        end else if(/*mstatus_sel &&*/ mstatus_valid && !stop_fetch) begin
            mstatus_reg <= mstatus_next;
        end
    end 
    
    //mepc
    wire mepc_sel = csr_addr == 12'h341;  
    wire [31:0] mepc_next =  interrupt_valid?    pc://check
                             ecall_op?    pc://check
                             (mepc_sel && csrrw_op)? csr_write_data:
                             (mepc_sel && csrrs_op)? (mepc_reg | csr_write_data):
                             (mepc_sel && csrrc_op)? (mepc_reg & (~csr_write_data)):
                             mepc_reg;
    wire mepc_valid = (op_valid ||interrupt_valid_temp || ecall_op);
    always @(posedge clk) begin
        if(!reset_n) begin
            mepc_reg <= 32'h0;//check
        end else if(mepc_valid && !stop_fetch) begin
            mepc_reg <= mepc_next;
        end
    end  
    
    //mcause
    wire mcause_sel = csr_addr == 12'h342;  
    wire [31:0] mcause_next =  interrupt_valid?    {1'b0,31'd11}://check
                             ecall_op?    {1'b0,31'd11}://check
                             (mcause_sel && csrrw_op)? csr_write_data:
                             (mcause_sel && csrrs_op)? (mcause_reg | csr_write_data):
                             (mcause_sel && csrrc_op)? (mcause_reg & (~csr_write_data)):
                             mcause_reg;
    wire mcause_valid = (op_valid || interrupt_valid_temp || ecall_op);
    always @(posedge clk) begin
        if(!reset_n) begin
            mcause_reg <= 32'h0;//check
        end else if(/*mcause_sel &&*/ mcause_valid && !stop_fetch) begin
            mcause_reg <= mcause_next;
        end
    end  
    
    //outputs
    assign mstatus_mie = mstatus_reg[3];
    
    assign csr_out =    /*(reset_n ==0)   ?
                        32'h0           :*/
                        ({32{/*csr_en &&*/ misa_sel}} & misa_reg) |
                        ({32{/*csr_en && */mtvec_sel}} & mtvec_reg) |
                        ({32{/*csr_en && */mstatus_sel}} & mstatus_reg) |
                        ({32{/*csr_en && */mepc_sel}} & mepc_reg) |
                        ({32{/*csr_en && */mcause_sel}} & mcause_reg);

endmodule
