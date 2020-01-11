//Defining constants for referencing
parameter [2:0] Up_Direction	= 3'h1;
parameter [2:0] Down_Direction	= 3'h2;
parameter [2:0] Left_Direction	= 3'h3;
parameter [2:0] Right_Direction	= 3'h4;

//Logging 'Fire' key
reg Fire1_Prev = 1'b0;
reg Fire1_Enable = 1'b0;

//Defining point on map
reg [0:79] Bullet1_YArray = 80'b0;
reg Bullet1_XArray3, Bullet1_XArray2, Bullet1_XArray1, Bullet1_XArray0 = 1'b0;
reg [3:0] XArray = 4'b0;

//Defining Bullet1 Coordinates
reg [9:0] Bullet1_xInput, Bullet1_yInput = 10'b0;
reg [5:0] Bullet1_yPos_Div, Bullet1_xPos_Div = 1'b0;
reg [2:0] Bullet1_Direction = 3'b0;

//Defining Tank2 Variables
reg [9:0] Tank2_yPos, Tank2_xPos = 10'b0;
reg [1:0] Tank2_Colour = 2'b0; //Where 0 is normal, 1 is boom, 2 is white to show respawn (will flick between 0 and 2)
reg [5:0] Tank2_RespawnCounter = 6'b0;


//Defining controls for death

always @(posedge Master_Clock_In)
begin
	//if condition - Rising edge of 'Fire1 button' and then 'Fire1_Enable' to make sure
	//		this code only runs to initialise settings
	if (Fire1_Enable == 1)
		begin
			Bullet1_xPosDiv = Bullet1_xInput[9:5]%20;
			Bullet1_yPosDiv = Bullet1_yInput[9:5]%15;

			Bullet1_YArray = MapArray[Bullet1_yPos_Div]
			Bullet1_XArray3 = Bullet1_YArray[4 * Bullet1_xPos_Div  ];
			Bullet1_XArray2 = Bullet1_YArray[4 * Bullet1_xPos_Div+1];
			Bullet1_XArray1 = Bullet1_YArray[4 * Bullet1_xPos_Div+2];
			Bullet1_XArray0 = Bullet1_YArray[4 * Bullet1_xPos_Div+3];
			Bullet1_XArray 	= {Bullet1_XArray3, Bullet1_XArray2, Bullet1_XArray1, Bullet1_XArray1};

			if (Bullet1_XArray == 1)
				begin
					Fire1_Enable 	= 1'b0;
					Bullet1_xInput 	= 10'd16;
					Bullet1_yInput 	= 10'd16;					
				end
	
			if (Bullet1_XArray == 2)
				begin
					Fire1_Enable = 1'b0;
					Bullet1_xInput = 10'd16;
					Bullet1_yInput = 10'd16;
					
					MapArray[Bullet1_yPos_Div][Bullet1_xPos_Div * 4  ] = 1'b0;
					MapArray[Bullet1_yPos_Div][Bullet1_xPos_Div * 4+1] = 1'b0;
					MapArray[Bullet1_yPos_Div][Bullet1_xPos_Div * 4+2] = 1'b0;
					MapArray[Bullet1_yPos_Div][Bullet1_xPos_Div * 4+3] = 1'b0;
					
				end

		end
				//if (Bullet1_yPos_Div = 
			// Need variables for tank2 here, and copy all these with Bullet2 and use tank1 variables
			//	I'm going to write the code here but I;m not chekcing it, and I'm gonna comment it all
			// 	out until the bullets actual break the fuckin blocks.

	else if (((Bullet1_xInput >= Tank2_xPos)  & (Bullet1_xInput <= Tank2_xPos + TankWidth))
	  	   & ((Bullet1_yInput >= Tank2_yPos)  & (Bullet1_yInput <= Tank2_yPos + TankWidth)))
		begin
			//show boom
			Tank2_Colour = 2'b1;
			if (Tank2_RespawnCounter = 30)
				begin
					Tank2_RespawnCounter = 6'b0;
										
					Tank2_xInput = Pixels_Horiz - TankWidth - 4;
					Tank2_yInput = Pixels_Vert  - TankWidth - 4;	
					
					Fire1_Enable = 0;	
					Bullet1_xInput = 10'd16;
					Bullet1_yInput = 10'd16;
				end
			else
				Ta
				
				
				
		end
	else if ((Fire1_Prev == 0) & (Fire1 == 1) & (Fire1_Enable == 0))
		begin
			Fire1_Enable == 1'b1;
			Bullet1_Direction = Prev_Direction;
			
			case (Bullet_Dir_1)
				Up_Direction:
					begin
						Bullet1_xInput = Tank1_xPos + (BulletWidth + 3);
						Bullet1_yInput = Tank1_yPos - (BulletWidth + 3);
					end
				
				Down_Direction:
					begin
						Bullet1_xInput = Tank1_xPos + (BulletWidth + 3);
						Bullet1_yInput = Tank1_yPos + (BulletWidth + 3) + TankWidth;
					end
				
				Left_Direction:
					begin
						Bullet1_xInput = Tank1_xPos - (BulletWidth + 3);
						Bullet1_yInput = Tank1_yPos + (BulletWidth + 3);
					end
				
				Right_Direction:
					begin
						Bullet1_xInput = Tank1_xPos + (BulletWidth + 3) + TankWidth;
						Bullet1_yInput = Tank1_yPos - (BulletWidth + 3) + TankWidth;
					end
				
				default: Fire1_Enable = 1'b0;
			endcase
		end
		
	
	
	
end