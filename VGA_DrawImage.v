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

parameter EdgeWidth = 20;

reg [9:0] xPosition = 305; // Value is 1/2(Horiz Pixels + xWidth)
parameter xWidth = 60 ;// random value i thought would be big enoguh to show up. if it's not increase it by a chunk

reg [9:0] yPosition = 225; // Value is 1/2(Vert Pixels + yWidth)
parameter yWidth = 60 ;// same as for xWidth 

reg [3:0] Colour_Counter = 0;
reg [15:0] Clock_Div = 0;

//	reg [0:8] Pix_Red   [0:8][3:0];
//	reg [0:8] Pix_Blue  [0:8][3:0];
//	reg [0:8] Pix_Green [0:8][3:0];
//	reg [3:0] Red, Blue, Green;

wire [11:0] Colour_Data_Background;
wire [11:0] Colour_Data_Tank;

reg [9:0] Tank_XInput, Tank_YInput = 10'b0;	
reg [9:0] PrevX, PrevY = 10'b0;

reg [5:0] xDivPos, yDivPos = 6'b0;

Bottle M4 (.Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In), .yInput(Val_Col_In), .ColourData(Colour_Data_Background));

TankImage M5 (.Master_Clock_In(Master_Clock_In), .xInput(Tank_XInput), .yInput(Tank_YInput), .ColourData(Colour_Data_Tank));

reg [0:79] MapArray [0:14];
reg [0:79] MapArrayData_Y = 80'b0;
reg MapArrayData_X_3, MapArrayData_X_2, MapArrayData_X_1, MapArrayData_X_0;



always @(posedge Master_Clock_In)	
	begin
		if (Reset_N_In == 0)
			begin
			Red   = 4'h0;     
			Blue  = 4'h0;
			Green = 4'h0;

			end
		else 
			begin
			// Need control for map choice here
                MapArray[ 0] = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
                MapArray[ 1] = 80'b0000_0010_0011_0010_0011_0010_0010_0011_0010_0011_0011_0010_0011_0010_0010_0011_0010_0011_0010_0000;
                MapArray[ 2] = 80'b0000_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0000;
                MapArray[ 3] = 80'b0000_0010_0010_0010_0010_0010_0010_0011_0010_0011_0011_0010_0011_0010_0010_0010_0010_0010_0010_0000;
                MapArray[ 4] = 80'b0000_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0000;
                MapArray[ 5] = 80'b0000_0010_0011_0010_0011_0010_0010_0011_0010_0010_0010_0010_0011_0010_0010_0011_0010_0011_0011_0000;
                MapArray[ 6] = 80'b0000_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0000;
                MapArray[ 7] = 80'b0000_0010_0010_0010_0010_0010_0011_0010_0010_0010_0010_0010_0010_0011_0010_0010_0010_0010_0010_0000;
                MapArray[ 8] = 80'b0000_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0000;
                MapArray[ 9] = 80'b0000_0010_0011_0010_0011_0010_0010_0011_0010_0010_0010_0010_0011_0010_0010_0011_0010_0011_0010_0000;
                MapArray[10] = 80'b0000_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0000;
                MapArray[11] = 80'b0000_0010_0010_0010_0010_0010_0010_0011_0010_0011_0011_0010_0011_0010_0010_0010_0010_0010_0010_0000;
                MapArray[12] = 80'b0000_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0000;
                MapArray[13] = 80'b0000_0010_0011_0010_0011_0010_0010_0011_0010_0011_0011_0010_0011_0010_0010_0011_0010_0011_0010_0000;
                MapArray[14] = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;

// MapArray[ 0] = 80'hFFFFFFFFFFFFFFFFFFFF;
// MapArray[ 1] = 80'h82828282828282828282;
// MapArray[ 2] = 80'h77777777777777777777;
// MapArray[ 3] = 80'hE5E5E5E5E5E5E5E5E5E5;
// MapArray[ 4] = 80'hFFFFFFFFFFFFFFFFFFFF;
// MapArray[ 5] = 80'h82828282828282828282;
// MapArray[ 6] = 80'h77777777777777777777;
// MapArray[ 7] = 80'hE5E5E5E5E5E5E5E5E5E5;
// MapArray[ 8] = 80'hFFFFFFFFFFFFFFFFFFFF;
// MapArray[ 9] = 80'h82828282828282828282;
// MapArray[10] = 80'h77777777777777777777;
// MapArray[11] = 80'hE5E5E5E5E5E5E5E5E5E5;
// MapArray[12] = 80'hFFFFFFFFFFFFFFFFFFFF;
// MapArray[13] = 80'h82828282828282828282;
// MapArray[14] = 80'h77777777777777777777;
 
            if (Disp_Ena_In == 0)
                begin
                    Red 	= {4{1'b0}};
                    Blue 	= {4{1'b0}};
                    Green 	= {4{1'b0}};
                end
        
            else
                begin
                    if ((Val_Col_In <= Pixels_Vert) & (Val_Row_In <= Pixels_Horiz)) 
                        begin
                        // Sup my dude
                        // Note I'm putting all of this code within this block because i want it updating at 60Hz, rather than 25MHz...
                        //      There is no button debounce, which might have some effect on the output, but I'm not concerned about that
                        //      for now.
                        if ((Val_Col_In == Pixels_Vert) & (Val_Row_In == Pixels_Horiz))
                        begin
                        if (yPosition == EdgeWidth)
                            //yPosition = Pixels_Vert - yWidth;
                            yPosition = EdgeWidth + 1;
        
                        else if (yPosition == Pixels_Vert - yWidth - EdgeWidth)
                            //yPosition = 0;
                            yPosition = Pixels_Vert - yWidth - EdgeWidth - 1;
        
                        if (xPosition == EdgeWidth)
                            xPosition = EdgeWidth + 1;
                            //xPosition = Pixels_Horiz - xWidth;
        
                        else if (xPosition == Pixels_Horiz - xWidth - EdgeWidth)
                            xPosition = Pixels_Horiz - xWidth - EdgeWidth - 1;
                            //xPosition = 0;
        
                        if (Up == 1)
                            yPosition = yPosition - 1;
                        else if (Down == 1) 
                            yPosition = yPosition + 1;
        
                        if (Left == 1)
                            xPosition = xPosition - 1;
                        else if (Right == 1)
                            xPosition = xPosition + 1;
                        end
        
        
                        if ((Val_Col_In >= yPosition) & (Val_Col_In <= yPosition + yWidth) & (Val_Row_In >= xPosition) & (Val_Row_In <= xPosition + xWidth))
                            begin
                                PrevY = yPosition;
                                PrevX = xPosition;
        
                            if (Down == 1)    
                                begin
                                    Tank_XInput = xWidth - (Val_Row_In - xPosition)%xWidth;
                                    Tank_YInput = yWidth - (Val_Col_In - yPosition)%yWidth;
                                end
        
                            else if (Left == 1)    
                                begin
                                    Tank_YInput = Val_Row_In - xPosition;
                                    Tank_XInput = Val_Col_In - yPosition;
                                end
        
                            else if (Right == 1)
                                begin
                                    Tank_YInput = xWidth - (Val_Row_In - xPosition)%xWidth;
                                    Tank_XInput = yWidth - (Val_Col_In - yPosition)%yWidth;
                                end
        
                            else
                                begin
                                    Tank_XInput = Val_Row_In - xPosition;
                                    Tank_YInput = Val_Col_In - yPosition;
                                end
        
        
                                Red   = Colour_Data_Tank[11:8];
                                Green = Colour_Data_Tank[7:4];
                                Blue  = Colour_Data_Tank[3:0];
                            end
        
                        else
                            begin
        
//                                if ((Val_Row_In <= EdgeWidth) | (Val_Row_In >= Pixels_Horiz - EdgeWidth) | (Val_Col_In <= EdgeWidth) | (Val_Col_In >= Pixels_Vert - EdgeWidth))
//                                    begin
//                                        Red 	= 4'h2;
//                                        Green 	= 4'h2;
//                                        Blue 	= 4'h2;
                                        
                                        
                                           
////                                        Red    = 4'h0;
////                                        Green  = 4'hF;
////                                        Blue   = 4'h0;
//                                    end
//                                else
                                   // begin
                                        
                                        xDivPos = ((Val_Row_In) / 32)%20;
                                        yDivPos = ((Val_Col_In) / 32)%15;
                                        
                                        MapArrayData_Y   = MapArray[yDivPos];
                                        MapArrayData_X_3 = MapArrayData_Y[xDivPos];
                                        MapArrayData_X_2 = MapArrayData_Y[xDivPos + 1];
                                        MapArrayData_X_1 = MapArrayData_Y[xDivPos + 2];
                                        MapArrayData_X_0 = MapArrayData_Y[xDivPos + 3];
                                        
                                        case ({MapArrayData_X_3, MapArrayData_X_2, MapArrayData_X_1, MapArrayData_X_0 })
                                            4'h0:begin  Red = 4'hF; Green = 4'hF; Blue = 4'hF;end
                                            4'h1:begin  Red = 4'h0; Green = 4'h0; Blue = 4'h0;end
                                            4'h2:begin  Red = 4'hF; Green = 4'h0; Blue = 4'h0;end
                                            4'h3:begin  Red = 4'hF; Green = 4'hF; Blue = 4'h0;end 
                                            
                                             default:begin Red = 4'h0; Green = 4'h8; Blue = 4'h0;end
                                        endcase
//                                    end
        
                            end            
                    end
                
                else
                    begin
                        Red 	= 4'h0;
                        Blue 	= 4'h0;
                        Green 	= 4'h0;
                    end
                end
            end
        end

endmodule
