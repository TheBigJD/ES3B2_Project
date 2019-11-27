module VGA_Draw(
    input Master_Clock_In, Reset_N_In,
    input Disp_Ena_In,
    input [9:0] Val_Col_In, Val_Row_In,
    input Up, Down,
    input Left, Right,
	input Fire,
    
//	input Up_2, Down_2,
//  input Left_2, Right_2,
//  input Fire_2,
    
	output reg [7:0] CoinValue = 8'd0,
	
	output reg [3:0] Red   = 4'h0, 
	output reg [3:0] Blue  = 4'h0, 
    output reg [3:0] Green = 4'h0
);

parameter Pixels_Horiz = 640; //Num of Pixels in X axis
parameter Pixels_Vert  = 480; //Num of Pixels in Y axis

parameter EdgeWidth = 0;

reg [9:0] xPosition = 4;
reg [9:0] yPosition = 4;

parameter TankWidth   = 25;

	
reg [3:0] Colour_Counter = 0;
reg [15:0] Clock_Div = 0;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg [9:0] PrevX, PrevY = 10'b0;

reg [1:0] PrevDirection;	
	reg [1:0] Up_Direction = 2'b00;	
reg [1:0] Down_Direction = 2'b01;	
reg [1:0] Left_Direction = 2'b10;	
reg [1:0] Right_Direction = 2'b11;		
	
reg [9:0] xDivPos, yDivPos;	
	
reg [9:0] Tank_xDivPos_1, Tank_yDivPos_1;
reg [9:0] Tank_xDivPos_2, Tank_yDivPos_2;
reg [9:0] Tank_xPos2_Holder, Tank_yPos2_Holder;

reg [0:79] TankArray_1 = 80'b0;
reg [3:0] TankArray_X_1 = 4'b0;
reg TankArray_1_0, TankArray_1_1, TankArray_1_2, TankArray_1_3;

reg [0:79] TankArray_2 = 80'b0;
reg [3:0] TankArray_X_2 = 4'b0;
reg TankArray_2_0, TankArray_2_1, TankArray_2_2, TankArray_2_3;

reg [0:79] TankArray_3 = 80'b0;
reg [3:0] TankArray_X_3 = 4'b0;
reg TankArray_3_0, TankArray_3_1, TankArray_3_2, TankArray_3_3;

reg [0:79] TankArray_4 = 80'b0;
reg [3:0] TankArray_X_4 = 4'b0;
reg TankArray_4_0, TankArray_4_1, TankArray_4_2, TankArray_4_3;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Instantiating colour inputs

wire [11:0] Colour_Data_Background;
//Bottle M4 (.Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In), .yInput(Val_Col_In), .ColourData(Colour_Data_Background));

reg [9:0] Tank_XInput, Tank_YInput = 10'b0;	
wire [11:0] Colour_Data_Tank;
TankImage M5 (.Master_Clock_In(Master_Clock_In), .xInput(Tank_XInput), .yInput(Tank_YInput), .ColourData(Colour_Data_Tank));

//reg [9:0] Brick_XInput, Brick_YInput = 10'b0;	
wire [11:0] Colour_Data_Brick;
Brick_Block M6( .Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In), .yInput(Val_Col_In), .ColourData(Colour_Data_Brick));

reg [9:0] Tank_XInput, Tank_YInput = 10'b0;	
wire [11:0] Colour_Data_Coin;
Mystery_Image M7( .Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In), .yInput(Val_Col_In), .ColourData(Colour_Data_Coin));

	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Bullets?
parameter BulletWidth = 10;
	reg [9:0] Bullet_XInput_1, Bullet_Y_Input_1 = 10'd16;
	reg Bullet_Fired_prev_1 = 1'b0;
	reg Bullet_Fired_1		= 1'b0;
	reg [1:0] Bullet_Dir_1 = 2'b0;
	// Note - these are coded differently to the tank bounding boxes. Tanks are done at each corner, whereas this is done
	//		at the centre only
	
reg [0:79] BulletArray_1 = 80'b0;
reg [3:0] Bulletrray_X_1 = 4'b0;
reg BulletArray_1_0, BulletArray_1_1, BulletArray_1_2, BulletArray_1_3;	

reg [9:0] Bullet_xDivPos_1, Bullet_yDivPos_1 = 10'b0;
	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
reg [0:79] MapArray [0:14];
reg [0:79] MapArrayData_Y = 80'b0;
reg [3:0]  MapArray_X = 4'b0;
reg MapArrayData_X_3, MapArrayData_X_2, MapArrayData_X_1, MapArrayData_X_0;

always @(posedge Master_Clock_In)	
	begin
		if (Reset_N_In == 0)
			begin
                Red   = 4'h0;     
                Blue  = 4'h0;
                Green = 4'h0;
    
                xPosition = 5;
                yPosition = 5;
				
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
            
			end
		else 
			begin

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

////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                            //do not delete this. or i kill you.
                            // this is the bit that takes the x/y coordinates and shuffles them into the 20by15 array
                            // This will give the data for essentially 'What should we do with the tank at this point?
                            // We need to observe points at (x, y), (x+w, y), (x,y+w), (x+w, y+w) and make sure that these points
                            //      that the tank movement is limited if it reaches a point where the tank cant move through.
                            // This will allow the basis for the bullets too. If it hits a breakable block, we can change the reg's
                            //      value at this point to 4'h0, and the tank will behave differently than it would if it was 4'h2.
			    // It's important to remember that dimensions go x ->, y   |  , and such code goes against the intuitive
                            //							      \|/
				
                            xDivPos = ((Val_Row_In[9:5])%20);
                            yDivPos = ((Val_Col_In[9:5])%15);
                            
                            MapArrayData_Y   = MapArray[yDivPos];
                            MapArrayData_X_3 = MapArrayData_Y[4*xDivPos];
                            MapArrayData_X_2 = MapArrayData_Y[4*xDivPos + 1];
                            MapArrayData_X_1 = MapArrayData_Y[4*xDivPos + 2];
                            MapArrayData_X_0 = MapArrayData_Y[4*xDivPos + 3];
                            
                            MapArray_X = {MapArrayData_X_3, MapArrayData_X_2, MapArrayData_X_1, MapArrayData_X_0 };

                            if ((Val_Col_In == Pixels_Vert) & (Val_Row_In == Pixels_Horiz))
                                begin
							// There might be a better way of ordering these values - overwriting might make an impact
							//	on gameplay
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									//Bullet controls
									Bullet_xDivPos_1 = ((Bullet_XInput_1[9:5])%20);
									Bullet_yDivPos_1 = ((Bullet_YInput_1[9:5])%15);

									BulletArrayData_Y   = BulletArray[Bullet_yDivPos_1];
									BulletArrayData_X_3 = BulletArrayData_Y[4*Bullet_xDivPos_1];
									BulletArrayData_X_2 = BulletArrayData_Y[4*Bullet_xDivPos_1 + 1];
									BulletArrayData_X_1 = BulletArrayData_Y[4*Bullet_xDivPos_1 + 2];
									BulletArrayData_X_0 = BulletArrayData_Y[4*Bullet_xDivPos_1 + 3];

									BulletArray_X = {BulletArrayData_X_3, BulletArrayData_X_2, BulletArrayData_X_1, BulletArrayData_X_0 };

									//Rising edge of 'Fire' button input
									Bullet_Fired_prev_1 = Fire;
									
									if ((Bullet_Fired_Prev_1 = 0) & (Fire == 1))
										begin
											Bullet_Fired_1 = 1'b1;
											Bullet_Dir = Prev_Direction;
											
											case (Bullet_Dir)
												Up:		begin
															Bullet_XInput_1 = xPosition + (BulletWidth + 3);
															Bullet_YInput_1 = yPosition - (BulletWidth + 3);
														end
												
												Down:	begin
															Bullet_XInput_1 = xPosition + (BulletWidth + 3);
															Bullet_YInput_1 = yPosition + (BulletWidth + 3) + TankWidth;
														end
												
												Left:	begin
															Bullet_XInput_1 = xPosition - (BulletWidth + 3);
															Bullet_YInput_1 = yPosition + (BulletWidth + 3);
														end
												
												Right:	begin
															Bullet_XInput_1 = xPosition + (BulletWidth + 3) + TankWidth;
															Bullet_YInput_1 = yPosition - (BulletWidth + 3) + TankWidth;
														end
													
										end
									
									if (Bullet_Fired_1 == 1)
										begin
											if ((BulletArray_X == 1) | (BulletArray_X == 2))
												begin
													Bullet_XInput_1 = 0;
													Bullet_YInput_1 = 0;
													Bullet_Fired_1 	= 0;
													
													if (BulletArray_X == 2)
														begin
															MapArray[Bullet_yDivPos_1][Bullet_xDivPos_1:Bullet_xDivPos + 3] = 4'h0;
															//I can guarantee it's not going to like this. Debugging/finding a way around
															//		it will be a fun adventure.
														end
												end
											
											else if ((Bullet_XInput_1 == 0) | (Bullet_YInput_1 == 0) | (Bullet_XInput_1 == xWidth) | (Bullet_YInput_1 == yWidth))
												begin
													Bullet_XInput_1 = 0;
													Bullet_YInput_1 = 0;
													Bullet_Fired_1 	= 0;
												end
											else
												case (Bullet_Dir)
													Up: begin
														Bullet_YInput_1 = Bullet_YInput_1 - 1;
													end
													
													Down: begin
														Bullet_YInput_1 = Bullet_YInput_1 + 1;
													end
													
													Left: begin
														Bullet_XInput_1 = Bullet_XInput_1 - 1;
													end
													
													Right: begin
														Bullet_XInput_1 = Bullet_XInput_1 + 1;
													end
										end
									else
										
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                    // If y-coordinate is at screen limit, move to other side of screen
                                    if (yPosition == EdgeWidth)
                                        yPosition = Pixels_Vert - TankWidth - 1;
                                    else if (yPosition == Pixels_Vert - TankWidth - EdgeWidth)
                                        yPosition = 1;

                                    //if x-coordinate is at screen limit, move to other side of screen
                                    if (xPosition == EdgeWidth)
                                        xPosition = Pixels_Horiz - TankWidth - 1;
                                    else if (xPosition == Pixels_Horiz - TankWidth - EdgeWidth)
                                        xPosition = 1;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////                    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////                    
                                    //Setting Bounding boxes for tank control. Looking for box state at x and y positions
                                    Tank_xDivPos_1 = xPosition[9:5]%20;
                                    Tank_yDivPos_1 = yPosition[9:5]%15;
                                    
									Tank_xPos2_Holder = xPosition + TankWidth;
									Tank_yPos2_Holder = yPosition + TankWidth;
					
                                    Tank_xDivPos_2 = Tank_xPos2_Holder[9:5]%20;
                                    Tank_yDivPos_2 = Tank_yPos2_Holder[9:5]%15;
                                    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////  
                                    //Top left
                                    TankArray_1   = MapArray[Tank_yDivPos_1];// This is the array for the map containing the 'bottom left#' of the tank
                                    TankArray_1_3 = TankArray_1[4*Tank_xDivPos_1  ];// This is bit 3 of [3:0] of the current position's status.
                                    TankArray_1_2 = TankArray_1[4*Tank_xDivPos_1+1];// This is bit 2 of [3:0] of the current position's status.
                                    TankArray_1_1 = TankArray_1[4*Tank_xDivPos_1+2];// This is bit 1 of [3:0] of the current position's status.v
                                    TankArray_1_0 = TankArray_1[4*Tank_xDivPos_1+3];// This is bit 0 of [3:0] of the current position's status.
									
                                    TankArray_X_1 = {TankArray_1_3, TankArray_1_2, TankArray_1_1, TankArray_1_0};
									//This then returns the state of the box for the bottom-left point of the tank, allowing for the game logic to perform functions depending
									//		on the position of the tank.
									
									// The same logic repeats for each corner of the tank.

                                    //Top right
                                    TankArray_2   = MapArray[Tank_yDivPos_1];
                                    TankArray_2_3 = TankArray_2[4*(Tank_xDivPos_2 )  ];
                                    TankArray_2_2 = TankArray_2[4*(Tank_xDivPos_2 )+1];
                                    TankArray_2_1 = TankArray_2[4*(Tank_xDivPos_2 )+2];
                                    TankArray_2_0 = TankArray_2[4*(Tank_xDivPos_2 )+3];
                                    TankArray_X_2 = {TankArray_2_3, TankArray_2_2, TankArray_2_1, TankArray_2_0}; 
									
                                    //Bottom left
                                    TankArray_3   = MapArray[Tank_yDivPos_2 ];
                                    TankArray_3_3 = TankArray_3[4*(Tank_xDivPos_1)  ];
                                    TankArray_3_2 = TankArray_3[4*(Tank_xDivPos_1)+1];
                                    TankArray_3_1 = TankArray_3[4*(Tank_xDivPos_1)+2];
                                    TankArray_3_0 = TankArray_3[4*(Tank_xDivPos_1)+3];
                                    TankArray_X_3 = {TankArray_3_3, TankArray_3_2, TankArray_3_1, TankArray_3_0};   
									
                                    //Bottom right
                                    TankArray_4   = MapArray[Tank_yDivPos_2 ];
                                    TankArray_4_3 = TankArray_4[4*(Tank_xDivPos_2 )  ];
                                    TankArray_4_2 = TankArray_4[4*(Tank_xDivPos_2 )+1];
                                    TankArray_4_1 = TankArray_4[4*(Tank_xDivPos_2 )+2];
                                    TankArray_4_0 = TankArray_4[4*(Tank_xDivPos_2 )+3];
                                    TankArray_X_4 = {TankArray_4_3, TankArray_4_2, TankArray_4_1, TankArray_4_0};   
									
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////     
                                    //If bottom edges are in boundary
									if (((TankArray_X_3 == 1) | (TankArray_X_3 == 2)) & ((TankArray_X_4 == 1) | (TankArray_X_4 == 2)))
                                                yPosition = yPosition - 1;
												
                                    //If left edges are in boundary
								    else if (((TankArray_X_1 == 1) | (TankArray_X_1 == 2)) & ((TankArray_X_3 == 1) | (TankArray_X_3 == 2)))
                                                xPosition = xPosition + 1;
												
                                    //if top edges are in boundary
                                    else if (((TankArray_X_1 == 1) | (TankArray_X_1 == 2)) & ((TankArray_X_2 == 1) | (TankArray_X_2 == 2)))
                                                yPosition = yPosition + 1;
												
                                    // if right edges are in boundary
                                    else if (((TankArray_X_2 == 1) | (TankArray_X_2 == 2)) & ((TankArray_X_4 == 1) | (TankArray_X_4 == 2)))
                                                xPosition = xPosition - 1;                        
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////        
									// if top left is in boundary
									else if ((TankArray_X_1 == 1) | (TankArray_X_1 == 2))
										begin
											yPosition = yPosition + 1;
											xPosition = xPosition + 1;
										end
									// if top right is in boundary	
									else if ((TankArray_X_2 == 1) | (TankArray_X_2 == 2))
										begin
											yPosition = yPosition + 1;
											xPosition = xPosition - 1;
										end	
									// if bottom left is in boundary	
									else if ((TankArray_X_3 == 1) | (TankArray_X_3 == 2))
										begin
											yPosition = yPosition - 1;
											xPosition = xPosition + 1;
										end	
									// if bottom right is in boundary	
									else if ((TankArray_X_4 == 1) | (TankArray_X_4 == 2))
										begin
											yPosition = yPosition - 1;
											xPosition = xPosition - 1;
										end	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////        
									//Coins!
									else if (Tank_Array_X_1 == 3)
										MapArray[Tank_yDivPos_1][Bullet_xDivPos_1:Bullet_xDivPos_1 + 3] = 4'h0;	
										CoinValue = CoinValue + 1;	
												
									else if (Tank_Array_X_2 == 3)
										MapArray[Tank_yDivPos_1][Bullet_xDivPos_2:Bullet_xDivPos_2 + 3] = 4'h0;	
										CoinValue = CoinValue + 1;	
												
									else if (Tank_Array_X_3 == 3)
										MapArray[Tank_yDivPos_2][Bullet_xDivPos_1:Bullet_xDivPos_1 + 3] = 4'h0;	
										CoinValue = CoinValue + 1;
												
									else if (Tank_Array_X_4 == 3)
										MapArray[Tank_yDivPos_2][Bullet_xDivPos_2:Bullet_xDivPos_2 + 3] = 4'h0;	
										CoinValue = CoinValue + 1;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
////////////////////////////////////////////////////////////////////////////////////////////////////////////// 												
									else
										begin
										//Finally getting to the actual tank controls
												 if (Up    == 1)
												yPosition     = yPosition - 1;
												PrevDirection = Up_Direction;
											
											else if (Right == 1)
												xPosition     = xPosition + 1;
												PrevDirection = Right_Direction;
											
											else if (Down  == 1)
												yPosition     = yPosition + 1;
												PrevDirection = Down_Direction;		
											
											else if (Left  == 1)
												xPosition     = xPosition - 1;  
												PrevDirection = Left_Direction;		
											
										end
								end 	    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
                            
                            //within tank bounding box, set image to tank
                            if ((Val_Col_In >= yPosition) & (Val_Col_In <= yPosition + TankWidth) & (Val_Row_In >= xPosition) & (Val_Row_In <= xPosition + TankWidth))
                                begin
									//If moving upwards, image is normal orientation
									if (PrevDirection = Up_Direction;)
										begin
											Tank_XInput = Val_Row_In - xPosition;
											Tank_YInput = Val_Col_In - yPosition;
										end
									// If moving downwards, image is mirrored in x
									else if (PrevDirection = Down_Direction)    
										begin
											Tank_XInput = TankWidth - (Val_Row_In - xPosition)%TankWidth;
											Tank_YInput = TankWidth - (Val_Col_In - yPosition)%TankWidth;
										end
									// if moving left, image is flipped to horizontal direction
									else if (PrevDirection = Left_Direction)    
										begin
											Tank_YInput = Val_Row_In - xPosition;
											Tank_XInput = Val_Col_In - yPosition;
										end
									// if moving right, image is flipped to horizontal, and then mirrored in y 
									else if (PrevDirection = Right_Direction)
										begin
											Tank_YInput = TankWidth - (Val_Row_In - xPosition)%TankWidth;
											Tank_XInput = TankWidth - (Val_Col_In - yPosition)%TankWidth;
										end
            
                                    Red   = Colour_Data_Tank[11:8];
                                    Green = Colour_Data_Tank[7:4];
                                    Blue  = Colour_Data_Tank[3:0];
                                
                                end
                            else
                                //if not within tank bounding box, image is dependant on colour of map.
								//	this will be changed to the colour of specific images dependant on the case	
								//	rather than just flat colours.
                                begin
									
									
									case (MapArray_X)
										4'h0:begin  Red = 4'hE; Green = 4'hE; Blue = 4'hE; end
										
										4'h1:begin 	Red   = Colour_Data_Brick[11:8];
																//Green = Colour_Data_Brick[ 7:4];
													Blue  = Colour_Data_Brick[ 7:4];
																//Blue  = Colour_Data_Brick[ 3:0];
													Green = Colour_Data_Brick[ 3:0];
										     end
											 
										4'h2:begin  Red   = Colour_Data_Brick[11:8];
													Green = Colour_Data_Brick[ 7:4];
													Blue  = Colour_Data_Brick[ 3:0];
											 end	
											 
										4'h3:begin  Red 	= Colour_Data_Coin[11:8];
													Green 	= Colour_Data_Coin[ 7:4];
													Blue 	= Colour_Data_Coin[ 3:0];
											 end 
										
										4'h4:begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
										4'h5:begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
										4'h6:begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
										4'h7:begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
										
										default:begin Red = 4'h8; Green = 4'h8; Blue = 4'h8;end
										
									endcase

            
                                end            
                    end
                
                else
                    begin
                        Red 	= 4'h2;
                        Blue 	= 4'h2;
                        Green 	= 4'h2;
                    end
                end
            end
        end

endmodule
