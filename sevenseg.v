module sevenseg
(
    input [3:0] num,
    output a,b,c,d,e,f,g
);

reg [6:0] intseg;


    always @(num)
        case(num)
            4'b0000: intseg <= 7'b1111110;
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
           
                
//            4'b1010: intseg <= 7'b1110111; // TODO Remove A-F chars from coin counter
//            4'b1011: intseg <= 7'b0011111;
//            4'b1100: intseg <= 7'b1001110;
//            4'b1101: intseg <= 7'b0111101;
//            4'b1110: intseg <= 7'b1001111;
//            4'b1111: intseg <= 7'b0011100;        
     
        
    assign {a,b,c,d,e,f,g} = ~intseg;
        
endmodule
