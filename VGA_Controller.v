// Here a 60Hz 640x480 VGA controller is defined. The protocol for this frequency and resolution are derived from 
// standard VGA lookup tables. An input clock of 25.175MHz is required1. The outputs of this module directly drive
// outputs on the FPGA.


module VGA_Control(
	input  Master_Clock_In, Reset_N_In, 	// Main control signals clock and Reset
	output Sync_Horiz_Out, Sync_Vert_Out,	// Sync signals to signal to display 
	output Disp_Ena_Out, 					// Set display to be enabled or not
	output [9:0] Val_Col_Out, Val_Row_Out 	// 10-bit outputs to store X and Y positions on screen	(need to store 640 and 480 in decimal)
	);

	// All constants defined by VGA driver protocol for selected screen frequency & resolution
	parameter Pixels_Horiz = 640; //Num of Pixels in X axis
	parameter Pixels_Vert  = 480; //Num of Pixels in Y axis
	
	parameter HSync_Front  =  16; // Blanking time between end of display and when the end of a row is detected
	parameter HSync_Sync   =  96; // Range where the end of row is detected
	parameter HSync_Back   =  48; // Blanking time between detecting end of row and end of blanking time boundary
							      
	parameter VSync_Front  =  10; // Blanking time between end of display and when the end of a column is detected
	parameter VSync_Sync   =   2; // Range where the end of column is detected
	parameter VSync_Back   =  33; // Blanking time between detecting end of column and end of blanking time boundary
	
	parameter HSync_Max   = Pixels_Horiz + HSync_Front + HSync_Sync + HSync_Back; // Set maximum horizontal position
 	parameter VSync_Max   = Pixels_Vert  + VSync_Front + VSync_Sync + VSync_Back; // Set maximum vertical position
 	
	reg [31:0] HSync_Counter = 0; // Counter to keep track of horizontal (column) position
	reg [31:0] VSync_Counter = 0; // Counter to keep track of vertical (row) positions
    
    reg Sync_Horiz = 1'b0;			//Intialise horizontal sync flag to zero (on)
    reg Sync_Vert = 1'b0;			//Intialise vertical sync flag to zero   (on)
    reg Disp_Ena = 1'b0;			//Intialise display enable to zero		 (off)

    
    
	always @(posedge Master_Clock_In) // Triggered on rising edge
	begin
		if (Reset_N_In == 0) 		// If reset switch enabled, enter switch off display routine
			begin 
				Sync_Horiz = 0;		// Set horizontal flag to zero initially (active low)
				Sync_Vert = 0;		// Set vertical flag to zero initially (active low)
			
				Disp_Ena = 0;		// Disable display
			
				HSync_Counter = 0;	// Reset horizontal counter to zero
				VSync_Counter = 0;	// Reset vertical counter to zero		
			
			end 
		else 
		
		begin		
			if (VSync_Counter == VSync_Max) // If vertical position off screen, reset counter
				VSync_Counter = 0;
			else 
			begin
				if (HSync_Counter == HSync_Max) 		// Otherwise if horizontal position has reached off-screen
				begin
					HSync_Counter = 0;					// Reset horizontal counter
                    VSync_Counter = VSync_Counter + 1;	// And increment vertical counter
                end 
				else
                    HSync_Counter = HSync_Counter + 1;	// If max horizontal position has not reached max, increment counter
			end
			
			// If current position is inside the range where a horizontal sync pulse should be generted, set sync_Horiz to low, otherwise set high.  	
			if ((HSync_Counter > (Pixels_Horiz + HSync_Front)) & (HSync_Counter <= (Pixels_Horiz + HSync_Front + HSync_Sync)))	
				Sync_Horiz = 0;
			else
				Sync_Horiz = 1;
				
			// If current position is inside the range where a vertical sync pulse should be generted, set sync_Vert to low, otherwise set high. 
			if ((VSync_Counter > (Pixels_Vert + VSync_Front)) & (VSync_Counter <= (Pixels_Vert + VSync_Front + VSync_Sync)))
				Sync_Vert = 0;
			else
				Sync_Vert = 1;
				
			// Disables screen if counter exceeds maximum screen & blanking time values
			if ((VSync_Counter > Pixels_Vert) | (HSync_Counter > Pixels_Horiz))		
				Disp_Ena = 0;
			else
				Disp_Ena = 1;

		end
    end
    
	// Set required signals as outputs to module, required for VGA
	assign Sync_Vert_Out = Sync_Vert;
	assign Sync_Horiz_Out = Sync_Horiz;
	assign Disp_Ena_Out = Disp_Ena;
	assign Val_Col_Out = VSync_Counter;
	assign Val_Row_Out = HSync_Counter;
	
     
endmodule