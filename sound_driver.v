`timescale 1ns / 1ps


module gen_test_sound(
    input clk,
    input [2:0] Vol,
    output sound
    );    
    
    reg [19:0] no_ticks_in_period = 20'b1011_1011_0001_0100_0000; // ,count up to (766,272/2 dec) reduces freq to 261 Hz, middle C. 
    reg [19:0] initial_on_time = 20'b?0101_1101_1000_1010_0000?;//20'b0000_0101_1101_1000_1010; // 23,946 dec, Set initial ON time (div_val/32) to enable volume control by 5*n using left shift
    
    
    //reg [2:0] duty_cycle_multiplier = 3'd0; // initialise number of spaces to left shift on_time by to 0
    reg [19:0] value_to_add = 20'b0; // initialise extra volume to 0
    reg [19:0] t_on = 20'b0;
    reg [19:0] t_off = 20'b0;
    reg [19:0] count = 20'b0;
    reg out = 1'b0; // Initialise output as zero
    
    always@*
    begin        
        value_to_add <= initial_on_time << Vol; // multiply initial val by 2^n, selected using on board switches
        t_on <= initial_on_time + value_to_add;
        t_off <= no_ticks_in_period - t_on;
    end
    

    
    
    always@(posedge clk) // positive edge triggered
    begin
        if(count > no_ticks_in_period) // reset if max_period reached
            begin
                count = 0;           
                         
            end
        else if (count < t_on)
            begin
                 count <= count + 1'b1;
                out <= 1'b1;  
            end
        else if(count > t_on)
            begin                            
                count <= count + 1'b1;
                out <= 1'b0;                
            end                   
    end
    
    assign sound = out;
    

    
endmodule



    
    
            
                
    
    