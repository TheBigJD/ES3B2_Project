module VGA_Draw(
	input Master_Clock_In, Reset_N_In,
	input Disp_Ena_In,
	input [9:0] Val_Col_In, Val_Row_In,
	input Up, Down,
	input Left, Right,
	output reg [3:0] Red = 4'h0, 
	output reg [3:0] Blue = 4'h0, 
	output reg [3:0] Green = 4'h0
);

	parameter Pixels_Horiz = 640; //Num of Pixels in X axis
	parameter Pixels_Vert  = 480; //Num of Pixels in Y axis
	
	reg [9:0] xPosition = 305; // Value is 1/2(Horiz Pixels + xWidth)
	parameter xWidth = 60;// random value i thought would be big enoguh to show up. if it's not increase it by a chunk
	
	reg [9:0] yPosition = 225; // Value is 1/2(Vert Pixels + yWidth)
	parameter yWidth = 60;// same as for xWidth 
	
	reg [3:0] Colour_Counter = 0;
	reg [15:0] Clock_Div = 0;
	
//	reg [0:8] Pix_Red   [0:8][3:0];
//	reg [0:8] Pix_Blue  [0:8][3:0];
//	reg [0:8] Pix_Green [0:8][3:0];
//	reg [3:0] Red, Blue, Green;
    
	wire [11:0] Colour_Data_Background;
	wire [11:0] Colour_Data_Tank;
    	
	reg [9:0] Tank_XInput, Tank_YInput;	
	
	
	Bottle M4 (.Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In), .yInput(Val_Col_In), .ColourData(Colour_Data_Background));
	
	Tank_VerilogForm Get_Tanked_Bitches (.Master_Clock_In(Master_Clock_In), .xInput(Tank_XInput), .yInput(Tank_YInput), .ColourData(Colour_Data_Tank));
           
	always @(posedge Master_Clock_In)	
	begin
	   if (Reset_N_In == 0) begin
	       Red   = 4'h0;     
	       Blue  = 4'h0;
	       Green = 4'h0;
	       
	   end else begin
            if (Disp_Ena_In == 0)
                begin
                    Red 	= {4{1'b0}};
                    Blue 	= {4{1'b0}};
                    Green 	= {4{1'b0}};
                end
            
            else begin
                if ((Val_Col_In <= Pixels_Vert) & (Val_Row_In <= Pixels_Horiz)) 
                    begin
                        // Sup my dude
                        // Note I'm putting all of this code within this block because i want it updating at 60Hz, rather than 25MHz...
                        //      There is no button debounce, which might have some effect on the output, but I'm not concerned about that
                        //      for now.
                        if ((Val_Col_In == Pixels_Vert) & (Val_Row_In == Pixels_Horiz))
                           begin
                                if (yPosition == 0)
                                    yPosition = Pixels_Vert - yWidth;
                                else if (yPosition == Pixels_Vert - yWidth)
                                    yPosition = 0; 
                                
                                if (xPosition == 0)
                                    xPosition = Pixels_Horiz - xWidth;
                                else if (xPosition == Pixels_Horiz - xWidth)
                                    xPosition = 0;
                                
                                if (Up == 1)
                                    yPosition = yPosition + 1;
                                else if (Down == 1) 
                                    yPosition = yPosition - 1;
                                    
                                if (Left == 1)
                                    xPosition = xPosition - 1;
                                else if (Right == 1)
                                    xPosition = xPosition + 1;
                            end
                                
                    
                        //Box Settings
                        // If we want to make this a more complex shape, such as a hollow rectangle, then this become either an OR statement where we plot
                        //      just the boundary lines, or we plot two rectangles - one the colour of the outline, and one the colour as the background behind it.
                        // Think the first option is more robust, but it the second should work.
                        
                        if ((Val_Col_In >= yPosition) & (Val_Col_In <= yPosition + yWidth) & (Val_Row_In >= xPosition) & (Val_Row_In <= xPosition + xWidth))
                            begin
				Tank_XInput = Val_Col_In - xPosition;
				Tank_YInput = Val_Row_In - yPosition;
				    
				Red   = Colour_Data_Tank[11:8];
				Blue  = Colour_Data_Tank[7:4];
				Green = Colour_Data_Tank[3:0];
                            end
                            
                        else
                            begin
		    					Red    = Colour_Data_Background[11:8];
                                Green  = Colour_Data_Background[7:4];
                                Blue   = Colour_Data_Background[3:0];
                            end            
                    end
                else
                    begin
                        Red 	= {4{1'b0}};
                        Blue 	= {4{1'b0}};
                        Green 	= {4{1'b0}};
                    end
            end
        end
    end

endmodule
