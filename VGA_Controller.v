//Here we are defining a 640x480 VGA controller. To do this, we need a 25.175MHz clock, and 
//
//
//


module VGA_Control(
	input  Master_Clock_In, Reset_N_In, 	// Main control signals Clock and Reset
	output Sync_Horiz_Out, Sync_Vert_Out,	// Sync signals to signal to display 
	output Disp_Ena_Out, 					// Display Enable - Is current position within display area
	output [9:0] Val_Col_Out, Val_Row_Out 	// 10-bit outputs to store X and Y positions on screen	(need to store 640 and 480 in decimal)
	);

	parameter Pixels_Horiz = 640; //Num of Pixels in X axis
	parameter Pixels_Vert  = 480; //Num of Pixels in Y axis
	
	
	//These values are all in "Pixel Clocks", or number of clock edges needed for the defined VGA image size
	parameter HSync_Front  =  16; //Horizontal Front Porch
	parameter HSync_Sync   =  96; //Horizontal Sync Pulse 
	parameter HSync_Back   =  48; //Horizontal Back Porch
							
	parameter VSync_Front  =  10; //Vertical Front Porch
	parameter VSync_Sync   =   2; //Vertical Sync Pulse
	parameter VSync_Back   =  33; //Vertical Back porch
	
	//Max count for Horizontal timing
	parameter HSync_Max   = Pixels_Horiz + HSync_Front + HSync_Sync + HSync_Back;
	//Mac count for Vertical timing
	parameter VSync_Max   = Pixels_Vert  + VSync_Front + VSync_Sync + VSync_Back;
 	
 	//Counters for vertical and horizontal position
	reg [31:0] HSync_Counter = 0;
	reg [31:0] VSync_Counter = 0;
    
    reg Sync_Horiz = 1'b0;
    reg Sync_Vert = 1'b0;
    reg Disp_Ena = 1'b0;

    
    
	always @(posedge Master_Clock_In)
	begin
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

		if (Reset_N_In == 0) 
			begin
			//Reset all values if reset triggered
			Sync_Horiz = 0;
			Sync_Vert = 0;
			
			Disp_Ena = 0;
			
			HSync_Counter = 0;
			VSync_Counter = 0;			
			end
		else
			begin
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
			//Counter to generate sync pulses
			
				//If reached max Vertical value, reset
				if (VSync_Counter == VSync_Max)
					VSync_Counter = 0;
				else 
				//else, check along horizontal axis
					begin
						//If reached max Horizontal value, reset horizontal and add 1 to vertical (Move to next row)
						if (HSync_Counter == HSync_Max)
							begin
								HSync_Counter = 0;
								VSync_Counter = VSync_Counter + 1;
							end
						else
						//Else, move 1 pixel along horizontal axis
							HSync_Counter = HSync_Counter + 1;
					end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
				//If horizontal value is within Hsync pulse, drop signal low
				if ((HSync_Counter > (Pixels_Horiz + HSync_Front)) & (HSync_Counter <= (Pixels_Horiz + HSync_Front + HSync_Sync)))
					Sync_Horiz = 0;
				//else signal is high
				else
					Sync_Horiz = 1;
				
				//if vertical value is within Vsync pulse, drop signal low
				if ((VSync_Counter > (Pixels_Vert + VSync_Front)) & (VSync_Counter <= (Pixels_Vert + VSync_Front + VSync_Sync)))
					Sync_Vert = 0;	
				//else signal is high
				else
					Sync_Vert = 1;
				
				//If signal is not inside of display area, disable display
				if ((VSync_Counter > Pixels_Vert) | (HSync_Counter > Pixels_Horiz))
					Disp_Ena = 0;
				// else enable
				else
					Disp_Ena = 1;

			end
    end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
    
	assign Sync_Vert_Out 	= Sync_Vert;
	assign Sync_Horiz_Out 	= Sync_Horiz;
	assign Disp_Ena_Out 	= Disp_Ena;
	assign Val_Col_Out 		= VSync_Counter;
	assign Val_Row_Out 		= HSync_Counter;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////		
	
     
endmodule