//Here we are defining a 640x480 VGA controller. To do this, we need a 25.175MHz clock, and 
//
//
//



module VGA_Control(
	input  Master_Clock_In, Reset_N_In, 	// Main control signals Clock and Reset
	output Sync_Horiz_Out, Sync_Vert_Out,	// Sync signals to signal to display 
	output Disp_Ena_Out, 
	output [9:0] Val_Col_Out, Val_Row_Out
	
	);

	parameter Pixels_Horiz = 640; //Num of Pixels in X axis
	parameter Pixels_Vert  = 480; //Num of Pixels in Y axis
	
	parameter HSync_Front  =  16; //These values are all in
	parameter HSync_Sync   =  96; // 	Pixel Clocks, or clock 
	parameter HSync_Back   =  48; //	edges of needed clock for the
							      //	defined VGA image size
	parameter VSync_Front  =  10; 
	parameter VSync_Sync   =   2;
	parameter VSync_Back   =  33;
	
	parameter HSync_Max   = Pixels_Horiz + HSync_Front + HSync_Sync + HSync_Back;
 	parameter VSync_Max   = Pixels_Vert  + VSync_Front + VSync_Sync + VSync_Back;
 	
	reg [31:0] HSync_Counter = 0;
	reg [31:0] VSync_Counter = 0;
    
    reg Sync_Horiz = 1'b0;
    reg Sync_Vert = 1'b0;
    reg Disp_Ena = 1'b0;

    
    
	always @(posedge Master_Clock_In)
	begin
		if (Reset_N_In == 0) begin
			Sync_Horiz = 0;
			Sync_Vert = 0;
			
			Disp_Ena = 0;
			
			HSync_Counter = 0;
			VSync_Counter = 0;			
			
		end else begin
		
			if (VSync_Counter == VSync_Max)
				VSync_Counter = 0;
			else begin

                if (HSync_Counter == HSync_Max) begin
                    HSync_Counter = 0;
                    VSync_Counter = VSync_Counter + 1;
                end else
                    HSync_Counter = HSync_Counter + 1;
			end
				
			if ((HSync_Counter > (Pixels_Horiz + HSync_Front)) & (HSync_Counter <= (Pixels_Horiz + HSync_Front + HSync_Sync)))
				Sync_Horiz = 0;
			else
				Sync_Horiz = 1;
				
			if ((VSync_Counter > (Pixels_Vert + VSync_Front)) & (VSync_Counter <= (Pixels_Vert + VSync_Front + VSync_Sync)))
				Sync_Vert = 0;
			else
				Sync_Vert = 1;

			if ((VSync_Counter > Pixels_Vert) | (HSync_Counter > Pixels_Horiz))
				Disp_Ena = 0;
			else
				Disp_Ena = 1;

		end
    end
    
	assign Sync_Vert_Out = Sync_Vert;
	assign Sync_Horiz_Out = Sync_Horiz;
	assign Disp_Ena_Out = Disp_Ena;
	assign Val_Col_Out = VSync_Counter;
	assign Val_Row_Out = HSync_Counter;
	
     
endmodule
