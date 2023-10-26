`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Nitin Krishna Venkatesan
// 
// Create Date: 12/16/2022 12:43:15 AM
// Design Name: 
// Module Name: init_controller
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


module init_controller(
    input clk_i,
    input rst_n,
    input IRQ0, //interrupt
    input bus_ack,
    //input bus_ready, //from external peripheral (slave)
    output reg [15:0] addr_counter,
    output reg load_when_reset, //to mem controller; facilitates selection between fetch and load-store
    output reg [15:0] pram_load_addr //to mem controller's pram addr when load when reset = 1
    
    //output reg pram_loaded //to mem controller
    );
    
    parameter STATE_IDLE = 1'b0;
    parameter STATE_LOAD = 1'b1;
    
    reg state; //seq part
    reg next_state; //comb part
    reg [15:0] addr_counter_next;
    //assign addr_counter = addr_counter_next;


    always @ (posedge clk_i or negedge rst_n)   
    begin
        if(!rst_n)
        begin
           pram_load_addr <= 16'd0; //default conditions
           //pram_loaded <= 1'b0;
        end
        else if (load_when_reset)
        begin
            pram_load_addr <= addr_counter;
            //pram_loaded <= 1'b0;
        end
        else
        begin
            pram_load_addr <= 16'd0;
            //pram_loaded <= 1'b1;
        end
    end
    
    always @ (posedge clk_i or negedge rst_n)   
    begin
        if(!rst_n)
        begin
            state <= STATE_LOAD; //default conditions
            addr_counter <= 16'd0;
        end
        else
        begin
            state <= next_state;
            addr_counter <= addr_counter_next;
        end
    end
    

    always @ *
    begin
        addr_counter_next = addr_counter;
        case(state)
            STATE_IDLE: 
            begin
                load_when_reset = 1'b0;
                addr_counter_next = 16'd0;
             end
            
            STATE_LOAD:
            begin
                //load_when_reset = 1'b1;
                if ((addr_counter_next == 16'h4000) || IRQ0)
                begin
                    next_state = STATE_IDLE;
                    //pram_loaded = 1'b1;
                    load_when_reset = 1'b0;
                end
                else
                begin
                    next_state = STATE_LOAD;
                    //pram_loaded = 1'b0;
                    load_when_reset = 1'b1;
                    if(bus_ack)
                        addr_counter_next = addr_counter + 16'h0004; //last two bits of addr are not considered!
                end
            end
        endcase
    end
endmodule
