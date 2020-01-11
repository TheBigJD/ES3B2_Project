//////////////////////////////////////////////////////////////////////////////////
//Interface for USB HID Interface for keyboard. Adapted from http://students.iitk.ac.in/eclub/assets/tutorials/keyboard.pdf
//////////////////////////////////////////////////////////////////////////////////


module PS2Receiver(
    input clk,                          // Onboard clock
    input keyb_clk,                     // Clock from Keyboard
    input kdata,                        // Keyboard datacode
    output reg [4:0]p1keys,             // 5-bit output register for both players (one bit for up, down, left, right, shoot)
    output reg [4:0]p2keys,
    output reg [7:0]debugLEDs           // LEDs for displaying key scan code from keyboard
    );
    
    reg [7:0] up       = 8'b01110101,   // Hard coded binary values for each relevant key
              down     = 8'b01110010, 
              left     = 8'b01101011, 
              right    = 8'b01110100, 
              space    = 8'b00101001, 
              w        = 8'b00011101, 
              a        = 8'b00011100, 
              s        = 8'b00011011, 
              d        = 8'b00100011, 
              tab      = 8'b00001101,
              enter    = 8'b01011010,
              backspa  = 8'b01100110,
              STOP     = 8'hF0;
    

    reg [7:0]datacur = 8'd0;                           // Register to store latest key press   
    reg [3:0]count = 0;                             // Counter to ensure all 10 data bits from keyboard are read 
    reg flag;                                   // Set high when keycode has been read in


always@(negedge(keyb_clk)) // Sample on negative edge as per PS/2 interface protocol
begin 
    case(count)
    0:;								// Start bit - Transmission starts when LOW signal detected (line pulled up to VDD)
    1:datacur[0]<=kdata;  // Next 8 bits on neg clock edges are data bits, load into datacur array
    2:datacur[1]<=kdata;
    3:datacur[2]<=kdata;
    4:datacur[3]<=kdata;
    5:datacur[4]<=kdata;
    6:datacur[5]<=kdata;
    7:datacur[6]<=kdata;
    8:datacur[7]<=kdata;
    9:flag<=1'b1;					// Parity bit - when read set flag high
    10:flag<=1'b0; 					// Stop bit
    
    endcase
        if(count<=9)    			// Loop to ensure datacur is reset after 10 bits

				count<=count+1;

        else if(count==10) 

				count<=0;			
					        
end

always @(posedge flag)          // Only start shifting data out after flag has been high and low (indicating keyboard data has been loaded in)
begin 		            

    debugLEDs = datacur;

    case(datacur)  //map value from keyboard to smaller 3 bit array
        up      : begin
                    p1keys <= 5'b00001; // Set direction bit high, other bits low. Same for remaining controls. This routine only handles one key at a time. 
                    
                  end
        left    : begin
                    p1keys <= 5'b00010;

                end
        right   : begin
                    p1keys <= 5'b00100;

                end
        down    : begin
                    p1keys <= 5'b01000;

                end
        space   : begin
                     p1keys <= 5'b10000;         
 
                end
                
            w   : begin
                    p2keys <= 5'b00001; 

                end
                
            a   : begin
                    p2keys <= 5'b00010; 

                end
                
            d   : begin 
                    p2keys <= 5'b00100; 
                 
                end
                
            s   : begin
                    p2keys <= 5'b01000; 

                    
                end
                
            tab : begin
                    p2keys <= 5'b10000; // shoot (tab) is 5

                end
            
            STOP : begin // Reset directions to zero for when stop key (F0) is reached
                    p1keys <= 5'b00000; 
                    p2keys <= 5'b00000;
                  
            
                   end
        default : begin // Default to zero outputs.
                    p1keys <= 5'b00000;
                    p2keys <= 5'b00000;                                                               
                                               
                  end
                  
       endcase                                     
                      
end
endmodule
