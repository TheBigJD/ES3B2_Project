module VGA_Draw(
//Master Control Signals
    input Master_Clock_In, Reset_N_In,
    
//Signals from VGA Controller
    input Disp_Ena_In,
    input [9:0] Val_Col_In, Val_Row_In,
    
//Signals to VGA output    
    output reg [3:0] Red   = 4'h0, 
	output reg [3:0] Blue  = 4'h0, 
    output reg [3:0] Green = 4'h0,

//Tank control inputs
    input Up1, Down1, Left1, Right1, Fire1,
    input Up2, Down2, Left2, Right2, Fire2,
    
//Game control inputs
    input LevelSwitch_2, LevelSwitch_1, LevelSwitch_0,
    input ColourSwitch_1,
    input MoveSpeed_1, MoveSpeed_0,
    
//Signals to display on seven segment displays
	output reg [7:0] CoinValue_1 	= 8'd0,
	output reg [7:0] CoinValue_2 	= 8'd0,
	output reg [7:0] P1_Deaths 		= 8'd5,
	output reg [7:0] P2_Deaths 		= 8'd5

);

//Constants for screen height and width
parameter Pixels_Horiz = 640; //Num of Pixels in X axis
parameter Pixels_Vert  = 480; //Num of Pixels in Y axis

//Constants for object width
parameter EdgeWidth = 0;	// Edge of screen - controlling bounding box around screen
parameter [5:0] TankWidth 	= 6'd24;	// Tank size
parameter [3:0] BulletWidth = 4'd10;	// Bullet Size

//Constants for controls, removes need to use binary every time referencing variable
parameter [2:0] Up_Direction      = 3'b100;	
parameter [2:0] Down_Direction    = 3'b001;	
parameter [2:0] Left_Direction    = 3'b010;	
parameter [2:0] Right_Direction   = 3'b011;	

// Tank movement speed
reg [2:0] MoveSpeed = 3'b1;

//Maximum Deaths - control game reset
reg [7:0] Max_Deaths = 8'd5;
reg  Reset_Val = 0;

//Counter variable to control tank death image
reg [5:0] Dead_Counter = 6'd60;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Map registers
reg [0:79] MapArray [0:14];

//Used for drawing the map

//Horizontal and vertical position /32
reg [9:0] xDivPos, yDivPos = 10'b0;
//Stores current row being drawn
reg [0:79] MapArrayData_Y = 80'b0;
//Stores 4 1-bit values of map array for point being drawn
reg MapArrayData_X_3, MapArrayData_X_2, MapArrayData_X_1, MapArrayData_X_0;
//Stores as nibble
reg [3:0]  MapArray_X = 4'b0;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Position of Tank1, initialising at given position
reg [9:0] Tank1_xPos = 32 + 4;
reg [9:0] Tank1_yPos = 32 + 4;
//Register for previous direction of tank - controls orientation of tank drawn and direction of bullet once fired
reg [2:0] PrevDirection_1     = 3'b000;	

//Variables to store x, y, x+w, and y+w - X and Y positions of each tank corner.	
//		x position of left side, and y position of top side, with respect to screen position, divided by 32 to account for map resolution
reg [9:0] Tank1_xDivPos_1, Tank1_yDivPos_1;
//		x position of right side, and y position of bottom side, with respect to screen position, divided by 32 to account for map resolution
reg [9:0] Tank1_xPos2_Holder, Tank1_yPos2_Holder; 	//variable is Tank1_yPos and Tank1_xPos, both + TankWidth
reg [9:0] Tank1_xDivPos_2, Tank1_yDivPos_2;			//Divided by 32


//Following four arrays are identical, and are used for storing the type of block each corner of the map is in

//Load in MapArray row for each tank corner position
reg [0:79] Tank1Array_1 = 80'b0;
//Store 4 1-bit value relating to position of the given corner
reg Tank1Array_1_0, Tank1Array_1_1, Tank1Array_1_2, Tank1Array_1_3;
//Store nibble given from values above
reg [3:0]  Tank1Array_X_1 = 4'b0;

reg [0:79] Tank1Array_2 = 80'b0;
reg Tank1Array_2_0, Tank1Array_2_1, Tank1Array_2_2, Tank1Array_2_3;
reg [3:0] Tank1Array_X_2 = 4'b0;

reg [0:79] Tank1Array_3 = 80'b0;
reg Tank1Array_3_0, Tank1Array_3_1, Tank1Array_3_2, Tank1Array_3_3;
reg [3:0] Tank1Array_X_3 = 4'b0;

reg [0:79] Tank1Array_4 = 80'b0;
reg Tank1Array_4_0, Tank1Array_4_1, Tank1Array_4_2, Tank1Array_4_3;
reg [3:0] Tank1Array_X_4 = 4'b0;

//Condition is Tank1 has been shot or not
reg Tank1_Dead = 1'b0;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//Position of Tank2, initialising at given position
reg [9:0] Tank2_xPos = 640 - 25 - 4 - 32;
reg [9:0] Tank2_yPos = 480 - 25 - 4 - 32;	
//Register for previous direction of tank - controls orientation of tank drawn, and direction of the bullet when it's fired.
reg [2:0] PrevDirection_2     = 3'b000;

//Variables to store x, y, x+w, and y+w - X and Y positions of each tank corner.	
//		x position of left side, and y position of top side, with respect to screen position, divided by 32 to account for map resolution	
reg [9:0] Tank2_xDivPos_1, Tank2_yDivPos_1;
//		x position of right side, and y position of bottom side, with respect to screen position, divided by 32 to account for map resolution
reg [9:0] Tank2_xPos2_Holder, Tank2_yPos2_Holder;	//Variable is Tank2_yPos anks Tank2_xPos, both with +TankWidth
reg [9:0] Tank2_xDivPos_2, Tank2_yDivPos_2;

//Following four arrays are identical, and are used for storing the type of block each corner of the map is in

//Load in MapArray row for each tank corner position
reg [0:79] Tank2Array_1 = 80'b0;
//Store 4 1-bit values relating to position of given corner
reg Tank2Array_1_0, Tank2Array_1_1, Tank2Array_1_2, Tank2Array_1_3;
//Convert into a nibble
reg [3:0]  Tank2Array_X_1 = 4'b0;

reg [0:79] Tank2Array_2 = 80'b0;
reg Tank2Array_2_0, Tank2Array_2_1, Tank2Array_2_2, Tank2Array_2_3;
reg [3:0] Tank2Array_X_2 = 4'b0;

reg [0:79] Tank2Array_3 = 80'b0;
reg Tank2Array_3_0, Tank2Array_3_1, Tank2Array_3_2, Tank2Array_3_3;
reg [3:0] Tank2Array_X_3 = 4'b0;

reg [0:79] Tank2Array_4 = 80'b0;
reg Tank2Array_4_0, Tank2Array_4_1, Tank2Array_4_2, Tank2Array_4_3;
reg [3:0] Tank2Array_X_4 = 4'b0;

//Reg stores is Tank2 has been shot or not
reg Tank2_Dead = 1'b0;
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Instantiating sprites

//Input colour references for Tank1
reg [9:0] Tank1_XInput, Tank1_YInput = 10'b0;	
//Output 12-bit colour value
wire [11:0] Colour_Data_Tank1;
//Instantiated module, returns colour value dependant on input
TankImage M5 (.Master_Clock_In(Master_Clock_In), .xInput(Tank1_XInput + 1), .yInput(Tank1_YInput + 1), .ColourData(Colour_Data_Tank1));

//Explosion sprite
wire [11:0] Colour_Data_Explosion1;
Explosion M13 (.Master_Clock_In(Master_Clock_In), .xInput(Tank1_XInput + 1), .yInput(Tank1_YInput + 1), .ColourData(Colour_Data_Explosion1));

//Tank 2 sprite
reg [9:0] Tank2_XInput, Tank2_YInput = 10'b0;	
wire [11:0] Colour_Data_Tank2;
TankImage M11 (.Master_Clock_In(Master_Clock_In), .xInput(Tank2_XInput + 1), .yInput(Tank2_YInput + 1), .ColourData(Colour_Data_Tank2));

//Second explosion sprite
wire [11:0] Colour_Data_Explosion2;
Explosion M14 (.Master_Clock_In(Master_Clock_In), .xInput(Tank2_XInput + 1), .yInput(Tank2_YInput + 1), .ColourData(Colour_Data_Explosion2));

//Sprite for breakable brick
wire [11:0] Colour_Data_Brick;
Brick_Block M6( .Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In + 1), .yInput(Val_Col_In + 1), .ColourData(Colour_Data_Brick));

//Alternative coin sprite
wire [11:0] Colour_Data_Nyan;
NyanCat M7( .Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In + 1), .yInput(Val_Col_In + 1), .ColourData(Colour_Data_Nyan));

//Sprite for unbreakable block
wire [11:0] Colour_Data_Solid_Block;
Solid_block M8( .Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In + 1), .yInput(Val_Col_In + 1), .ColourData(Colour_Data_Solid_Block));
	
//Sprite for normal coins
wire [11:0] Colour_Data_Coin;
Coin_Image M9( .Master_Clock_In(Master_Clock_In), .xInput(Val_Row_In + 1), .yInput(Val_Col_In + 1), .ColourData(Colour_Data_Coin));

	
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Bullet1 Registers

//Position
reg [9:0] Bullet1_XInput, Bullet1_YInput = 10'd16;

//Debounce/checking for rising edge of 'Fire' button being pressed
reg Bullet1_Fired_prev_1 = 1'b0;
reg Bullet1_Fired_prev_2 = 1'b0;
reg Bullet1_Fired		 = 1'b0;

//Direction of bullet travel
reg [2:0] Bullet1_Dir    = 3'b000;

	// Note - these are coded differently to the tank bounding boxes. Tanks are done at each corner, whereas this is done
	//		at the centre only due to its smaller size

//X and Y Positions divided by 32
reg [9:0] Bullet1_xDivPos, Bullet1_yDivPos = 10'b0;
//Stores row of map that the bullet is positioned in	
reg [0:79] Bullet1ArrayData_Y = 80'b0;
//4 1-bit values relating to correct position
reg Bullet1ArrayData_X_0, Bullet1ArrayData_X_1, Bullet1ArrayData_X_2, Bullet1ArrayData_X_3 = 1'b0;
//Moved into a nibble
reg [3:0] Bullet1Array_X = 4'b0;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//Bullet2 Registers

//Position
reg [9:0] Bullet2_XInput, Bullet2_YInput = 10'd16;

//Debounce and checking for rising edge of 'Fire' button being pressed
reg Bullet2_Fired_prev_1 = 1'b0;
reg Bullet2_Fired_prev_2 = 1'b0;
reg Bullet2_Fired		 = 1'b0;

//Direction of bullet travel
reg [2:0] Bullet2_Dir    = 3'b000;

	// Note - these are coded differently to the tank bounding boxes. Tanks are done at each corner, whereas this is done
	//		at the centre only
	
//X and Y Positions divided by 32	
reg [9:0] Bullet2_xDivPos, Bullet2_yDivPos = 10'b0;	
//Stores row of map that the bullet is positioned in
reg [0:79] Bullet2ArrayData_Y = 80'b0;
//4 1-bit values relating to map position
reg Bullet2ArrayData_X_0, Bullet2ArrayData_X_1, Bullet2ArrayData_X_2, Bullet2ArrayData_X_3;
//Moved into a nibble
reg [3:0] Bullet2Array_X = 4'b0;


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	
//At every positive edge of master clock signal - is 25MHz to sync colour output with VGA clock
always @(posedge Master_Clock_In)	
	begin
		// If Master Reset is low, OR game logic triggers a reset (When 5 kills are reached)
		if ((Reset_N_In == 0) | (Reset_Val == 1))
			begin
                //Immediately resetting Reset_Val back to 0 to restart the game. Loop is designed
                //	reinstantiate level, and reset values of deaths, and positions of tanks and bullets.
                //This set to 1'b0 here allows for a 1-clock reset timer.
                Reset_Val = 1'b0;
                
			    P1_Deaths = 8'b0;
			    P2_Deaths = 8'b0;
			    
			    CoinValue_1 = 8'b0;
			    CoinValue_2 = 8'b0;
                
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
							
				//Draw grey screen while in reset				    
                Red   = 4'h2;     
                Blue  = 4'h2;
                Green = 4'h2;
				
				//Level code is saved in reset to change once manual reset is triggered, or
				//		once game finishes.
				//MapArray chosen is dependant on input switches, and as these values are only
				//		set in the reset loop, these values are unchanged outside of main game logic.
				//Maps are a 20-by-15 grid, given by 640-by-480 / 32. Each position is given a nibble
				//		which tells the game what to draw and how the tanks/bullets should behave in that block
				//Maps care chosen by a 3-bit value dependant on switches on the board.
				case ({LevelSwitch_2, LevelSwitch_1, LevelSwitch_0})
				    6: begin
							// Presentation start screen
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
						//Last map is set as default instead of "0: begin" because only levels 0-6 are programmed in, a switch position reading 7 would
						//		error
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
			//begin main logic 
			begin
				//If Display is not enabled from VGA controller, draw black.
				if (Disp_Ena_In == 0)
					begin
						Red 	= {4{1'b0}};
						Blue 	= {4{1'b0}};
						Green 	= {4{1'b0}};
					end
		
				else
					begin
						//If coordinate is within main screen
						if ((Val_Col_In <= Pixels_Vert) & (Val_Row_In <= Pixels_Horiz)) 
							begin
								//IF loop controls game logic, updating once bottom right corner is drawn, i.e. at ~60Hz
								if ((Val_Col_In == Pixels_Vert) & (Val_Row_In == Pixels_Horiz))
									begin

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
				//Bullet controls
										// Record 2 previous bullet fired states for each tank
									
										Bullet1_Fired_prev_2 = Bullet1_Fired_prev_1;
										Bullet1_Fired_prev_1 = Fire1;
									
										Bullet2_Fired_prev_2 = Bullet2_Fired_prev_1;
										Bullet2_Fired_prev_1 = Fire2;
										
										//Rising edge of 'Fire' button input, AND if bullet isn't already in motion
										if ((Fire1 == 1'b1) & (Bullet1_Fired_prev_2 == 1'b0) & (Bullet1_Fired == 0))
											begin
												//This loop runs only once given condition is cancelled out on first line whatever happens with the Fire button, 
												//		and it enables second loop instead
												Bullet1_Fired = 1'b1;
												
												//Direction of bullet is dependant on tank's direction
												Bullet1_Dir   = PrevDirection_1;
												
												//Starting position of bullet is dependant on direction
												//Starts on side of tank that it should aim for, with a boundary limit of (BulletWidth + 3)
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
													default: 
														begin
															//If something happens to cause an error, bullet firing is cancelled
															Bullet1_Fired = 1'b0;
															Bullet1_XInput = 10'd16;
															Bullet1_YInput = 10'd16;
														end
												endcase
											end
										
										else if (Bullet1_Fired == 1)
											begin
												//Divide X and Y position by 32 by taking 5 MSBs. %20 and %15 to ensure within range of MapArray
												Bullet1_xDivPos = (Bullet1_XInput[9:5])%20;
												Bullet1_yDivPos = (Bullet1_YInput[9:5])%15;
												
												//Taking row of MapArray that bullet is in
												Bullet1ArrayData_Y   = MapArray[Bullet1_yDivPos];
												//Getting 4 1-bit values corresponding to current X position block
												Bullet1ArrayData_X_3 = Bullet1ArrayData_Y[4 * (Bullet1_xDivPos)    ];
												Bullet1ArrayData_X_2 = Bullet1ArrayData_Y[4 * (Bullet1_xDivPos) + 1];
												Bullet1ArrayData_X_1 = Bullet1ArrayData_Y[4 * (Bullet1_xDivPos) + 2];
												Bullet1ArrayData_X_0 = Bullet1ArrayData_Y[4 * (Bullet1_xDivPos) + 3];
												//Concatenating into a nibble
												Bullet1Array_X = {Bullet1ArrayData_X_3, Bullet1ArrayData_X_2, Bullet1ArrayData_X_1, Bullet1ArrayData_X_0 };
												
												
												//If bullet is outside of screen, reset and cancel bullet
												if ((Bullet1_XInput <= BulletWidth) | (Bullet1_YInput <= BulletWidth) | (Bullet1_XInput >= Pixels_Horiz - BulletWidth) | (Bullet1_YInput >= Pixels_Vert - BulletWidth))
													begin
														Bullet1_XInput = 10'd16;
														Bullet1_YInput = 10'd16;
														Bullet1_Fired 	=  1'b0;
													end
												//If bullet hits a block
												else if ((Bullet1Array_X == 1) | (Bullet1Array_X == 2))
													begin
														// Cancel bullet
														Bullet1_XInput = 10'd16;
														Bullet1_YInput = 10'd16;
														Bullet1_Fired 	=  1'b0;
									
														//If Block hit was a breakable block, "break" it by setting value of block to 0 (transparent)
														if (Bullet1Array_X == 2)
															begin
																MapArray[Bullet1_yDivPos][4 * Bullet1_xDivPos	 ] = 1'b0;	
																MapArray[Bullet1_yDivPos][4 * Bullet1_xDivPos + 1] = 1'b0;
																MapArray[Bullet1_yDivPos][4 * Bullet1_xDivPos + 2] = 1'b0;
																MapArray[Bullet1_yDivPos][4 * Bullet1_xDivPos + 3] = 1'b0;
															end
													end
												
												//If Bullet1 is within enemy tank's bounding box
												else if (((Bullet1_XInput >= Tank2_xPos) & (Bullet1_XInput <= Tank2_xPos + TankWidth))
														&((Bullet1_YInput >= Tank2_yPos) & (Bullet1_YInput <= Tank2_yPos + TankWidth)))
													begin
														//Signal Tank2 is dead, and run commands related further down logic
														Tank2_Dead = 1'b1;
														//Add 1 to deaths
														P2_Deaths = P2_Deaths + 1;
														
														//Reset Bullet1 values
														Bullet1_XInput = 10'd16;
														Bullet1_YInput = 10'd16;
														Bullet1_Fired  =  1'b0;
													end
												//If Bullet1 is within 'Coin' or 'Nothing' block
												else if ((Bullet1Array_X == 3) | (Bullet1Array_X == 0))
													begin    		                                            
														case (Bullet1_Dir)
															//Move with speed of 5 in direction of travel
															Up_Direction    : Bullet1_YInput = Bullet1_YInput - 5;
															Down_Direction  : Bullet1_YInput = Bullet1_YInput + 5;
															Left_Direction  : Bullet1_XInput = Bullet1_XInput - 5;
															Right_Direction : Bullet1_XInput = Bullet1_XInput + 5;
															
															//Default prevents errors given 4 options of a 3-bit (8-option) value are defined
															default: Bullet1_Fired = 1'b0;
														endcase		
													end
												//If something else happens (mistakenly), reset Bullet1 values
												else
													begin
														Bullet1_YInput = 10'd16;
														Bullet1_XInput = 10'd16;
														Bullet1_Fired = 1'b0;
													end
											end
										else
											begin
												Bullet1_XInput = 10'd16;
												Bullet1_YInput = 10'd16;
												Bullet1_Fired 	= 1'b0;
											end
										
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////																				
										
										//Rising edge of 'Fire' button input, AND if bullet isn't already in motion
										if ((Fire2 == 1'b1) & (Bullet2_Fired_prev_2 == 1'b0) & (Bullet2_Fired == 0))
											begin
												//This loop runs only once given condition is cancelled out on first line whatever happens with the Fire button, 
												//		and it enables second loop instead
												Bullet2_Fired = 1'b1;
												
												//Direction of bullet is dependent on tank's direction
												Bullet2_Dir   = PrevDirection_2;
											
												//Starting position of bullet is dependant on direction
												//Starts on side of tank that it should aim for, with a boundary limit of (BulletWidth + 3)
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
													
													//If something happens to cause an error, bullet firing is cancelled
													default: Bullet2_Fired = 1'b0;
												endcase
											end
										
										else if (Bullet2_Fired == 1)
											begin
												//Divide X and Y position by 32 by taking 5 MSBs. %20 and %15 to ensure within range of MapArray
												Bullet2_xDivPos = (Bullet2_XInput[9:5])%20;
												Bullet2_yDivPos = (Bullet2_YInput[9:5])%15;
											
												//Taking row of MapArray that bullet is in
												Bullet2ArrayData_Y   = MapArray[Bullet2_yDivPos];
												
												//Getting 4 1-bit values corresponding to current X position block
												Bullet2ArrayData_X_3 = Bullet2ArrayData_Y[4* (Bullet2_xDivPos)];
												Bullet2ArrayData_X_2 = Bullet2ArrayData_Y[4* (Bullet2_xDivPos) + 1];
												Bullet2ArrayData_X_1 = Bullet2ArrayData_Y[4* (Bullet2_xDivPos) + 2];
												Bullet2ArrayData_X_0 = Bullet2ArrayData_Y[4* (Bullet2_xDivPos) + 3];
											
												//Concatenating into a nibble
												Bullet2Array_X = {Bullet2ArrayData_X_3, Bullet2ArrayData_X_2, Bullet2ArrayData_X_1, Bullet2ArrayData_X_0 };
											
												//If bullet is outside of screen, reset and cancel bullet
												if ((Bullet2_XInput <= BulletWidth) | (Bullet2_YInput <= BulletWidth) | (Bullet2_XInput >= Pixels_Horiz - BulletWidth) | (Bullet2_YInput >= Pixels_Vert - BulletWidth))
													begin
														Bullet2_XInput = 10'd16;
														Bullet2_YInput = 10'd16;
														Bullet2_Fired  =  1'b0;
													end
												
												//If bullet hits a block
												else if ((Bullet2Array_X == 1) | (Bullet2Array_X == 2))
													begin
														// Cancel bullet
														Bullet2_XInput = 10'd16;
														Bullet2_YInput = 10'd16;
														Bullet2_Fired  =  1'b0;
															
															//If Block hit was a breakable block, "break" it by setting value of block to 0 (transparent)
															if (Bullet2Array_X == 2)
															begin
																MapArray[Bullet2_yDivPos][4 * Bullet2_xDivPos	 ] = 1'b0;	
																MapArray[Bullet2_yDivPos][4 * Bullet2_xDivPos + 1] = 1'b0;
																MapArray[Bullet2_yDivPos][4 * Bullet2_xDivPos + 2] = 1'b0;
																MapArray[Bullet2_yDivPos][4 * Bullet2_xDivPos + 3] = 1'b0;
															end
													end
													
												//If Bullet1 is within enemy tank's bounding box
												else if (((Bullet2_XInput >= Tank1_xPos) & (Bullet2_XInput <= Tank1_xPos + TankWidth))
														&((Bullet2_YInput >= Tank1_yPos) & (Bullet2_YInput <= Tank1_yPos + TankWidth)))
													begin
													   //Signal Tank1 is dead, and run commands related further down logic
													   Tank1_Dead = 1'b1;
													   
													   //Add 1 to deaths
													   P1_Deaths = P1_Deaths + 1;
														
													   //Reset Bullet1 values
													   Bullet2_XInput = 10'd16;
													   Bullet2_YInput = 10'd16;
													   Bullet2_Fired  =  1'b0;
													end
													
												//If Bullet2 is within 'Coin' or 'Nothing' block
												else if ((Bullet2Array_X == 3) | (Bullet2Array_X == 0))
													begin    		                                            
														  case (Bullet2_Dir)
															//Move with speed of 5 in direction of travel
															Up_Direction    : Bullet2_YInput = Bullet2_YInput - 5;
															Down_Direction  : Bullet2_YInput = Bullet2_YInput + 5;
															Left_Direction  : Bullet2_XInput = Bullet2_XInput - 5;
															Right_Direction : Bullet2_XInput = Bullet2_XInput + 5;
															
															//Default prevents errors given 4 options of a 3-bit (8-option) value are defined
															default: Bullet2_Fired = 1'b0;
														endcase		
													end
												
												//If something else happens (mistakenly), reset Bullet2 values
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
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////    
																                    
										//Setting Bounding boxes for tank control. Looking for box state at x and y positions
										Tank1_xDivPos_1 = Tank1_xPos[9:5]%20;
										Tank1_yDivPos_1 = Tank1_yPos[9:5]%15;
									
										Tank1_xPos2_Holder = Tank1_xPos + TankWidth;
										Tank1_yPos2_Holder = Tank1_yPos + TankWidth;
					
										Tank1_xDivPos_2 = Tank1_xPos2_Holder[9:5]%20;
										Tank1_yDivPos_2 = Tank1_yPos2_Holder[9:5]%15;
									
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////         
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
										//Top left
										Tank1Array_1   = MapArray[Tank1_yDivPos_1];		   // This is the array for the map containing the 'bottom left#' of the tank
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
									
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////       
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
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
											Tank1_yPos = Pixels_Vert - TankWidth - (MoveSpeed + 1);
										else if (Tank1_yPos >= Pixels_Vert - TankWidth - EdgeWidth)
											Tank1_yPos = MoveSpeed + 1;

										//if x-coordinate is at screen limit, move to other side of screen
										else if (Tank1_xPos <= EdgeWidth + MoveSpeed)
											Tank1_xPos = Pixels_Horiz - TankWidth - (MoveSpeed + 1);
										else if (Tank1_xPos >= Pixels_Horiz - TankWidth - EdgeWidth)
											Tank1_xPos = MoveSpeed + 1;
											
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////        
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
										//If Tank1 has been shot
										else if (Tank1_Dead == 1)
											begin
												//Begin a 1s timer until position reset, preventing movement until timer ends
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
											//Tank1 moves up 1 pixel
											Tank1_yPos = Tank1_yPos - 1;
											
										//If left edges are in boundary
										else if (((Tank1Array_X_1 == 1) | (Tank1Array_X_1 == 2)) & ((Tank1Array_X_3 == 1) | (Tank1Array_X_3 == 2)))
											//Tank1 moves right 1 pixel
											Tank1_xPos = Tank1_xPos + 1;
												
										//if top edges are in boundary
										else if (((Tank1Array_X_1 == 1) | (Tank1Array_X_1 == 2)) & ((Tank1Array_X_2 == 1) | (Tank1Array_X_2 == 2)))
											//Tank1 moves down 1 pixel
											Tank1_yPos = Tank1_yPos + 1;
											
										// if right edges are in boundary
										else if (((Tank1Array_X_2 == 1) | (Tank1Array_X_2 == 2)) & ((Tank1Array_X_4 == 1) | (Tank1Array_X_4 == 2)))
											//Tank1 moves left 1 pixel
											Tank1_xPos = Tank1_xPos - 1;     
											                   
///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
//////////////////////////////////////////////////////////////////////////////////////////////////////////////        
										// if top left is in boundary
										else if ((Tank1Array_X_1 == 1) | (Tank1Array_X_1 == 2))
											begin
												//Move diagonally by #pixels dependent on movespeed
												Tank1_yPos = Tank1_yPos + MoveSpeed;
												Tank1_xPos = Tank1_xPos + MoveSpeed;
											end
											
										// if top right is in boundary	
										else if ((Tank1Array_X_2 == 1) | (Tank1Array_X_2 == 2))
											begin
												//Move diagonally by #pixels dependent on movespeed
												Tank1_yPos = Tank1_yPos + MoveSpeed;
												Tank1_xPos = Tank1_xPos - MoveSpeed;
											end	
											
										// if bottom left is in boundary	
										else if ((Tank1Array_X_3 == 1) | (Tank1Array_X_3 == 2))
											begin
												//Move diagonally by #pixels dependent on movespeed
												Tank1_yPos = Tank1_yPos - MoveSpeed;
												Tank1_xPos = Tank1_xPos + MoveSpeed;
											end	
											
										// if bottom right is in boundary	
										else if ((Tank1Array_X_4 == 1) | (Tank1Array_X_4 == 2))
											begin
												//Move diagonally by #pixels dependent on movespeed
												Tank1_yPos = Tank1_yPos - MoveSpeed;
												Tank1_xPos = Tank1_xPos - MoveSpeed;
											end
											
////////////////////////////////////////////////////////////////////////////////////////////////////////////////  
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
										//If Corners are in a 'Coin' block, 'pick up' block by setting MapArray value to 4'b0000 and add 1 to coin value
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
										//If no other conditions are met, move tank depending on buttons pressed.
										else
											begin 
												// Get movement speed from switch inputs
												MoveSpeed = 1 + MoveSpeed_0 + MoveSpeed_1 * 2;			
												
												//Set current direction and previous direction depending on direction.
												if (Up1 == 1)
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
										
										//If Tank1 has been shot
										else if (Tank2_Dead == 1)
											begin
												
												//Begin a 1s timer until position reset, preventing movement until timer ends
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
												
												//Move diagonally by #pixels dependent on movespeed
												Tank2_yPos = Tank2_yPos + MoveSpeed;
												Tank2_xPos = Tank2_xPos + MoveSpeed;
											end
										// if top right is in boundary	
										else if ((Tank2Array_X_2 == 1) | (Tank2Array_X_2 == 2))
											begin
											
												//Move diagonally by #pixels dependent on movespeed
												Tank2_yPos = Tank2_yPos + MoveSpeed;
												Tank2_xPos = Tank2_xPos - MoveSpeed;
											end	
										// if bottom left is in boundary	
										else if ((Tank2Array_X_3 == 1) | (Tank2Array_X_3 == 2))
											begin
											
												//Move diagonally by #pixels dependent on movespeed
												Tank2_yPos = Tank2_yPos - MoveSpeed;
												Tank2_xPos = Tank2_xPos + MoveSpeed;
											end	
										// if bottom right is in boundary	
										else if ((Tank2Array_X_4 == 1) | (Tank2Array_X_4 == 2))
											begin
											
												//Move diagonally by #pixels dependent on movespeed
												Tank2_yPos = Tank2_yPos - MoveSpeed;
												Tank2_xPos = Tank2_xPos - MoveSpeed;
											end	                      
	///////////////////////////////////////////////////////////////////////////////////////////////////////////////         
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
										
										//If any of the 4 corners are in a 'Coin' block, 'pick up' block by setting MapArray value to 4'b0000 and add 1 to coin value
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
										//If no other conditions are met, 
										else
											begin
											//Move depending on buttons pressed.
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
									
									//If Player deaths exceeds max value, reset game
									if((P1_Deaths >= Max_Deaths) | (P2_Deaths >= Max_Deaths))
										begin
											 Reset_Val = 1'b1;
										end
							

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////// 
								//within Tank1 bounding box, set image to tank
								if ((Val_Col_In >= Tank1_yPos) & (Val_Col_In <= Tank1_yPos + TankWidth) & (Val_Row_In >= Tank1_xPos) & (Val_Row_In <= Tank1_xPos + TankWidth))
									begin
										// If moving downwards, image is mirrored in x
										if (PrevDirection_1 == Down_Direction)    
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
										//If moving upwards, image is normal orientation
										else
											begin
												Tank1_XInput = Val_Row_In - Tank1_xPos;
												Tank1_YInput = Val_Col_In - Tank1_yPos;
											end	
										
										//If the tank is alive, show a tank image
										if (Tank1_Dead == 0)
											begin
												Red   = Colour_Data_Tank1[11:8];
												Green = Colour_Data_Tank1[ 7:4];
												Blue  = Colour_Data_Tank1[ 3:0];
											end
										//Else show an explosion image
										else
											begin
												Red   = Colour_Data_Explosion1[11:8];
												Green = Colour_Data_Explosion1[ 7:4];                                        
												Blue  = Colour_Data_Explosion1[ 3:0];  
											end  
									end

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////                               
								
							  	//within Tank2 bounding box, set image to tank
								else if ((Val_Col_In >= Tank2_yPos) & (Val_Col_In <= Tank2_yPos + TankWidth) & (Val_Row_In >= Tank2_xPos) & (Val_Row_In <= Tank2_xPos + TankWidth))
									begin

										// If moving downwards, image is mirrored in x
										if (PrevDirection_2 == Down_Direction)    
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
										//If moving upwards, image is normal orientation
										else
											begin
												Tank2_XInput = Val_Row_In - Tank2_xPos;
												Tank2_YInput = Val_Col_In - Tank2_yPos;
											end
										
										//If the tank is alive, show a tank image
										if (Tank2_Dead == 0)
											begin
												Green = Colour_Data_Tank2[11:8]; //To change the colour of the tank, the Green and Red colour
												Red   = Colour_Data_Tank2[ 7:4]; //		for each pixel is swapped.
												Blue  = Colour_Data_Tank2[ 3:0]; 
											end
											
										//Else show an explosion image
										else
											begin
												Red     = Colour_Data_Explosion1[11:8];
												Green   = Colour_Data_Explosion1[ 7:4];                                        
												Blue    = Colour_Data_Explosion1[ 3:0];  
											end 
									end
	//////////////////////////////////////////////////////////////////////////////////////////////////////////////
	////////////////////////////////////////////////////////////////////////////////////////////////////////////// 							
								//Bullet Draw
								//If Bullet1 in motion, draw green bullet in defined range
								else if (((Val_Col_In >= Bullet1_YInput - BulletWidth/2) & (Val_Col_In <= Bullet1_YInput + BulletWidth/2))
									   & ((Val_Row_In >= Bullet1_XInput - BulletWidth/2) & (Val_Row_In <= Bullet1_XInput + BulletWidth/2))
									   &  (Bullet1_Fired == 1))
									begin
										Red 	= 4'h0;
										Green 	= 4'h8; 
										Blue 	= 4'h0;
									end
									
								//If Bullet2 in motion, draw red bullet in defined range
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
									
										MapArrayData_Y   = MapArray[yDivPos];				// This is the array for the map containing
										MapArrayData_X_3 = MapArrayData_Y[4*xDivPos    ];   // This is bit 3 of [3:0] of the map colour array
										MapArrayData_X_2 = MapArrayData_Y[4*xDivPos + 1];   // This is bit 2 of [3:0] of the map colour array
										MapArrayData_X_1 = MapArrayData_Y[4*xDivPos + 2];   // This is bit 1 of [3:0] of the map colour array
										MapArrayData_X_0 = MapArrayData_Y[4*xDivPos + 3];   // This is bit 0 of [3:0] of the map colour array
									
										// Concatenate all 4 bits of the map 
										MapArray_X = {MapArrayData_X_3, MapArrayData_X_2, MapArrayData_X_1, MapArrayData_X_0 };  
									
										case (MapArray_X)
											
											//Code for empty block
											4'h0:begin  Red   = 4'hF; 
														Green = 4'hF; 
														Blue  = 4'hF;
												end
											
											// Code for unbreakable blocks
											4'h1:begin 	Red   = Colour_Data_Solid_Block[11:8];
														Green = Colour_Data_Solid_Block[ 7:4];
														Blue  = Colour_Data_Solid_Block[ 3:0];
												 end
											 
											// Code for breakable brick
											4'h2:begin  Red   = Colour_Data_Brick[11:8];
														Green = Colour_Data_Brick[ 7:4];
														Blue  = Colour_Data_Brick[ 3:0];
												 end	
											 
											// Code what option coin blocka are set to
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
										
											// Placeholders for additional map blocks
											4'h4:     begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
											4'h5:     begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
											4'h6:     begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
											4'h7:     begin	Red = 4'hF; Green = 4'h4; Blue = 4'h4; end
										
											// Default to black background
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
