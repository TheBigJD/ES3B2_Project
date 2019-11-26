//////////////////////////////////////////////////////////////////////////////////
//Interface for USB HID Interface for keyboard. Adapted from http://students.iitk.ac.in/eclub/assets/tutorials/keyboard.pdf
//////////////////////////////////////////////////////////////////////////////////


module PS2Receiver(
    input clk, // Onboard clock
    input keyb_clk, // Clock from Keyboard
    input kdata, // Keyboard datacode
    output reg [2:0]p1keys,
    output reg [2:0]p2keys,
    output reg U, 
    output reg D, 
    output reg L, 
    output reg R
    );
    
    reg [7:0] up       = 8'b01110101,
              down     = 8'b01110010, 
              left     = 8'b01101011, 
              right    = 8'b11100000, 
              space    = 8'b00101001, 
              w        = 8'b00011101, 
              a        = 8'b00011100, 
              s        = 8'b00011011, 
              d        = 8'b00100011, 
              tab      = 8'b00001101,
              enter    = 8'b01011010,
              backspa  = 8'b01100110,
              STOP     = 8'hF0;
    
    
    wire keyb_clk_debounced, kdata_debounced; // Output wires from debounce module
    reg [7:0]datacur;
    reg [7:0]dataprev;
    reg [3:0]count;
    reg [15:0]count1 = 0;
    reg [15:0]keydelay = 16'h61A8; //delay of 1ms
    reg flag;                                 // to detect when keycode has been read in
    
    initial begin // Setup initial params to zero
        count<=4'b0000;
        flag<=1'b0;
    end
    
debouncer debounce(  // Debounce both data and clock inputs coming from keyboard
    .clk(clk),
    .In0(keyb_clk),
    .In1(kdata),
    .Out0(keyb_clk_debounced),
    .Out1(kdata_debounced)
);
    
always@(negedge(keyb_clk_debounced)) // Sample on negative edge as per PS/2 interface protocol
begin 
    case(count)
    0:;								// Start bit - Transmission starts when LOW signal detected (line pulled up to VDD)
    1:datacur[0]<=kdata_debounced;  // Next 8 bits on neg clock edges are data bits, load into datacur array
    2:datacur[1]<=kdata_debounced;
    3:datacur[2]<=kdata_debounced;
    4:datacur[3]<=kdata_debounced;
    5:datacur[4]<=kdata_debounced;
    6:datacur[5]<=kdata_debounced;
    7:datacur[6]<=kdata_debounced;
    8:datacur[7]<=kdata_debounced;
    9:flag<=1'b1;					// Parity bit
    10:flag<=1'b0; 					// Stop bit
    
    endcase
        if(count<=9)    			// Loop to ensure datacur is reset after 10 bits
			begin
				count<=count+1;
			end
        else if(count==10) 
			begin 
				count<=0;			
			end
        
end

always @(posedge flag)          // Only start shifting data out after flag has been high and low (indicating a keyboard data has been loaded in)
begin 		            
    
    if(datacur == 8'hf0)  
    begin  //F0 is the 'stop code', indicating when a key has been pressed
            case(dataprev)  //map value from keyboard to smaller 3 bit array
                up      : begin
                            p1keys <= 3'b001; // Set LEDs and set UP to high. Same for remaining directions
                            U <= 1'b1;
                          end
                left    : begin
                            p1keys <= 3'b010;
                            L <= 1'b1;
                        end
                right   : begin
                            p1keys <= 3'b011;
                            R <= 1'b1;
                        end
                down    : begin
                            p1keys <= 3'b100;
                            D <= 1'b1;
                        end
                space   : p1keys <= 3'b101;
                
                    w   : p2keys <= 3'b001; //up is 1
                    a   : p2keys <= 3'b010; // left is 2
                    s   : p2keys <= 3'b011; // right is 3
                    d   : p2keys <= 3'b100; // down is 4
                    tab : p2keys <= 3'b101; // shoot (tab) is 5
                    
                default : begin
                            p1keys <= 3'b000;
                            p2keys <= 3'b000;
                            
                            U <= 1'b0; // Reset directions to zero for no keyboard input
                            D <= 1'b0;
                            L <= 1'b0;
                            R <= 1'b0;                          
                            
                                                       
                          end
            endcase  
            
//            if(count1 == keydelay) // try add 1ms delay after direction change. Doesn't seem to work.
//                count1 = 0;
//            else 
//                count1 = count1 + 1;
          end            
                     
    else
        begin   
            dataprev <= datacur;
            U <= 1'b0;              // Reset directions to zero for no keyboard input
            D <= 1'b0;
            L <= 1'b0;
            R <= 1'b0;   
end
    end
endmodule
