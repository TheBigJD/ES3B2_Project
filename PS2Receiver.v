`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
//Interface for USB HID Interface for keyboard
//////////////////////////////////////////////////////////////////////////////////


module PS2Receiver(
    input clk, // Onboard clock
    input keyb_clk, // Clock from Keyboard
    input kdata, // Keyboard datacode
    output [31:0] keycodeout // Keycode output
    );
    
    
    wire keyb_clk_debounced, kdata_debounced; // Output wires from debounce module
    reg [7:0]datacur;
    reg [7:0]dataprev;
    reg [3:0]count;
    reg [31:0]keycode; // 32 bits keycode
    reg flag; //
    
    initial begin // Setup initial params to zero
        keycode[31:0]<=0'h00000000;
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

//Replace this section with single keycodes, prototype to get it displayed on 4 digit segment display

always @(posedge flag)begin 		// Only start shifting data out after flag has been high and low (indicating a keyboard data has been loaded in)
    if (dataprev!=datacur)
		begin
			keycode[31:24]<=keycode[23:16];
			keycode[23:16]<=keycode[15:8];
			keycode[15:8]<=dataprev;
			keycode[7:0]<=datacur;
			dataprev<=datacur;
		end
end
    
assign keycodeout=keycode; // Ouput 4 previous digits entered on keyboard
    
endmodule
