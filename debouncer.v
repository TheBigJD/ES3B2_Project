`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module to debounce keyboard button presses on HID USB port
// 
//////////////////////////////////////////////////////////////////////////////////


module debouncer(
    input clk,
    input In0, // Two inputs for keyboard clock and keyboard data
    input In1,
    output reg Out0, // Two corresponding outputs
    output reg Out1
    );
    
	parameter delay_time = 19; // Specifies number of clock cycles to delay for
    reg [4:0]count0, count1; // Counter reg
    reg Iv0=0,Iv1=0;
    reg out0, out1;
    
always@(posedge(clk))
begin
	if (In0==Iv0) 
		begin
			if (count0==delay_time) // Wait for delay_time cycles for debounce
				begin
					Out0<=In0; // Let output = input
				end
			else count0<=count0+1; 
		end
	else 
		begin
			count0<= "00000"; // Reset counter to 0
			Iv0<=In0; 		// Assign Iv0 to current value so debounce occurs on both pos and neg edges of clock
		end
		
		
	if (In1==Iv1)  // Same routine for second debounce input
		begin
			if (count1==delay_time)
				begin
					Out1<=In1;
				end
			else count1<=count1+1;
		end
	else 
		begin
			count1<= "00000";
			Iv1<=In1;
		end
end
    
endmodule
