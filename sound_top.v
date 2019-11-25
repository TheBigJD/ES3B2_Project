`timescale 1ns / 1ps


module top(
    input Master_Clock_In,
    input SW4, SW5, SW6,    
    output AUD_PWM   
    );
    
    wire Middle_C;
    wire [2:0] volume;
    
    assign volume[0] = SW4, volume[1] = SW5, volume[2] = SW6;
    
    
    
    gen_test_sound S1(.clk(Master_Clock_In), .Vol(volume), .sound(Middle_C));
    assign Middle_C = AUD_PWM;       
    
    
    
endmodule