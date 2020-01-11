//////////////////////////////////////////////////////////////////////////////////
// Module to map a number to seven segment display LEDs
//////////////////////////////////////////////////////////////////////////////////

module sevenseg
(
    input [3:0] num,                       // Input number to display on seven segment display
    output a,b,c,d,e,f,g                   // 7 drive signals, one for each segment on seven seg display
);

reg [6:0] intseg;                          // Setup temp register for conciseness

    always @(num)                          // routine called whenever a new number comes in    
        case(num)
            4'b0000: intseg <= 7'b1111110; // Only have options for numbers 0-9. Default to 0 otherwise.
            4'b0001: intseg <= 7'b0110000;
            4'b0010: intseg <= 7'b1101101;
            4'b0011: intseg <= 7'b1111001;
            4'b0100: intseg <= 7'b0110011;
            4'b0101: intseg <= 7'b1011011;
            4'b0110: intseg <= 7'b1011111; 
            4'b0111: intseg <= 7'b1110000;
            4'b1000: intseg <= 7'b1111111;
            4'b1001: intseg <= 7'b1111011;
            default: intseg <= 7'b1111111;
        endcase

        
    assign {a,b,c,d,e,f,g} = ~intseg;      // Concatenate and invert sevenseg outputs as LEDs on FPGA are active low. 
        
endmodule
