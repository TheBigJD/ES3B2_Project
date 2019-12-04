//////////////////////////////////////////////////////////////////////////////////
//Interface for USB HID Interface for keyboard. Adapted from http://students.iitk.ac.in/eclub/assets/tutorials/keyboard.pdf
//////////////////////////////////////////////////////////////////////////////////


module PS2Receiver(
    input clk, // Onboard clock
    input keyb_clk, // Clock from Keyboard
    input kdata, // Keyboard datacode
    output reg [4:0]p1keys,
    output reg [4:0]p2keys,
    output reg [7:0]debugLEDs // TODO rm debug
    );
    
parameter [7:0] up       = 8'b01110101,
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
    
    
    wire keyb_clk_debounced, kdata_debounced; // Output wires from debounce module
    reg [7:0]  datacur = 8'b0;
    reg [7:0]  dataprev = 8'b0;
    reg [3:0]  count = 4'b0;
    reg [15:0] count1 = 16'b0;
    reg [15:0] keydelay = 16'h61A8; //delay of 1ms
    reg flag = 1'b0;                                 // to detect when keycode has been read in
 
  
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
    0: datacur = 8'b0;								// Start bit - Transmission starts when LOW signal detected (line pulled up to VDD)
    1:datacur[0] =kdata_debounced;  // Next 8 bits on neg clock edges are data bits, load into datacur array
    2:datacur[1] =kdata_debounced;
    3:datacur[2] =kdata_debounced;
    4:datacur[3] =kdata_debounced;
    5:datacur[4] =kdata_debounced;
    6:datacur[5] =kdata_debounced;
    7:datacur[6] =kdata_debounced;
    8:datacur[7] =kdata_debounced;
    9:  flag     =1'b1;					// Parity bit
    10: flag     =1'b0; 					// Stop bit
    
    endcase
    
    if(count >= 10)    			// Loop to ensure datacur is reset after 10 bits
        count = 4'b0;
    else
        count = count + 1;			
			        
end
 // TODO currently pressed buttons don't lose value when keys are let go
 //as the routine below is not called (flag only high when keys are pressed)
 //So add condidtion to set p1keys and p2keys to 5'b00000 if no keys pressed
always @(posedge flag)          // Only start shifting data out after flag has been high and low (indicating a keyboard data has been loaded in)
begin 		            

    debugLEDs = datacur;

            case(datacur)  //map value from keyboard to smaller 3 bit array
                up      :  p1keys <= 5'b00001; // Set LEDs and set UP to high. Same for remaining directions
                left    :  p1keys <= 5'b00010;
                right   :  p1keys <= 5'b00100;
                down    :  p1keys <= 5'b01000;
                space   :  p1keys <= 5'b10000;         
                    w   :  p2keys <= 5'b00001; //up is 1
                    a   :  p2keys <= 5'b00010; // left is 2
                    s   :  p2keys <= 5'b00100; // right is 3
                    d   :  p2keys <= 5'b01000; // down is 4
                    tab :  p2keys <= 5'b10000; // shoot (tab) is 5
                            
                    STOP : begin // Reset directions to zero for when stop key is reached
                            p1keys <= 5'b00000; 
                            p2keys <= 5'b00000;
                           end
                           
                default : begin
                            p1keys <= 5'b00000;
                            p2keys <= 5'b00000;                                                               
                                                       
                          end
                          
               endcase                                      
                      
end
endmodule
