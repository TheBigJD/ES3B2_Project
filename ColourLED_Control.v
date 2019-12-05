
module ColourLED_Control(
        input [2:0] LED1, LED2,
        output LED1_R, LED1_G, LED1_B,
        output LED2_R, LED2_G, LED2_B
    );
    
    assign LED1_R = LED1[2];
    assign LED1_G = LED1[1]; 
    assign LED1_B = LED1[0];
    
    assign LED2_R = LED2[2];
    assign LED2_G = LED2[1]; 
    assign LED2_B = LED2[0];    
    
endmodule
