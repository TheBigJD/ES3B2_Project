//////////////////////////////////////////////////////////////////////////////////
// Module to display colours on RGB LEDs on FPGA
//////////////////////////////////////////////////////////////////////////////////

module ColourLED_Control(

        input [2:0] LED1, LED2,         // Inputs for coin counters player 1 & player 2
        output LED1_R, LED1_G, LED1_B,  // Outputs for RGB LEDs
        output LED2_R, LED2_G, LED2_B
        
    );
    
    // Set R G and B values equal to bits of coin counter player 1
    assign LED1_R = LED1[2];        
    assign LED1_G = LED1[1]; 
    assign LED1_B = LED1[0];
    
     // Set R G and B values equal to bits of coin counter player 2
    assign LED2_R = LED2[2];
    assign LED2_G = LED2[1]; 
    assign LED2_B = LED2[0];    
    
endmodule
