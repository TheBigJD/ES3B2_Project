module Main_File( input Master_Clock_In, Reset_N_In,
                  input Up, Down, Left, Right, Fire,
                  //input PS2?CLK, PS2_DATA, // provisional keyboard inputs
                  input ColourSwitch_1,
                  input MoveSpeed_1, MoveSpeed_0,
                  input LevelSwitch_1, LevelSwitch_0,
                  
                  output Debug_led, // TODO remove
                  
                  output [3:0] Main_Red_Out, Main_Green_Out, Main_Blue_Out,
                  output Sync_Horiz_Out, Sync_Vert_Out,
                  
                  output a, b, c, d, e, f, g,
                  output [7:0] an
                  //output LED[2:0], LED2[2:0] //provisional keyboard inputs
                  
            	);
   
   wire Clock_25MHz;
   wire Disp_Enable;
   wire [9:0] Val_Column, Val_Row;
   
   wire [7:0] Coins;
   wire [3:0]  sevSeg_5 = 4'b0, 
               sevSeg_4 = 4'b0, 
               sevSeg_3 = 4'b0, 
               sevSeg_2 = 4'b0, 
               sevSeg_1 = 4'b0, 
               sevSeg_0 = 4'b0;
               

               
   // wire up, down, left, right; //Provisional keyboard wires
   
   
    Clock_Div M1
    (
        .Master_Clock_In(Master_Clock_In),
        .Clock_Out(Clock_25MHz)
    ); 

    VGA_Control M2 
    (
        .Master_Clock_In(Clock_25MHz), .Reset_N_In(Reset_N_In), 	
        
        .Sync_Horiz_Out(Sync_Horiz_Out), .Sync_Vert_Out(Sync_Vert_Out),	
        
        .Disp_Ena_Out(Disp_Enable), 
        .Val_Col_Out(Val_Column), .Val_Row_Out(Val_Row)
    );
        
    VGA_Draw M3
    (
        .Master_Clock_In(Clock_25MHz), .Reset_N_In(Reset_N_In),
        
        .Up(Up), .Down(Down), .Left(Left), .Right(Right), .Fire(Fire),
        
        .ColourSwitch_1(ColourSwitch_1),
        .LevelSwitch_1(LevelSwitch_1), .LevelSwitch_0(LevelSwitch_0),
        .MoveSpeed_1(MoveSpeed_1), .MoveSpeed_0(MoveSpeed_0),
        
        .debug_led(Debug_led),
        
        
        .Disp_Ena_In(Disp_Enable), .Val_Col_In(Val_Column), .Val_Row_In(Val_Row),
        .Red(Main_Red_Out), .Blue(Main_Blue_Out), .Green(Main_Green_Out),
        
        .CoinValue(Coins[7:0])
    );
    
//	PS2Receiver M4 // provisional keyboard driver
//	(
//	   .clk(Clock_25MHz),
//	   .keyb_clk(PS2_CLK),
//	   .kdata(PS2_DATA),
//	   .p1keys(LED[2:0]),
//	   .p2keys(LED2[2:0]),
//	   .U(up),
//	   .D(down),
//	   .L(left),
//	   .R(right)
	
//	);
	   
	   
	seginterface M5 
	(
		.clk(Clock_25MHz), .rst(Reset_N_In),
		
	    .dig7(Coins[7:4]), .dig6(Coins[3:0]), .dig5(sevSeg_5), .dig4(sevSeg_4),
	 	.dig3(sevSeg_3), .dig2(sevSeg_2), .dig1(sevSeg_1), .dig0(sevSeg_0),

		.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
		.an(an)
	
	);   
	   
	
        
endmodule
        
        
        
        
        
