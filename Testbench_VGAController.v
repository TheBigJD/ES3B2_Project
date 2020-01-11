////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ns/100ps

module Testbench();

	reg Clock 					  =  1'b0;
	reg Reset 					  =  1'b0;
	reg Sync_Horiz, Sync_Vert 	  =  1'b0;
	reg Disp_Ena 				  =  1'b0;
	reg [9:0] Val_Col, Val_Row 	  = 10'b0;	
	
	reg [9:0]  Counter_Horiz 	  = 20'd0;
	reg [19:0] Counter_Vert 	  = 20'd0;
	reg Horiz_Rising, Vert_Rising =  1'b0;
	
	
////Instantiating module to test, connecting driven inputs to TB code and outputting to
//		reg values to show outputs.

VGA_Controller UUT 
( 
	.Master_Clock_In(Clock),	 	.Reset_N_In(Reset), 		// Main control signals Clock and Reset
	.Sync_Horiz_Out(Sync_Horiz), 	.Sync_Vert_Out(Sync_Vert), 	// Sync signals to signal to display 
	.Disp_Ena_Out(Disp_Ena), 									// Display Enable - Is current position within display area
	.Val_Col_Out(Val_Col), 			.Val_Row_Out(Val_Row) 		// 10-bit outputs to store X and Y positions on screen	(need to store 640 and 480 in decimal)
);
	
////////////////////////////////////////////////////////////////////////////////////////  
//Clock generator - clock inverts every 40ns to give 25MHz clock
	always
		#40 Clock = ~Clock;

//////////////////////////////////////////////////////////////////////////////////////// 
//initial statement - runs only once at start of code
	initial
		begin
			Clock	= 1'b0; //setting low to begin clock logic
			Reset	= 1'b0;
			#10
			Reset 	= 1'b1;
		end

//////////////////////////////////////////////////////////////////////////////////////// 
//Main logic to get signals monitored 
	always
		begin
			Horiz_Rising = Sync_Horiz;
			Vert_Rising  = Sync_Vert;
			
			Counter_Horiz = Counter_Horiz + 1;
			Counter_Vert  = Counter_Vert  + 1;
			
			if ((Sync_Horiz == 1) & (Horiz_Rising == 0))
				begin
					$display("Horiz Time = ", Counter_Horiz * 1ns);
					Counter_Horiz = 0;
				end
			
			if ((Sync_Vert == 1)  & (Vert_Rising == 0))
				begin
					$display("Vert Time = ", Counter_Vert * 1ns);
					Counter_Vert = 0;
				end
				
			if ((Disp_Ena == 1) & ((Sync_Vert == 0) | (Sync_Horiz == 0))) 
				$display("Disp_Ena timing error");		
			
		end
////////////////////////////////////////////////////////////////////////////////////////
endmodule

