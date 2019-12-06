module VGA_Draw(
    input Master_Clock_In, Reset_N_In,
    input Disp_Ena_In,
    input [9:0] Val_Col_In, Val_Row_In,
    
    input Up1, Down1, Left1, Right1, Fire1,
    input Up2, Down2, Left2, Right2, Fire2,
    
    input LevelSwitch_2, LevelSwitch_1, LevelSwitch_0,
    input ColourSwitch_1,
    input MoveSpeed_1, MoveSpeed_0,
    
	output reg [7:0] CoinValue_1 = 8'd0,
	output reg [7:0] CoinValue_2 = 8'd0,
	
	output reg [7:0] P1_Deaths = 8'd0,
	output reg [7:0] P2_Deaths = 8'd0,
	
	output reg [3:0] Red   = 4'h0, 
	output reg [3:0] Blue  = 4'h0, 
    output reg [3:0] Green = 4'h0
);

parameter Pixels_Horiz = 640; //Num of Pixels in X axis
parameter Pixels_Vert  = 480; //Num of Pixels in Y axis

parameter EdgeWidth = 0;
parameter [2:0] Up_Direction      = 3'b100;	
parameter [2:0] Down_Direction    = 3'b001;	
parameter [2:0] Left_Direction    = 3'b010;	
parameter [2:0] Right_Direction   = 3'b011;	

parameter TankWidth   = 24;

reg [2:0] MoveSpeed = 3'b1;
	
parameter [3:0] BulletWidth = 4'd10;

reg [7:0] Max_Deaths = 8'd5;

reg  Reset_Val = 0;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
reg [5:0] Dead_Counter = 6'd60;


reg [2:0] PrevDirection_1     = 3'b000;	
reg [2:0] PrevDirection_2     = 3'b000;	

reg [9:0] Tank1_xPos = 32 + 4;
reg [9:0] Tank1_yPos = 32 + 4;	
	
reg [9:0] Tank1_xDivPos_1, Tank1_yDivPos_1;
reg [9:0] Tank1_xDivPos_2, Tank1_yDivPos_2;
reg [9:0] Tank1_xPos2_Holder, Tank1_yPos2_Holder;

reg [0:79] Tank1Array_1 = 80'b0;
reg [3:0]  Tank1Array_X_1 = 4'b0;
reg Tank1Array_1_0, Tank1Array_1_1, Tank1Array_1_2, Tank1Array_1_3;

reg [0:79] Tank1Array_2 = 80'b0;
reg [3:0] Tank1Array_X_2 = 4'b0;
reg Tank1Array_2_0, Tank1Array_2_1, Tank1Array_2_2, Tank1Array_2_3;

reg [0:79] Tank1Array_3 = 80'b0;
reg [3:0] Tank1Array_X_3 = 4'b0;
reg Tank1Array_3_0, Tank1Array_3_1, Tank1Array_3_2, Tank1Array_3_3;

reg [0:79] Tank1Array_4 = 80'b0;
reg [3:0] Tank1Array_X_4 = 4'b0;
reg Tank1Array_4_0, Tank1Array_4_1, Tank1Array_4_2, Tank1Array_4_3;

reg Tank1_Dead = 1'b0;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

reg [9:0] Tank2_xPos = 640 - 25 - 4 - 32;
reg [9:0] Tank2_yPos = 480 - 25 - 4 - 32;	
	
reg [9:0] Tank2_xDivPos_1, Tank2_yDivPos_1;
reg [9:0] Tank2_xDivPos_2, Tank2_yDivPos_2;
reg [9:0] Tank2_xPos2_Holder, Tank2_yPos2_Holder;

reg [0:79] Tank2Array_1 = 80'b0;
reg [3:0]  Tank2Array_X_1 = 4'b0;
reg Tank2Array_1_0, Tank2Array_1_1, Tank2Array_1_2, Tank2Array_1_3;

reg [0:79] Tank2Array_2 = 80'b0;
reg [3:0] Tank2Array_X_2 = 4'b0;
reg Tank2Array_2_0, Tank2Array_2_1, Tank2Array_2_2, Tank2Array_2_3;

reg [0:79] Tank2Array_3 = 80'b0;
reg [3:0] Tank2Array_X_3 = 4'b0;
reg Tank2Array_3_0, Tank2Array_3_1, Tank2Array_3_2, Tank2Array_3_3;

reg [0:79] Tank2Array_4 = 80'b0;
reg [3:0] Tank2Array_X_4 = 4'b0;
reg Tank2Array_4_0, Tank2Array_4_1, Tank2Array_4_2, Tank2Array_4_3;

reg Tank2_Dead = 1'b0;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Instantiating colour inputs

wire [11:0] Colour_Data_Background;
//Bottle M4 (.Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In), .yInput(Val_Col_In), .ColourData(Colour_Data_Background));

reg [9:0] Tank1_XInput, Tank1_YInput = 10'b0;	
wire [11:0] Colour_Data_Tank1;
TankImage M5 (.Master_Clock_In(Master_Clock_In), .xInput(Tank1_XInput), .yInput(Tank1_YInput), .ColourData(Colour_Data_Tank1));

wire [11:0] Colour_Data_Explosion1;
Explosion M13 (.Master_Clock_In(Master_Clock_In), .xInput(Tank1_XInput), .yInput(Tank1_YInput), .ColourData(Colour_Data_Explosion1));


reg [9:0] Tank2_XInput, Tank2_YInput = 10'b0;	
wire [11:0] Colour_Data_Tank2;
TankImage M11 (.Master_Clock_In(Master_Clock_In), .xInput(Tank2_XInput), .yInput(Tank2_YInput), .ColourData(Colour_Data_Tank2));

//wire [11:0] Colour_Data_Explosion2;
//Explosion M14 (.Master_Clock_In(Master_Clock_In), .xInput(Tank2_XInput), .yInput(Tank2_YInput), .ColourData(Colour_Data_Explosion2));

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

reg [9:0] Bullet1_XInput, Bullet1_YInput = 10'd16;
reg Bullet1_Fired_prev_1 = 1'b0;
reg Bullet1_Fired_prev_2 = 1'b0;
reg Bullet1_Fired		 = 1'b0;
reg [2:0] Bullet1_Dir    = 3'b000;

reg [5:0] Bullet1_ClockDiv = 6'b0;
reg [5:0] Bullet1_ClockCounter = 6'd30;
	// Note - these are coded differently to the tank bounding boxes. Tanks are done at each corner, whereas this is done
	//		at the centre only
	
reg [3:0] Bullet1Array_X = 4'b0;
reg [0:79] Bullet1ArrayData_Y = 80'b0;
reg Bullet1ArrayData_X_0, Bullet1ArrayData_X_1, Bullet1ArrayData_X_2, Bullet1ArrayData_X_3;

reg [9:0] Bullet1_xDivPos, Bullet1_yDivPos = 10'b0;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Bullets?

reg [9:0] Bullet2_XInput, Bullet2_YInput = 10'd16;
reg Bullet2_Fired_prev_1 = 1'b0;
reg Bullet2_Fired_prev_2 = 1'b0;
reg Bullet2_Fired		 = 1'b0;
reg [2:0] Bullet2_Dir    = 3'b000;

reg [5:0] Bullet2_ClockDiv = 6'b0;
reg [5:0] Bullet2_ClockCounter = 6'd30;
	// Note - these are coded differently to the tank bounding boxes. Tanks are done at each corner, whereas this is done
	//		at the centre only
	
reg [3:0] Bullet2Array_X = 4'b0;
reg [0:79] Bullet2ArrayData_Y = 80'b0;
reg Bullet2ArrayData_X_0, Bullet2ArrayData_X_1, Bullet2ArrayData_X_2, Bullet2ArrayData_X_3;

reg [9:0] Bullet2_xDivPos, Bullet2_yDivPos = 10'b0;

reg [9:0] xDivPos, yDivPos = 10'b0;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
reg [0:79] MapArray [0:14];
reg [0:79] MapArrayData_Y = 80'b0;
reg [3:0]  MapArray_X = 4'b0;
reg MapArrayData_X_3, MapArrayData_X_2, MapArrayData_X_1, MapArrayData_X_0;



always @(posedge Master_Clock_In)	
	begin
		if ((Reset_N_In == 0) | (Reset_Val == 1))
			begin
                
                Reset_Val = 1'b0;
			    P1_Deaths = 8'b0;
			    P2_Deaths = 8'b0;
			    
			    CoinValue_1 = 8'b0;
			    CoinValue_2 = 8'b0;
			    
                Red   = 4'h0;     
                Blue  = 4'h0;
                Green = 4'h0;
                    
                Bullet1_Fired = 1'b0;
                Bullet1_XInput = 10'd16;
                Bullet1_YInput = 10'd16;
                Tank1_xPos = 32 + 4;
                Tank1_yPos = 32 + 4;
				            
				Bullet2_Fired 	    =  1'b0;
                Bullet2_XInput 	    = 10'd16;
                Bullet2_YInput   	= 10'd16;
                Tank2_xPos 			= 579;
                Tank2_yPos 			= 419;
				
				
				case ({LevelSwitch_2, LevelSwitch_1, LevelSwitch_0})
				
				    6: begin
                            MapArray[ 0] = 80'h33333333333333333333;
                            MapArray[ 1] = 80'h31112221131132221113;
                            MapArray[ 2] = 80'h33132321331312221313;
                            MapArray[ 3] = 80'h31132221331132321313;
                            MapArray[ 4] = 80'h33333333333333333333;
                            MapArray[ 5] = 80'h33333111322231133333;
                            MapArray[ 6] = 80'h33333111323231313333;
                            MapArray[ 7] = 80'h33333131323231133333;
                            MapArray[ 8] = 80'h33333333333333333333;
                            MapArray[ 9] = 80'h33113222311132223333;
                            MapArray[10] = 80'h33133233313132333333;
                            MapArray[11] = 80'h33133222313132223333;
                            MapArray[12] = 80'h33133233313133323333;
                            MapArray[13] = 80'h33133222313132223333;
                            MapArray[14] = 80'h33333333333333333333;
				    
                        end
				        
				    5: begin
				        
				            MapArray[ 0] = 80'h11111111011111011111;
                            MapArray[ 1] = 80'h13300222022222002031;
                            MapArray[ 2] = 80'h00000000000000002000;
                            MapArray[ 3] = 80'h10022200121033011101;
                            MapArray[ 4] = 80'h13023301131100000001;
                            MapArray[ 5] = 80'h13013302333202122211;
                            MapArray[ 6] = 80'h13011102333001133311;
                            MapArray[ 7] = 80'h10000001131102122211;
                            MapArray[ 8] = 80'h00100300121200033330;
                            MapArray[ 9] = 80'h10131010233202211121;
                            MapArray[10] = 80'h10131033233201233321;
                            MapArray[11] = 80'h10010033232102211121;
                            MapArray[12] = 80'h13000110122000000001;
                            MapArray[13] = 80'h13300000000030033331;
                            MapArray[14] = 80'h11111111011111011111;

				       end
				    4: begin
				    
				        MapArray[ 0] = 80'h11111111111111111111;
                        MapArray[ 1] = 80'h13300013100000003331;
                        MapArray[ 2] = 80'h13320012100122122121;
                        MapArray[ 3] = 80'h10010012100233233201;
                        MapArray[ 4] = 80'h10020003000233233201;
                        MapArray[ 5] = 80'h10010012100233122101;
                        MapArray[ 6] = 80'h00023323233122133200;
                        MapArray[ 7] = 80'h00010012100233233200;
                        MapArray[ 8] = 80'h10020003000233122101;
                        MapArray[ 9] = 80'h10010003000122100221;
                        MapArray[10] = 80'h10000121210233200001;
                        MapArray[11] = 80'h12200000000200233201;
                        MapArray[12] = 80'h13200011100200200131;
                        MapArray[13] = 80'h10200033300000000331;
                        MapArray[14] = 80'h11111111111111111111;                        
				    
				       end
				       
					3: begin
						MapArray[ 0] = 80'h11111111100111111111;
						MapArray[ 1] = 80'h13000000000000000031;
						MapArray[ 2] = 80'h00222202222220222200;
						MapArray[ 3] = 80'h00230000000000003200;
						MapArray[ 4] = 80'h10201102222220110201;
						MapArray[ 5] = 80'h10201302000020310201;
						MapArray[ 6] = 80'h10000000000000000001;
						MapArray[ 7] = 80'h10222222233222222201;
						MapArray[ 8] = 80'h10000000000000000001;
						MapArray[ 9] = 80'h10201302000020310201;
						MapArray[10] = 80'h10201102222220110201;
						MapArray[11] = 80'h00230000000000003200;
						MapArray[12] = 80'h00222202222220222200;
						MapArray[13] = 80'h13000000000000000031;
						MapArray[14] = 80'h11111111100111111111;
						end
						
					2: begin // Pacman level
						MapArray[ 0] = 80'h11111111111111111111;
						MapArray[ 1] = 80'h13331333333333313331;
						MapArray[ 2] = 80'h13131331133113313131;
						MapArray[ 3] = 80'h13133333333333333131;
						MapArray[ 4] = 80'h13113113133131131131;
						MapArray[ 5] = 80'h13313333133133331331;
						MapArray[ 6] = 80'h03311313333331311330;
						MapArray[ 7] = 80'h03333311111111333330;
						MapArray[ 8] = 80'h13313333333333331331;
						MapArray[ 9] = 80'h11311131111113111311;
						MapArray[10] = 80'h13333133333333133331;
						MapArray[11] = 80'h13113331111113331131;
						MapArray[12] = 80'h13113131111113131131;
						MapArray[13] = 80'h13333133333333133331;
						MapArray[14] = 80'h11111111111111111111;
					end
					
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
                        MapArray[ 1] = 80'b0000_0000_0011_0010_0011_0010_0010_0011_0010_0011_0011_0010_0011_0010_0010_0011_0010_0011_0000_0000;
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
                        MapArray[13] = 80'b0000_0000_0011_0010_0011_0010_0010_0011_0010_0011_0011_0010_0011_0010_0010_0011_0010_0011_0000_0000;
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
									
                                    Bullet1_Fired_prev_2 = Bullet1_Fired_prev_1;
                                    Bullet1_Fired_prev_1 = Fire1;
                                    
                                    Bullet2_Fired_prev_2 = Bullet2_Fired_prev_1;
                                    Bullet2_Fired_prev_1 = Fire2;
                                    
                                    if ((Fire1 == 1'b1) & (Bullet1_Fired_prev_2 == 1'b0) & (Bullet1_Fired == 0))
                                    //if ((Bullet_Fired_prev_1 == 0) & (Fire == 1))
                                        begin
                                            Bullet1_Fired = 1'b1;
                                            Bullet1_Dir = PrevDirection_1;
                                            
                                            case (Bullet1_Dir)
                                                Up_Direction:
                                                    begin
                                                        Bullet1_XInput = Tank1_xPos + (BulletWidth + 3);
                                                        Bullet1_YInput = Tank1_yPos - (BulletWidth + 3);
                                                    end
                                                    
                                                Down_Direction:
                                                    begin
                                                        Bullet1_XInput = Tank1_xPos + (BulletWidth + 3);
                                                        Bullet1_YInput = Tank1_yPos + (BulletWidth + 3) + TankWidth;
                                                    end
                                                    
                                                Left_Direction:
                                                    begin
                                                        Bullet1_XInput = Tank1_xPos - (BulletWidth + 3);
                                                        Bullet1_YInput = Tank1_yPos + (BulletWidth + 3);
                                                    end
                                                    
                                                Right_Direction:
                                                    begin
                                                        Bullet1_XInput = Tank1_xPos + (BulletWidth + 3) + TankWidth;
                                                        Bullet1_YInput = Tank1_yPos - (BulletWidth + 3) + TankWidth;
                                                    end
                                                    
                                                default: Bullet1_Fired = 1'b0;
                                            endcase
                                        end
                                        
                                    else if (Bullet1_Fired == 1)
                                        begin
                                            Bullet1_xDivPos = (Bullet1_XInput[9:5])%20;
                                            Bullet1_yDivPos = (Bullet1_YInput[9:5])%15;
                                            
                                            Bullet1ArrayData_Y   = MapArray[Bullet1_yDivPos];
                                            Bullet1ArrayData_X_3 = Bullet1ArrayData_Y[4* (Bullet1_xDivPos)];
                                            Bullet1ArrayData_X_2 = Bullet1ArrayData_Y[4* (Bullet1_xDivPos) + 1];
                                            Bullet1ArrayData_X_1 = Bullet1ArrayData_Y[4* (Bullet1_xDivPos) + 2];
                                            Bullet1ArrayData_X_0 = Bullet1ArrayData_Y[4* (Bullet1_xDivPos) + 3];
                                            
                                            Bullet1Array_X = {Bullet1ArrayData_X_3, Bullet1ArrayData_X_2, Bullet1ArrayData_X_1, Bullet1ArrayData_X_0 };
                                            
                                            if ((Bullet1_XInput <= BulletWidth) | (Bullet1_YInput <= BulletWidth) | (Bullet1_XInput >= Pixels_Horiz - BulletWidth) | (Bullet1_YInput >= Pixels_Vert - BulletWidth))
                                                begin
                                                    Bullet1_XInput = 10'd16;
                                                    Bullet1_YInput = 10'd16;
                                                    Bullet1_Fired 	=  1'b0;
                                                end
                                            
                                            else if ((Bullet1Array_X == 1) | (Bullet1Array_X == 2))
                                                begin
                                                    Bullet1_XInput = 10'd16;
                                                    Bullet1_YInput = 10'd16;
                                                    Bullet1_Fired 	=  1'b0;
                                    
                                                    if (Bullet1Array_X == 2)
                                                        begin
                                                            MapArray[Bullet1_yDivPos][4 * Bullet1_xDivPos	   ] = 1'b0;	
                                                            MapArray[Bullet1_yDivPos][4 * Bullet1_xDivPos + 1] = 1'b0;
                                                            MapArray[Bullet1_yDivPos][4 * Bullet1_xDivPos + 2] = 1'b0;
                                                            MapArray[Bullet1_yDivPos][4 * Bullet1_xDivPos + 3] = 1'b0;
                                                        end
                                                end
                                        	
                                            else if (((Bullet1_XInput >= Tank2_xPos) & (Bullet1_XInput <= Tank2_xPos + TankWidth))
                                                    &((Bullet1_YInput >= Tank2_yPos) & (Bullet1_YInput <= Tank2_yPos + TankWidth)))
                                                begin
                                                   Tank2_Dead = 1'b1;
                                                   P2_Deaths = P2_Deaths + 1;

                                                   Bullet1_XInput = 10'd16;
                                                   Bullet1_YInput = 10'd16;
                                                   Bullet1_Fired  =  1'b0;
                                                end
                                                
                                        	else if ((Bullet1Array_X == 3) | (Bullet1Array_X == 0))
                                        		begin    		                                            
                                                    case (Bullet1_Dir)
                                                        Up_Direction    : Bullet1_YInput = Bullet1_YInput - 5;
                                                        Down_Direction  : Bullet1_YInput = Bullet1_YInput + 5;
                                                        Left_Direction  : Bullet1_XInput = Bullet1_XInput - 5;
                                                        Right_Direction : Bullet1_XInput = Bullet1_XInput + 5;
                                                        default: Bullet1_Fired = 1'b0;
                                                    endcase		
                                                end
                                                
                                            else
                                                begin
													Bullet1_YInput = 10'd16;
													Bullet1_XInput = 10'd16;
													Bullet1_Fired = 1'b0;
                                                end
                                        end
                                    else
                                        begin
                                            Bullet1_XInput = 10'b0;
                                            Bullet1_YInput = 10'b0;
                                            Bullet1_Fired 	= 1'b0;
                                        end
                                        
                                        
                                    if ((Fire2 == 1'b1) & (Bullet2_Fired_prev_2 == 1'b0) & (Bullet2_Fired == 0))
                                    //if ((Bullet_Fired_prev_1 == 0) & (Fire == 1))
                                        begin
                                            Bullet2_Fired = 1'b1;
                                            Bullet2_Dir   = PrevDirection_2;
                                            
                                            case (Bullet2_Dir)
                                                Up_Direction:
                                                    begin
                                                        Bullet2_XInput = Tank2_xPos + (BulletWidth + 3);
                                                        Bullet2_YInput = Tank2_yPos - (BulletWidth + 3);
                                                    end
                                                    
                                                Down_Direction:
                                                    begin
                                                        Bullet2_XInput = Tank2_xPos + (BulletWidth + 3);
                                                        Bullet2_YInput = Tank2_yPos + (BulletWidth + 3) + TankWidth;
                                                    end
                                                    
                                                Left_Direction:
                                                    begin
                                                        Bullet2_XInput = Tank2_xPos - (BulletWidth + 3);
                                                        Bullet2_YInput = Tank2_yPos + (BulletWidth + 3);
                                                    end
                                                    
                                                Right_Direction:
                                                    begin
                                                        Bullet2_XInput = Tank2_xPos + (BulletWidth + 3) + TankWidth;
                                                        Bullet2_YInput = Tank2_yPos - (BulletWidth + 3) + TankWidth;
                                                    end
                                                    
                                                default: Bullet2_Fired = 1'b0;
                                            endcase
                                        end
                                        
                                    else if (Bullet2_Fired == 1)
                                        begin
                                            Bullet2_xDivPos = (Bullet2_XInput[9:5])%20;
                                            Bullet2_yDivPos = (Bullet2_YInput[9:5])%15;
                                            
                                            Bullet2ArrayData_Y   = MapArray[Bullet2_yDivPos];
                                            Bullet2ArrayData_X_3 = Bullet2ArrayData_Y[4* (Bullet2_xDivPos)];
                                            Bullet2ArrayData_X_2 = Bullet2ArrayData_Y[4* (Bullet2_xDivPos) + 1];
                                            Bullet2ArrayData_X_1 = Bullet2ArrayData_Y[4* (Bullet2_xDivPos) + 2];
                                            Bullet2ArrayData_X_0 = Bullet2ArrayData_Y[4* (Bullet2_xDivPos) + 3];
                                            
                                            Bullet2Array_X = {Bullet2ArrayData_X_3, Bullet2ArrayData_X_2, Bullet2ArrayData_X_1, Bullet2ArrayData_X_0 };
                                            
                                            if ((Bullet2_XInput <= BulletWidth) | (Bullet2_YInput <= BulletWidth) | (Bullet2_XInput >= Pixels_Horiz - BulletWidth) | (Bullet2_YInput >= Pixels_Vert - BulletWidth))
                                                begin
                                                    Bullet2_XInput = 10'd16;
                                                    Bullet2_YInput = 10'd16;
                                                    Bullet2_Fired  =  1'b0;
                                                end
                                            
                                            else if ((Bullet2Array_X == 1) | (Bullet2Array_X == 2))
                                                begin
                                                    Bullet2_XInput = 10'd16;
                                                    Bullet2_YInput = 10'd16;
                                                    Bullet2_Fired  =  1'b0;
                                    
                                                    if (Bullet2Array_X == 2)
                                                        begin
                                                            MapArray[Bullet2_yDivPos][4 * Bullet2_xDivPos	 ] = 1'b0;	
                                                            MapArray[Bullet2_yDivPos][4 * Bullet2_xDivPos + 1] = 1'b0;
                                                            MapArray[Bullet2_yDivPos][4 * Bullet2_xDivPos + 2] = 1'b0;
                                                            MapArray[Bullet2_yDivPos][4 * Bullet2_xDivPos + 3] = 1'b0;
                                                        end
                                                end
                                            else if (((Bullet2_XInput >= Tank1_xPos) & (Bullet2_XInput <= Tank1_xPos + TankWidth))
                                        	        &((Bullet2_YInput >= Tank1_yPos) & (Bullet2_YInput <= Tank1_yPos + TankWidth)))
                                                begin
                                        	       Tank1_Dead = 1'b1;
                                        	       P1_Deaths = P1_Deaths + 1;

                                        	       Bullet2_XInput = 10'd16;
                                                   Bullet2_YInput = 10'd16;
                                                   Bullet2_Fired  =  1'b0;
                                        	    end

                                        	else if ((Bullet2Array_X == 3) | (Bullet2Array_X == 0))
                                        		begin    		                                            
                                                      case (Bullet2_Dir)
                                                        Up_Direction    : Bullet2_YInput = Bullet2_YInput - 5;
                                                        Down_Direction  : Bullet2_YInput = Bullet2_YInput + 5;
                                                        Left_Direction  : Bullet2_XInput = Bullet2_XInput - 5;
                                                        Right_Direction : Bullet2_XInput = Bullet2_XInput + 5;
                                                        default: Bullet2_Fired = 1'b0;
                                                    endcase		
                                                end
                                                
                                            else
                                                begin
													Bullet2_YInput = 10'd16;
													Bullet2_XInput = 10'd16;
													Bullet2_Fired = 1'b0;
                                                end
                                        end
                                    else
                                        begin
                                            Bullet2_XInput = 10'b0;
                                            Bullet2_YInput = 10'b0;
                                            Bullet2_Fired 	= 1'b0;
                                        end
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
////////////////////////////////////////////////////////////////////////////////////////////////////////////// //////////////////////////////////////////////////////////////////////////////////////////////////////////////    
							                                      
////////////////////////////////////////////////////////////////////////////////////////////////////////////////                    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////                    
                                    //Setting Bounding boxes for tank control. Looking for box state at x and y positions
                                    Tank1_xDivPos_1 = Tank1_xPos[9:5]%20;
                                    Tank1_yDivPos_1 = Tank1_yPos[9:5]%15;
                                    
									Tank1_xPos2_Holder = Tank1_xPos + TankWidth;
									Tank1_yPos2_Holder = Tank1_yPos + TankWidth;
					
                                    Tank1_xDivPos_2 = Tank1_xPos2_Holder[9:5]%20;
                                    Tank1_yDivPos_2 = Tank1_yPos2_Holder[9:5]%15;
                                    
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////  
                                    //Top left
                                    Tank1Array_1   = MapArray[Tank1_yDivPos_1];// This is the array for the map containing the 'bottom left#' of the tank
                                    Tank1Array_1_3 = Tank1Array_1[4*Tank1_xDivPos_1  ];// This is bit 3 of [3:0] of the current position's status.
                                    Tank1Array_1_2 = Tank1Array_1[4*Tank1_xDivPos_1+1];// This is bit 2 of [3:0] of the current position's status.
                                    Tank1Array_1_1 = Tank1Array_1[4*Tank1_xDivPos_1+2];// This is bit 1 of [3:0] of the current position's status.v
                                    Tank1Array_1_0 = Tank1Array_1[4*Tank1_xDivPos_1+3];// This is bit 0 of [3:0] of the current position's status.
									
                                    Tank1Array_X_1 = {Tank1Array_1_3, Tank1Array_1_2, Tank1Array_1_1, Tank1Array_1_0};
									//This then returns the state of the box for the bottom-left point of the tank, allowing for the game logic to perform functions depending
									//		on the position of the tank.
									
									// The same logic repeats for each corner of the tank.

                                    //Top right
                                    Tank1Array_2   = MapArray[Tank1_yDivPos_1];
                                    Tank1Array_2_3 = Tank1Array_2[4*(Tank1_xDivPos_2 )  ];
                                    Tank1Array_2_2 = Tank1Array_2[4*(Tank1_xDivPos_2 )+1];
                                    Tank1Array_2_1 = Tank1Array_2[4*(Tank1_xDivPos_2 )+2];
                                    Tank1Array_2_0 = Tank1Array_2[4*(Tank1_xDivPos_2 )+3];
                                    Tank1Array_X_2 = {Tank1Array_2_3, Tank1Array_2_2, Tank1Array_2_1, Tank1Array_2_0}; 
									
                                    //Bottom left
                                    Tank1Array_3   = MapArray[Tank1_yDivPos_2 ];
                                    Tank1Array_3_3 = Tank1Array_3[4*(Tank1_xDivPos_1)  ];
                                    Tank1Array_3_2 = Tank1Array_3[4*(Tank1_xDivPos_1)+1];
                                    Tank1Array_3_1 = Tank1Array_3[4*(Tank1_xDivPos_1)+2];
                                    Tank1Array_3_0 = Tank1Array_3[4*(Tank1_xDivPos_1)+3];
                                    Tank1Array_X_3 = {Tank1Array_3_3, Tank1Array_3_2, Tank1Array_3_1, Tank1Array_3_0};   
									
                                    //Bottom right
                                    Tank1Array_4   = MapArray[Tank1_yDivPos_2 ];
                                    Tank1Array_4_3 = Tank1Array_4[4*(Tank1_xDivPos_2 )  ];
                                    Tank1Array_4_2 = Tank1Array_4[4*(Tank1_xDivPos_2 )+1];
                                    Tank1Array_4_1 = Tank1Array_4[4*(Tank1_xDivPos_2 )+2];
                                    Tank1Array_4_0 = Tank1Array_4[4*(Tank1_xDivPos_2 )+3];
                                    Tank1Array_X_4 = {Tank1Array_4_3, Tank1Array_4_2, Tank1Array_4_1, Tank1Array_4_0};   
									
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
                                    //Top left
                                    Tank2Array_1   = MapArray[Tank2_yDivPos_1];// This is the array for the map containing the 'bottom left#' of the tank
                                    Tank2Array_1_3 = Tank2Array_1[4*Tank2_xDivPos_1  ];// This is bit 3 of [3:0] of the current position's status.
                                    Tank2Array_1_2 = Tank2Array_1[4*Tank2_xDivPos_1+1];// This is bit 2 of [3:0] of the current position's status.
                                    Tank2Array_1_1 = Tank2Array_1[4*Tank2_xDivPos_1+2];// This is bit 1 of [3:0] of the current position's status.
                                    Tank2Array_1_0 = Tank2Array_1[4*Tank2_xDivPos_1+3];// This is bit 0 of [3:0] of the current position's status.
									
                                    Tank2Array_X_1 = {Tank2Array_1_3, Tank2Array_1_2, Tank2Array_1_1, Tank2Array_1_0};
									//This then returns the state of the box for the bottom-left point of the tank, allowing for the game logic to perform functions depending
									//		on the position of the tank.
									
									// The same logic repeats for each corner of the tank.

                                    //Top right
                                    Tank2Array_2   = MapArray[Tank2_yDivPos_1];
                                    Tank2Array_2_3 = Tank2Array_2[4*(Tank2_xDivPos_2 )  ];
                                    Tank2Array_2_2 = Tank2Array_2[4*(Tank2_xDivPos_2 )+1];
                                    Tank2Array_2_1 = Tank2Array_2[4*(Tank2_xDivPos_2 )+2];
                                    Tank2Array_2_0 = Tank2Array_2[4*(Tank2_xDivPos_2 )+3];
                                    Tank2Array_X_2 = {Tank2Array_2_3, Tank2Array_2_2, Tank2Array_2_1, Tank2Array_2_0}; 
									
                                    //Bottom left
                                    Tank2Array_3   = MapArray[Tank2_yDivPos_2 ];
                                    Tank2Array_3_3 = Tank2Array_3[4*(Tank2_xDivPos_1)  ];
                                    Tank2Array_3_2 = Tank2Array_3[4*(Tank2_xDivPos_1)+1];
                                    Tank2Array_3_1 = Tank2Array_3[4*(Tank2_xDivPos_1)+2];
                                    Tank2Array_3_0 = Tank2Array_3[4*(Tank2_xDivPos_1)+3];
                                    Tank2Array_X_3 = {Tank2Array_3_3, Tank2Array_3_2, Tank2Array_3_1, Tank2Array_3_0};   
									
                                    //Bottom right
                                    Tank2Array_4   = MapArray[Tank2_yDivPos_2 ];
                                    Tank2Array_4_3 = Tank2Array_4[4*(Tank2_xDivPos_2 )  ];
                                    Tank2Array_4_2 = Tank2Array_4[4*(Tank2_xDivPos_2 )+1];
                                    Tank2Array_4_1 = Tank2Array_4[4*(Tank2_xDivPos_2 )+2];
                                    Tank2Array_4_0 = Tank2Array_4[4*(Tank2_xDivPos_2 )+3];
                                    Tank2Array_X_4 = {Tank2Array_4_3, Tank2Array_4_2, Tank2Array_4_1, Tank2Array_4_0};   
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////									
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////									
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
									
                                    // If y-coordinate is at screen limit, move to other side of screen
                                    if (Tank1_yPos <= EdgeWidth + MoveSpeed)
                                        Tank1_yPos = Pixels_Vert - TankWidth - MoveSpeed - 1;
                                    else if (Tank1_yPos >= Pixels_Vert - TankWidth - EdgeWidth)
                                        Tank1_yPos = MoveSpeed + 1;

                                    //if x-coordinate is at screen limit, move to other side of screen
                                    else if (Tank1_xPos <= EdgeWidth + MoveSpeed)
                                        Tank1_xPos = Pixels_Horiz - TankWidth - MoveSpeed - 1;
                                    else if (Tank1_xPos >= Pixels_Horiz - TankWidth - EdgeWidth)
                                        Tank1_xPos = MoveSpeed + 1;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////        
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
                                    else if (Tank1_Dead == 1)
                                        begin
                                            if (Dead_Counter == 60)
                                                begin
                                                    Tank1_xPos = 32 + 4;
                                                    Tank1_yPos = 32 + 4;  
                                                    Tank1_Dead = 1'b0;

                                                    Dead_Counter = 0;
                                                 end
                                            else
                                                Dead_Counter = Dead_Counter + 1;

                                        end


///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////       
                                    //If bottom edges are in boundary
									else if (((Tank1Array_X_3 == 1) | (Tank1Array_X_3 == 2)) & ((Tank1Array_X_4 == 1) | (Tank1Array_X_4 == 2)))
                                                Tank1_yPos = Tank1_yPos - 1;
												
                                    //If left edges are in boundary
								    else if (((Tank1Array_X_1 == 1) | (Tank1Array_X_1 == 2)) & ((Tank1Array_X_3 == 1) | (Tank1Array_X_3 == 2)))
                                                Tank1_xPos = Tank1_xPos + 1;
												
                                    //if top edges are in boundary
                                    else if (((Tank1Array_X_1 == 1) | (Tank1Array_X_1 == 2)) & ((Tank1Array_X_2 == 1) | (Tank1Array_X_2 == 2)))
                                                Tank1_yPos = Tank1_yPos + 1;
												
                                    // if right edges are in boundary
                                    else if (((Tank1Array_X_2 == 1) | (Tank1Array_X_2 == 2)) & ((Tank1Array_X_4 == 1) | (Tank1Array_X_4 == 2)))
                                                Tank1_xPos = Tank1_xPos - 1;                        
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////        
									// if top left is in boundary
									else if ((Tank1Array_X_1 == 1) | (Tank1Array_X_1 == 2))
										begin
											Tank1_yPos = Tank1_yPos + MoveSpeed;
											Tank1_xPos = Tank1_xPos + MoveSpeed;
										end
									// if top right is in boundary	
									else if ((Tank1Array_X_2 == 1) | (Tank1Array_X_2 == 2))
										begin
											Tank1_yPos = Tank1_yPos + MoveSpeed;
											Tank1_xPos = Tank1_xPos - MoveSpeed;
										end	
									// if bottom left is in boundary	
									else if ((Tank1Array_X_3 == 1) | (Tank1Array_X_3 == 2))
										begin
											Tank1_yPos = Tank1_yPos - MoveSpeed;
											Tank1_xPos = Tank1_xPos + MoveSpeed;
										end	
									// if bottom right is in boundary	
									else if ((Tank1Array_X_4 == 1) | (Tank1Array_X_4 == 2))
										begin
											Tank1_yPos = Tank1_yPos - MoveSpeed;
											Tank1_xPos = Tank1_xPos - MoveSpeed;
										end	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
									else if (Tank1Array_X_4 == 3)
										begin
											MapArray[Tank1_yDivPos_2][4 * Tank1_xDivPos_2    ] = 1'b0;	
											MapArray[Tank1_yDivPos_2][4 * Tank1_xDivPos_2 + 1] = 1'b0;
											MapArray[Tank1_yDivPos_2][4 * Tank1_xDivPos_2 + 2] = 1'b0;
											MapArray[Tank1_yDivPos_2][4 * Tank1_xDivPos_2 + 3] = 1'b0;
											
											CoinValue_1 = CoinValue_1 + 1;
										end
										
									else if (Tank1Array_X_1 == 3)
										begin
											MapArray[Tank1_yDivPos_1][4 * Tank1_xDivPos_1   ] = 1'b0;	
											MapArray[Tank1_yDivPos_1][4 * Tank1_xDivPos_1+ 1] = 1'b0;	
											MapArray[Tank1_yDivPos_1][4 * Tank1_xDivPos_1+ 2] = 1'b0;
											MapArray[Tank1_yDivPos_1][4 * Tank1_xDivPos_1+ 3] = 1'b0;
											
											CoinValue_1 = CoinValue_1 + 1;	
										end
								
 									else if (Tank1Array_X_2 == 3)
										begin
											MapArray[Tank1_yDivPos_1][4 * Tank1_xDivPos_2	 ] = 1'b0;	
											MapArray[Tank1_yDivPos_1][4 * Tank1_xDivPos_2 + 1] = 1'b0;
											MapArray[Tank1_yDivPos_1][4 * Tank1_xDivPos_2 + 2] = 1'b0;
											MapArray[Tank1_yDivPos_1][4 * Tank1_xDivPos_2 + 3] = 1'b0;
											
											CoinValue_1 = CoinValue_1 + 1;	
										end
								
 									else if (Tank1Array_X_3 == 3)
										begin
											MapArray[Tank1_yDivPos_2][4 * Tank1_xDivPos_1   ] = 1'b0;	
											MapArray[Tank1_yDivPos_2][4 * Tank1_xDivPos_1+ 1] = 1'b0;
											MapArray[Tank1_yDivPos_2][4 * Tank1_xDivPos_1+ 2] = 1'b0;
											MapArray[Tank1_yDivPos_2][4 * Tank1_xDivPos_1+ 3] = 1'b0;
											
											CoinValue_1 = CoinValue_1 + 1;
										end
								
 									
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
										
									else
										begin
											MoveSpeed = 1 + MoveSpeed_0 + MoveSpeed_1 * 2;
										//Finally getting to the actual tank controls
											if 		(Up1    == 1)
											    begin
												    Tank1_yPos     = Tank1_yPos - MoveSpeed;
												    PrevDirection_1 = Up_Direction;
											    end
											    
											else if (Right1 == 1)
											    begin
												    Tank1_xPos     = Tank1_xPos + MoveSpeed;
												    PrevDirection_1 = Right_Direction;
											    end
											
											else if (Down1  == 1)
											    begin
												    Tank1_yPos     = Tank1_yPos + MoveSpeed;
												    PrevDirection_1 = Down_Direction;		
											    end
											
											else if (Left1  == 1)
											    begin
												    Tank1_xPos     = Tank1_xPos - MoveSpeed;  
												    PrevDirection_1 = Left_Direction;		
											    end
										end
								 	    
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////         
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                
                                    //Setting Bounding boxes for tank control. Looking for box state at x and y positions
                                    Tank2_xDivPos_1 = Tank2_xPos[9:5]%20;
                                    Tank2_yDivPos_1 = Tank2_yPos[9:5]%15;
                                    
									Tank2_xPos2_Holder = Tank2_xPos + TankWidth;
									Tank2_yPos2_Holder = Tank2_yPos + TankWidth;
					
                                    Tank2_xDivPos_2 = Tank2_xPos2_Holder[9:5]%20;
                                    Tank2_yDivPos_2 = Tank2_yPos2_Holder[9:5]%15;
                                    

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////         
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////            

                                    // If y-coordinate is at screen limit, move to other side of screen
                                    if (Tank2_yPos <= EdgeWidth + MoveSpeed)
                                        Tank2_yPos = Pixels_Vert - TankWidth - MoveSpeed - 1;
                                    else if (Tank2_yPos >= Pixels_Vert - TankWidth - EdgeWidth)
                                        Tank2_yPos = MoveSpeed + 1;

                                    //if x-coordinate is at screen limit, move to other side of screen
                                    else if (Tank2_xPos <= EdgeWidth + MoveSpeed)
                                        Tank2_xPos = Pixels_Horiz - TankWidth - MoveSpeed - 1;
                                    else if (Tank2_xPos >= Pixels_Horiz - TankWidth - EdgeWidth)
                                        Tank2_xPos = MoveSpeed + 1;
                                        
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////                                                
                                    else if (Tank2_Dead == 1)
                                        begin
                                            if (Dead_Counter == 60)
                                                begin
                                                    Tank2_xPos = 640 - (25 + 32 + 4);
                                                    Tank2_yPos = 480 - (25 + 32 + 4);  
                                                    Tank2_Dead = 1'b0;

                                                    Dead_Counter = 0;
                                                 end
                                            else
                                                Dead_Counter = Dead_Counter + 1;
                                        end                                           

///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////       
                                    //If bottom edges are in boundary
									else if (((Tank2Array_X_3 == 1) | (Tank2Array_X_3 == 2)) & ((Tank2Array_X_4 == 1) | (Tank2Array_X_4 == 2)))
                                                Tank2_yPos = Tank2_yPos - 1;
												
                                    //If left edges are in boundary
								    else if (((Tank2Array_X_1 == 1) | (Tank2Array_X_1 == 2)) & ((Tank2Array_X_3 == 1) | (Tank2Array_X_3 == 2)))
                                                Tank2_xPos = Tank2_xPos + 1;
												
                                    //if top edges are in boundary
                                    else if (((Tank2Array_X_1 == 1) | (Tank2Array_X_1 == 2)) & ((Tank2Array_X_2 == 1) | (Tank2Array_X_2 == 2)))
                                                Tank2_yPos = Tank2_yPos + 1;
												
                                    // if right edges are in boundary
                                    else if (((Tank2Array_X_2 == 1) | (Tank2Array_X_2 == 2)) & ((Tank2Array_X_4 == 1) | (Tank2Array_X_4 == 2)))
                                                Tank2_xPos = Tank2_xPos - 1;         
                                                                                                             
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////        
									// if top left is in boundary
									else if ((Tank2Array_X_1 == 1) | (Tank2Array_X_1 == 2))
										begin
											Tank2_yPos = Tank2_yPos + MoveSpeed;
											Tank2_xPos = Tank2_xPos + MoveSpeed;
										end
									// if top right is in boundary	
									else if ((Tank2Array_X_2 == 1) | (Tank2Array_X_2 == 2))
										begin
											Tank2_yPos = Tank2_yPos + MoveSpeed;
											Tank2_xPos = Tank2_xPos - MoveSpeed;
										end	
									// if bottom left is in boundary	
									else if ((Tank2Array_X_3 == 1) | (Tank2Array_X_3 == 2))
										begin
											Tank2_yPos = Tank2_yPos - MoveSpeed;
											Tank2_xPos = Tank2_xPos + MoveSpeed;
										end	
									// if bottom right is in boundary	
									else if ((Tank2Array_X_4 == 1) | (Tank2Array_X_4 == 2))
										begin
											Tank2_yPos = Tank2_yPos - MoveSpeed;
											Tank2_xPos = Tank2_xPos - MoveSpeed;
										end	                      
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
									else if (Tank2Array_X_1 == 3)
										begin
											MapArray[Tank2_yDivPos_1][4 * Tank2_xDivPos_1   ] = 1'b0;	
											MapArray[Tank2_yDivPos_1][4 * Tank2_xDivPos_1+ 1] = 1'b0;	
											MapArray[Tank2_yDivPos_1][4 * Tank2_xDivPos_1+ 2] = 1'b0;
											MapArray[Tank2_yDivPos_1][4 * Tank2_xDivPos_1+ 3] = 1'b0;
											
											CoinValue_2 = CoinValue_2 + 1;	
										end
								
 									else if (Tank2Array_X_2 == 3)
										begin
											MapArray[Tank2_yDivPos_1][4 * Tank2_xDivPos_2	 ] = 1'b0;	
											MapArray[Tank2_yDivPos_1][4 * Tank2_xDivPos_2 + 1] = 1'b0;
											MapArray[Tank2_yDivPos_1][4 * Tank2_xDivPos_2 + 2] = 1'b0;
											MapArray[Tank2_yDivPos_1][4 * Tank2_xDivPos_2 + 3] = 1'b0;
											
											CoinValue_2 = CoinValue_2 + 1;	
										end
								
 									else if (Tank2Array_X_3 == 3)
										begin
											MapArray[Tank2_yDivPos_2][4 * Tank2_xDivPos_1   ] = 1'b0;	
											MapArray[Tank2_yDivPos_2][4 * Tank2_xDivPos_1+ 1] = 1'b0;
											MapArray[Tank2_yDivPos_2][4 * Tank2_xDivPos_1+ 2] = 1'b0;
											MapArray[Tank2_yDivPos_2][4 * Tank2_xDivPos_1+ 3] = 1'b0;
											
											CoinValue_2 = CoinValue_2 + 1;
										end
								
 									else if (Tank2Array_X_4 == 3)
										begin
											MapArray[Tank2_yDivPos_2][4 * Tank2_xDivPos_2   ] = 1'b0;	
											MapArray[Tank2_yDivPos_2][4 * Tank2_xDivPos_2+ 1] = 1'b0;
											MapArray[Tank2_yDivPos_2][4 * Tank2_xDivPos_2+ 2] = 1'b0;
											MapArray[Tank2_yDivPos_2][4 * Tank2_xDivPos_2+ 3] = 1'b0;
											
											CoinValue_2 = CoinValue_2 + 1;
										end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////	
									else
										begin
										//Finally getting to the actual tank controls
												 if (Up2    == 1)
											    begin
												    Tank2_yPos     = Tank2_yPos - MoveSpeed;
												    PrevDirection_2 = Up_Direction;
											    end
											    
											else if (Right2 == 1)
											    begin
												    Tank2_xPos     = Tank2_xPos + MoveSpeed;
												    PrevDirection_2 = Right_Direction;
											    end
											
											else if (Down2  == 1)
											    begin
												    Tank2_yPos     = Tank2_yPos + MoveSpeed;
												    PrevDirection_2 = Down_Direction;		
											    end
											
											else if (Left2  == 1)
											    begin
												    Tank2_xPos     = Tank2_xPos - MoveSpeed;  
												    PrevDirection_2 = Left_Direction;		
											    end
										end
								end 	    
								
							if(CoinValue_1[3:0] == 4'b1010) // Get rid of A-F values on segment counter, only display 0-9. 
								begin
									CoinValue_1[7:4] = CoinValue_1[7:4] + 4'b0001;
									CoinValue_1[3:0] = 4'b0000;										      
								end    

							if(CoinValue_2[3:0] == 4'b1010) // Get rid of A-F values on segment counter, only display 0-9. 
								begin
									CoinValue_2[7:4] = CoinValue_2[7:4] + 4'b0001;
									CoinValue_2[3:0] = 4'b0000;										      
								end    
								
							if((P1_Deaths >= Max_Deaths) | (P2_Deaths >= Max_Deaths))
							begin
							     Reset_Val = 1'b1;
							     
							end
							

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
                            //within tank bounding box, set image to tank
                            if ((Val_Col_In >= Tank1_yPos) & (Val_Col_In <= Tank1_yPos + TankWidth) & (Val_Row_In >= Tank1_xPos) & (Val_Row_In <= Tank1_xPos + TankWidth))
                                begin
									if (Tank1_Dead == 0)
                                        begin
                                            //If moving upwards, image is normal orientation
                                            if (PrevDirection_1 == Up_Direction)
                                                begin
                                                    Tank1_XInput = Val_Row_In - Tank1_xPos;
                                                    Tank1_YInput = Val_Col_In - Tank1_yPos;
                                                end
                                            // If moving downwards, image is mirrored in x
                                            else if (PrevDirection_1 == Down_Direction)    
                                                begin
                                                    Tank1_XInput = TankWidth - (Val_Row_In - Tank1_xPos)%TankWidth;
                                                    Tank1_YInput = TankWidth - (Val_Col_In - Tank1_yPos)%TankWidth;
                                                end
                                            // if moving left, image is flipped to horizontal direction
                                            else if (PrevDirection_1 == Left_Direction)    
                                                begin
                                                    Tank1_YInput = Val_Row_In - Tank1_xPos;
                                                    Tank1_XInput = Val_Col_In - Tank1_yPos;
                                                end
                                            // if moving right, image is flipped to horizontal, and then mirrored in y 
                                            else if (PrevDirection_1 == Right_Direction)
                                                begin
                                                    Tank1_YInput = TankWidth - (Val_Row_In - Tank1_xPos)%TankWidth;
                                                    Tank1_XInput = TankWidth - (Val_Col_In - Tank1_yPos)%TankWidth;
                                                end

                                            Red   = Colour_Data_Tank1[11:8];
                                            Green = Colour_Data_Tank1[ 7:4];
                                            Blue  = Colour_Data_Tank1[ 3:0];
                                        end
                                    else
                                        begin
                                            Red = Colour_Data_Explosion1[11:8];
                                            Green = Colour_Data_Explosion1[7:4];                                        
                                            Blue = Colour_Data_Explosion1[3:0];  
                                        end  
                                end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////                               
                                
                          //within tank bounding box, set image to tank
                            else if ((Val_Col_In >= Tank2_yPos) & (Val_Col_In <= Tank2_yPos + TankWidth) & (Val_Row_In >= Tank2_xPos) & (Val_Row_In <= Tank2_xPos + TankWidth))
                                begin
                                    if (Tank2_Dead == 0)
                                        begin
                                            //If moving upwards, image is normal orientation
                                            if (PrevDirection_2 == Up_Direction)
                                                begin
                                                    Tank2_XInput = Val_Row_In - Tank2_xPos;
                                                    Tank2_YInput = Val_Col_In - Tank2_yPos;
                                                end
                                            // If moving downwards, image is mirrored in x
                                            else if (PrevDirection_2 == Down_Direction)    
                                                begin
                                                    Tank2_XInput = TankWidth - (Val_Row_In - Tank2_xPos)%TankWidth;
                                                    Tank2_YInput = TankWidth - (Val_Col_In - Tank2_yPos)%TankWidth;
                                                end
                                            // if moving left, image is flipped to horizontal direction
                                            else if (PrevDirection_2 == Left_Direction)    
                                                begin
                                                    Tank2_YInput = Val_Row_In - Tank2_xPos;
                                                    Tank2_XInput = Val_Col_In - Tank2_yPos;
                                                end
                                            // if moving right, image is flipped to horizontal, and then mirrored in y 
                                            else if (PrevDirection_2 == Right_Direction)
                                                begin
                                                    Tank2_YInput = TankWidth - (Val_Row_In - Tank2_xPos)%TankWidth;
                                                    Tank2_XInput = TankWidth - (Val_Col_In - Tank2_yPos)%TankWidth;
                                                end
                    
                                            Green = Colour_Data_Tank2[11:8];
                                            Red   = Colour_Data_Tank2[ 7:4];
                                            Blue  = Colour_Data_Tank2[ 3:0];
                                        end
                                    else
                                        begin
                                            Red     = Colour_Data_Explosion1[11:8];//############
                                            Green   = Colour_Data_Explosion1[7:4];                                        
                                            Blue    = Colour_Data_Explosion1[3:0];  
                                        end 
                                end
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////// 							
							//Bullet Draw
							else if (((Val_Col_In >= Bullet1_YInput - BulletWidth/2) & (Val_Col_In <= Bullet1_YInput + BulletWidth/2))
							       & ((Val_Row_In >= Bullet1_XInput - BulletWidth/2) & (Val_Row_In <= Bullet1_XInput + BulletWidth/2))
							       &  (Bullet1_Fired == 1))
								begin
                                    Red 	= 4'h0;
                                    Green 	= 4'h8; 
                                    Blue 	= 4'h0;
								end
								
							else if (((Val_Col_In >= Bullet2_YInput - BulletWidth/2) & (Val_Col_In <= Bullet2_YInput + BulletWidth/2))
							       & ((Val_Row_In >= Bullet2_XInput - BulletWidth/2) & (Val_Row_In <= Bullet2_XInput + BulletWidth/2))
							       &  (Bullet2_Fired == 1))
							       begin
                                        Red 	= 4'h8;
                                        Green 	= 4'h0;
                                        Blue 	= 4'h0;
                                   end
								
								
							else	
                                //if not within tank bounding box, image is dependant on colour of map.
								//	this will be changed to the colour of specific images dependant on the case	
								//	rather than just flat colours.
                                begin
									xDivPos = ((Val_Row_In[9:5])%20);
									yDivPos = ((Val_Col_In[9:5])%15);
									
									MapArrayData_Y   = MapArray[yDivPos];
									MapArrayData_X_3 = MapArrayData_Y[4*xDivPos];
									MapArrayData_X_2 = MapArrayData_Y[4*xDivPos + 1];
									MapArrayData_X_1 = MapArrayData_Y[4*xDivPos + 2];
									MapArrayData_X_0 = MapArrayData_Y[4*xDivPos + 3];
									
									MapArray_X = {MapArrayData_X_3, MapArrayData_X_2, MapArrayData_X_1, MapArrayData_X_0 };  
									
									case (MapArray_X)
										4'h0:begin  Red   = 4'hF; 
                                                    Green = 4'hF; 
                                                    Blue  = 4'hF;
											end
										
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
