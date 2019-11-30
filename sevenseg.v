module sevenseg
(
    input [3:0] num,
    output reg [6:0] Outputs
);

    always @(num)
        case(num)
            4'b0000: Outputs = 7'b1111110;
            4'b0001: Outputs = 7'b0110000;
            4'b0010: Outputs = 7'b1101101;
            4'b0011: Outputs = 7'b1111001;
            4'b0100: Outputs = 7'b0110011;
            4'b0101: Outputs = 7'b1011011;
            4'b0110: Outputs = 7'b1011111; 
            4'b0111: Outputs = 7'b1110000;
            4'b1000: Outputs = 7'b1111111;
            4'b1001: Outputs = 7'b1111011;
            4'b1010: Outputs = 7'b1110111;
            4'b1011: Outputs = 7'b0011111;
            4'b1100: Outputs = 7'b1001110;
            4'b1101: Outputs = 7'b0111101;
            4'b1110: Outputs = 7'b1001111;
            4'b1111: Outputs = 7'b0011100;        
        endcase
endmodule
