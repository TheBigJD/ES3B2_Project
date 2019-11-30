module VGA_Draw(
    input Master_Clock_In, Reset_N_In,
    input Disp_Ena_In,
    input [9:0] Val_Col_In, Val_Row_In,
    input Up, Down, Left, Right, Fire,
    input LevelSwitch_1, LevelSwitch_0,
    input ColourSwitch_1,
    input MoveSpeed_1, MoveSpeed_0,
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

reg [9:0] Tank_xPos = 4;
reg [9:0] Tank_yPos = 4;

parameter TankWidth   = 25;

	
reg [3:0] Colour_Counter = 0;
reg [15:0] Clock_Div = 0;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg [2:0] MoveSpeed = 3'b1;

reg [9:0] PrevX, PrevY = 10'b0;

reg [2:0] PrevDirection     = 3'b00;	
parameter [2:0] Up_Direction      = 3'b100;	
parameter [2:0] Down_Direction    = 3'b001;	
parameter [2:0] Left_Direction    = 3'b010;	
parameter [2:0] Right_Direction   = 3'b011;		
	
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

wire [11:0] Colour_Data_Brick;
Brick_Block M6( .Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In), .yInput(Val_Col_In), .ColourData(Colour_Data_Brick));

wire [11:0] Colour_Data_Nyan;
MysteryImage M7( .Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In), .yInput(Val_Col_In), .ColourData(Colour_Data_Nyan));

wire [11:0] Colour_Data_Solid_Block;
Solid_block M8( .Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In), .yInput(Val_Col_In), .ColourData(Colour_Data_Solid_Block));
	
wire [11:0] Colour_Data_Coin;
Coin_Image M9( .Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In), .yInput(Val_Col_In), .ColourData(Colour_Data_Coin));

	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Bullets?
parameter [3:0] BulletWidth = 4'd10;
reg [9:0] Bullet_XInput_1, Bullet_YInput_1 = 10'd16;
reg Bullet_Fired_prev_1 = 1'b0;
reg Bullet_Fired_prev_2 = 1'b0;
reg Bullet_Fired_1		= 1'b0;
reg [2:0] Bullet_Dir_1  = 2'b000;

reg [5:0] Bullet_ClockDiv = 6'b0;
reg [5:0] Bullet_ClockCounter = 6'd30;
	// Note - these are coded differently to the tank bounding boxes. Tanks are done at each corner, whereas this is done
	//		at the centre only
	
//reg [0:79] BulletArray_1 = 80'b0;
reg [3:0] BulletArray_X = 4'b0;
reg [79:0] BulletArrayData_Y = 80'b0;
reg BulletArrayData_X_0, BulletArrayData_X_1, BulletArrayData_X_2, BulletArrayData_X_3;

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
                    
                Bullet_Fired_1 = 1'b0;
                Bullet_XInput_1 = 10'd16;
                Bullet_YInput_1 = 10'd16;
                Tank_xPos = 10'd5;
                Tank_yPos = 10'd5;
				
				case ({LevelSwitch_1, LevelSwitch_0})
				    1: begin
				        MapArray[ 0] = 80'b0001_0001_0001_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0000_0001_0001_0001;
                        MapArray[ 1] = 80'b0001_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001;
                        MapArray[ 2] = 80'b0001_0011_0001_0001_0001_0011_0010_0010_0011_0000_0000_0011_0010_0010_0011_0001_0001_0001_0011_0001;
                        MapArray[ 3] = 80'b0001_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000_0001;
                        MapArray[ 4] = 80'b0001_0000_0010_0010_0010_0000_0010_0000_0001_0001_0001_0001_0000_0010_0000_0010_0010_0010_0000_0001;
                        MapArray[ 5] = 80'b0001_0000_0000_0000_0000_0000_0010_0000_0000_0010_0010_0000_0000_0010_0000_0000_0000_0000_0000_0001;
                        MapArray[ 6] = 80'b0001_0000_0001_0000_0000_0010_0010_0000_0000_0010_0010_0000_0000_0010_0010_0000_0000_0001_0000_0001;
                        MapArray[ 7] = 80'b0000_0000_0001_0011_0010_0011_0011_0010_0011_0010_0010_0011_0010_0011_0011_0010_0011_0001_0000_0000;
                        MapArray[ 8] = 80'b0001_0000_0001_0000_0000_0010_0010_0000_0000_0010_0010_0000_0000_0010_0010_0000_0000_0001_0000_0001;
                        MapArray[ 9] = 80'b0001_0000_0000_0000_0000_0000_0010_0000_0000_0010_0010_0000_0000_0010_0000_0000_0000_0000_0000_0001;
                        MapArray[10] = 80'b0001_0000_0010_0010_0010_0000_0010_0000_0001_0001_0001_0001_0000_0010_0000_0010_0010_0010_0000_0001;
                        MapArray[11] = 80'b0001_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000_0000_0010_0000_0000_0000_0000_0000_0001;
                        MapArray[12] = 80'b0001_0011_0001_0001_0001_0011_0010_0010_0011_0000_0000_0011_0010_0010_0011_0001_0001_0001_0011_0001;
                        MapArray[13] = 80'b0001_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0001;
                        MapArray[14] = 80'b0001_0001_0001_0000_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0001_0000_0001_0001_0001;
                    end
				    
				    
				    default: begin
                        MapArray[ 0] = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
                        MapArray[ 1] = 80'b0001_0010_0011_0010_0011_0010_0010_0011_0010_0011_0011_0010_0011_0010_0010_0011_0010_0011_0010_0001;
                        MapArray[ 2] = 80'b0001_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0001;
                        MapArray[ 3] = 80'b0001_0010_0010_0010_0010_0010_0010_0011_0010_0011_0011_0010_0011_0010_0010_0010_0010_0010_0010_0001;
                        MapArray[ 4] = 80'b0001_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0001;
                        MapArray[ 5] = 80'b0001_0010_0011_0010_0011_0010_0010_0011_0010_0010_0010_0010_0011_0010_0010_0011_0010_0011_0011_0001;
                        MapArray[ 6] = 80'b0001_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0001;
                        MapArray[ 7] = 80'b0001_0010_0010_0010_0010_0010_0011_0010_0010_0010_0010_0010_0010_0011_0010_0010_0010_0010_0010_0001;
                        MapArray[ 8] = 80'b0001_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0011_0001;
                        MapArray[ 9] = 80'b0001_0010_0011_0010_0011_0010_0010_0011_0010_0010_0010_0010_0011_0010_0010_0011_0010_0011_0010_0001;
                        MapArray[10] = 80'b0001_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0001;
                        MapArray[11] = 80'b0001_0010_0010_0010_0010_0010_0010_0011_0010_0011_0011_0010_0011_0010_0010_0010_0010_0010_0010_0001;
                        MapArray[12] = 80'b0001_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0010_0011_0011_0011_0011_0010_0011_0011_0001;
                        MapArray[13] = 80'b0001_0010_0011_0010_0011_0010_0010_0011_0010_0011_0011_0010_0011_0010_0010_0011_0010_0011_0010_0001;
                        MapArray[14] = 80'b0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000_0000;
                    end
                endcase
			end
		else 
			begin
			// Need control for map choice here
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
                            if ((Val_Col_In == Pixels_Vert) & (Val_Row_In == Pixels_Horiz))
                                begin
							// There might be a better way of ordering these values - overwriting might make an impact
							//	on gameplay
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									//Bullet controls

									//Rising edge of 'Fire' button input
									
                                    Bullet_Fired_prev_2 = Bullet_Fired_prev_1;
                                    Bullet_Fired_prev_1 = Fire;
                                    
                                    if ((Fire == 1'b1) & (Bullet_Fired_prev_2 == 1'b0) & (Bullet_Fired_1 == 0))
                                    //if ((Bullet_Fired_prev_1 == 0) & (Fire == 1))
                                        begin
                                            Bullet_Fired_1 = 1'b1;
                                            Bullet_Dir_1 = PrevDirection;
                                            
                                            case (Bullet_Dir_1)
                                                Up_Direction:
                                                    begin
                                                        Bullet_XInput_1 = Tank_xPos + (BulletWidth + 3);
                                                        Bullet_YInput_1 = Tank_yPos - (BulletWidth + 3);
                                                    end
                                                Down_Direction:
                                                    begin
                                                        Bullet_XInput_1 = Tank_xPos + (BulletWidth + 3);
                                                        Bullet_YInput_1 = Tank_yPos + (BulletWidth + 3) + TankWidth;
                                                    end
                                                Left_Direction:
                                                    begin
                                                        Bullet_XInput_1 = Tank_xPos - (BulletWidth + 3);
                                                        Bullet_YInput_1 = Tank_yPos + (BulletWidth + 3);
                                                    end
                                                Right_Direction:
                                                    begin
                                                        Bullet_XInput_1 = Tank_xPos + (BulletWidth + 3) + TankWidth;
                                                        Bullet_YInput_1 = Tank_yPos - (BulletWidth + 3) + TankWidth;
                                                    end
                                                default: Bullet_Fired_1 = 1'b0;
                                            endcase
                                        end
                                        
                                    else if (Bullet_Fired_1 == 1)
                                        begin
                                            Bullet_xDivPos_1 = (Bullet_XInput_1[9:5])%20;
                                            Bullet_yDivPos_1 = (Bullet_YInput_1[9:5])%15;
                                            
                                            BulletArrayData_Y   = MapArray[Bullet_yDivPos_1];
                                            BulletArrayData_X_3 = BulletArrayData_Y[4* (Bullet_xDivPos_1)];
                                            BulletArrayData_X_2 = BulletArrayData_Y[4* (Bullet_xDivPos_1) + 1];
                                            BulletArrayData_X_1 = BulletArrayData_Y[4* (Bullet_xDivPos_1) + 2];
                                            BulletArrayData_X_0 = BulletArrayData_Y[4* (Bullet_xDivPos_1) + 3];
                                            
                                            BulletArray_X = {BulletArrayData_X_3, BulletArrayData_X_2, BulletArrayData_X_1, BulletArrayData_X_0 };
                                            
                                            if ((Bullet_XInput_1 <= BulletWidth) | (Bullet_YInput_1 <= BulletWidth) | (Bullet_XInput_1 >= Pixels_Horiz - BulletWidth) | (Bullet_YInput_1 >= Pixels_Vert - BulletWidth))
                                                begin
                                                    Bullet_XInput_1 = 10'd16;
                                                    Bullet_YInput_1 = 10'd16;
                                                    Bullet_Fired_1 	=  1'b0;
                                                end
                                            
                                            if ((BulletArray_X == 1) | (BulletArray_X == 2))
                                                begin
                                                    Bullet_XInput_1 = 10'd16;
                                                    Bullet_YInput_1 = 10'd16;
                                                    Bullet_Fired_1 	=  1'b0;
                                    
                                                    if (BulletArray_X == 2)
                                                        begin
                                                            MapArray[Bullet_yDivPos_1][4 * Bullet_xDivPos_1	   ] = 1'b0;	
                                                            MapArray[Bullet_yDivPos_1][4 * Bullet_xDivPos_1 + 1] = 1'b0;
                                                            MapArray[Bullet_yDivPos_1][4 * Bullet_xDivPos_1 + 2] = 1'b0;
                                                            MapArray[Bullet_yDivPos_1][4 * Bullet_xDivPos_1 + 3] = 1'b0;
                                                        end
                                                end
                                                
                                            else
                                                begin
                                                    case (Bullet_Dir_1)
                                                        Up_Direction    : Bullet_YInput_1 = Bullet_YInput_1 - 5;
                                                        Down_Direction  : Bullet_YInput_1 = Bullet_YInput_1 + 5;
                                                        Left_Direction  : Bullet_XInput_1 = Bullet_XInput_1 - 5;
                                                        Right_Direction : Bullet_XInput_1 = Bullet_XInput_1 + 5;
                                                        default: Bullet_Fired_1 = 1'b0;
                                                    endcase	
                                                end
                                        end
                                    else
                                        begin
                                            Bullet_XInput_1 = 10'b0;
                                            Bullet_YInput_1 = 10'b0;
                                            Bullet_Fired_1 	= 1'b0;
                                        end
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                    // If y-coordinate is at screen limit, move to other side of screen
                                    if (Tank_yPos == EdgeWidth)
                                        Tank_yPos = Pixels_Vert - TankWidth - 1;
                                    else if (Tank_yPos == Pixels_Vert - TankWidth - EdgeWidth)
                                        Tank_yPos = 10'b1;
                                        
                                    //if x-coordinate is at screen limit, move to other side of screen
                                    if (Tank_xPos == EdgeWidth)
                                        Tank_xPos = Pixels_Horiz - TankWidth - 1;
                                    else if (Tank_xPos == Pixels_Horiz - TankWidth - EdgeWidth)
                                        Tank_xPos = 10'b1;
////////////////////////////////////////////////////////////////////////////////////////////////////////////////                    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////                    
                                    //Setting Bounding boxes for tank control. Looking for box state at x and y positions
                                    Tank_xDivPos_1 = Tank_xPos[9:5]%20;
                                    Tank_yDivPos_1 = Tank_yPos[9:5]%15;
                                    
									Tank_xPos2_Holder = Tank_xPos + TankWidth;
									Tank_yPos2_Holder = Tank_yPos + TankWidth;
					
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
                                    // If y-coordinate is at screen limit, move to other side of screen
                                    if (Tank_yPos == EdgeWidth)
                                        Tank_yPos = Pixels_Vert - TankWidth - 3;
                                    else if (Tank_yPos == Pixels_Vert - TankWidth - EdgeWidth)
                                        Tank_yPos = 3;

                                    //if x-coordinate is at screen limit, move to other side of screen
                                    if (Tank_xPos == EdgeWidth)
                                        Tank_xPos = Pixels_Horiz - TankWidth - 3;
                                    else if (Tank_xPos == Pixels_Horiz - TankWidth - EdgeWidth)
                                        Tank_xPos = 3;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////       
                                    //If bottom edges are in boundary
									else if (((TankArray_X_3 == 1) | (TankArray_X_3 == 2)) & ((TankArray_X_4 == 1) | (TankArray_X_4 == 2)))
                                                Tank_yPos = Tank_yPos - 1;
												
                                    //If left edges are in boundary
								    else if (((TankArray_X_1 == 1) | (TankArray_X_1 == 2)) & ((TankArray_X_3 == 1) | (TankArray_X_3 == 2)))
                                                Tank_xPos = Tank_xPos + 1;
												
                                    //if top edges are in boundary
                                    else if (((TankArray_X_1 == 1) | (TankArray_X_1 == 2)) & ((TankArray_X_2 == 1) | (TankArray_X_2 == 2)))
                                                Tank_yPos = Tank_yPos + 1;
												
                                    // if right edges are in boundary
                                    else if (((TankArray_X_2 == 1) | (TankArray_X_2 == 2)) & ((TankArray_X_4 == 1) | (TankArray_X_4 == 2)))
                                                Tank_xPos = Tank_xPos - 1;                        
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////        
									// if top left is in boundary
									else if ((TankArray_X_1 == 1) | (TankArray_X_1 == 2))
										begin
											Tank_yPos = Tank_yPos + 1;
											Tank_xPos = Tank_xPos + 1;
										end
									// if top right is in boundary	
									else if ((TankArray_X_2 == 1) | (TankArray_X_2 == 2))
										begin
											Tank_yPos = Tank_yPos + 1;
											Tank_xPos = Tank_xPos - 1;
										end	
									// if bottom left is in boundary	
									else if ((TankArray_X_3 == 1) | (TankArray_X_3 == 2))
										begin
											Tank_yPos = Tank_yPos - 1;
											Tank_xPos = Tank_xPos + 1;
										end	
									// if bottom right is in boundary	
									else if ((TankArray_X_4 == 1) | (TankArray_X_4 == 2))
										begin
											Tank_yPos = Tank_yPos - 1;
											Tank_xPos = Tank_xPos - 1;
										end	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
////////////////////////////////////////////////////////////////////////////////////////////////////////////
					
									else if (TankArray_X_1 == 3)
										begin
											MapArray[Tank_yDivPos_1][4 * Tank_xDivPos_1   ] = 1'b0;	
											MapArray[Tank_yDivPos_1][4 * Tank_xDivPos_1+ 1] = 1'b0;	
											MapArray[Tank_yDivPos_1][4 * Tank_xDivPos_1+ 2] = 1'b0;
											MapArray[Tank_yDivPos_1][4 * Tank_xDivPos_1+ 3] = 1'b0;
											
											CoinValue = CoinValue + 1;	
										end
								
 									else if (TankArray_X_2 == 3)
										begin
											MapArray[Tank_yDivPos_1][4 * Tank_xDivPos_2	 ]   = 1'b0;	
											MapArray[Tank_yDivPos_1][4 * Tank_xDivPos_2 + 1] = 1'b0;
											MapArray[Tank_yDivPos_1][4 * Tank_xDivPos_2 + 2] = 1'b0;
											MapArray[Tank_yDivPos_1][4 * Tank_xDivPos_2 + 3] = 1'b0;
											
											CoinValue = CoinValue + 1;	
										end
								
 									else if (TankArray_X_3 == 3)
										begin
											MapArray[Tank_yDivPos_2][4 * Tank_xDivPos_1   ] = 1'b0;	
											MapArray[Tank_yDivPos_2][4 * Tank_xDivPos_1+ 1] = 1'b0;
											MapArray[Tank_yDivPos_2][4 * Tank_xDivPos_1+ 2] = 1'b0;
											MapArray[Tank_yDivPos_2][4 * Tank_xDivPos_1+ 3] = 1'b0;
											
											CoinValue = CoinValue + 1;
										end
								
 									else if (TankArray_X_4 == 3)
										begin
											MapArray[Tank_yDivPos_2][4 * Tank_xDivPos_2   ] = 1'b0;	
											MapArray[Tank_yDivPos_2][4 * Tank_xDivPos_2+ 1] = 1'b0;
											MapArray[Tank_yDivPos_2][4 * Tank_xDivPos_2+ 2] = 1'b0;
											MapArray[Tank_yDivPos_2][4 * Tank_xDivPos_2+ 3] = 1'b0;
											
											CoinValue = CoinValue + 1;
										end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
										
									else
										begin
											MoveSpeed = 1 + MoveSpeed_0 + MoveSpeed_1 * 2;
										//Finally getting to the actual tank controls
											if (Up    == 1)
											    begin
												    Tank_yPos     = Tank_yPos - MoveSpeed;
												    PrevDirection = Up_Direction;
											    end
											    
											else if (Right == 1)
											    begin
												    Tank_xPos     = Tank_xPos + MoveSpeed;
												    PrevDirection = Right_Direction;
											    end
											
											else if (Down  == 1)
											    begin
												    Tank_yPos     = Tank_yPos + MoveSpeed;
												    PrevDirection = Down_Direction;		
											    end
											
											else if (Left  == 1)
											    begin
												    Tank_xPos     = Tank_xPos - MoveSpeed;  
												    PrevDirection = Left_Direction;		
											    end
										end
								end 	    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
							xDivPos = ((Val_Row_In[9:5])%20);
                            yDivPos = ((Val_Col_In[9:5])%15);
                            
                            MapArrayData_Y   = MapArray[yDivPos];
                            MapArrayData_X_3 = MapArrayData_Y[4*xDivPos];
                            MapArrayData_X_2 = MapArrayData_Y[4*xDivPos + 1];
                            MapArrayData_X_1 = MapArrayData_Y[4*xDivPos + 2];
                            MapArrayData_X_0 = MapArrayData_Y[4*xDivPos + 3];
                            
                            MapArray_X = {MapArrayData_X_3, MapArrayData_X_2, MapArrayData_X_1, MapArrayData_X_0 };
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////    
                            //within tank bounding box, set image to tank
                            if ((Val_Col_In > Tank_yPos) & (Val_Col_In < Tank_yPos + TankWidth) & (Val_Row_In > Tank_xPos) & (Val_Row_In < Tank_xPos + TankWidth))
                                begin
									//If moving upwards, image is normal orientation
									if (PrevDirection == Up_Direction)
										begin
											Tank_XInput = Val_Row_In - Tank_xPos;
											Tank_YInput = Val_Col_In - Tank_yPos;
										end
									// If moving downwards, image is mirrored in x
									else if (PrevDirection == Down_Direction)    
										begin
											Tank_XInput = TankWidth - (Val_Row_In - Tank_xPos)%TankWidth;
											Tank_YInput = TankWidth - (Val_Col_In - Tank_yPos)%TankWidth;
										end
									// if moving left, image is flipped to horizontal direction
									else if (PrevDirection == Left_Direction)    
										begin
											Tank_YInput = Val_Row_In - Tank_xPos;
											Tank_XInput = Val_Col_In - Tank_yPos;
										end
									// if moving right, image is flipped to horizontal, and then mirrored in y 
									else if (PrevDirection == Right_Direction)
										begin
											Tank_YInput = TankWidth - (Val_Row_In - Tank_xPos)%TankWidth;
											Tank_XInput = TankWidth - (Val_Col_In - Tank_yPos)%TankWidth;
										end
            
                                    Red   = Colour_Data_Tank[11:8];
                                    Green = Colour_Data_Tank[7:4];
                                    Blue  = Colour_Data_Tank[3:0];
                                
                                end
							//Bullet Draw
							else if (((Val_Col_In >= Bullet_YInput_1 - BulletWidth/2) & (Val_Col_In <= Bullet_YInput_1 + BulletWidth/2)) & ((Val_Row_In >= Bullet_XInput_1- BulletWidth/2) & (Val_Row_In <= Bullet_XInput_1 + BulletWidth/2)))
								begin
								    if (Bullet_Fired_1 == 1)
                                        begin
                                            Red 	= 4'hF;
                                            Green 	= 4'h0;
                                            Blue 	= 4'h0;
                                        end
                                    else
                                        begin
                                            Red 	= 4'hF;
                                            Green 	= 4'hF;
                                            Blue 	= 4'hF;
                                        end
                                            
								end
							else	
                                //if not within tank bounding box, image is dependant on colour of map.
								//	this will be changed to the colour of specific images dependant on the case	
								//	rather than just flat colours.
                                begin
									case (MapArray_X)
										4'h0:begin  Red   = 4'hF; 
                                                    Green = 4'hF; 
                                                    Blue  = 4'hF; end
										
										4'h1:begin 	Red   = Colour_Data_Solid_Block[11:8];
													Green = Colour_Data_Solid_Block[ 7:4];
													Blue  = Colour_Data_Solid_Block[ 3:0];
										     end
											 
										4'h2:begin  Red   = Colour_Data_Brick[11:8];
													Green = Colour_Data_Brick[ 7:4];
													Blue  = Colour_Data_Brick[ 3:0];
											 end	
											 
										4'h3:begin 
                                                if (ColourSwitch_1 == 0)
                                                    begin
                                                        Red 	= Colour_Data_Coin[11:8];
                                                        Green 	= Colour_Data_Coin[ 7:4];
                                                        Blue 	= Colour_Data_Coin[ 3:0];
                                                    end
                                                else
                                                    begin
                                                        Red 	= Colour_Data_Nyan[11:8];
                                                        Green 	= Colour_Data_Nyan[ 7:4];
                                                        Blue 	= Colour_Data_Nyan[ 3:0];
											         end 
                                            end
										
										4'h4:     begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
										4'h5:     begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
										4'h6:     begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
										4'h7:     begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
										
										default:  begin Red = 4'h8; Green = 4'h8; Blue = 4'h8;end
										
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
