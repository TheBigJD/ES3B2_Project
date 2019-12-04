module Main_File( input Master_Clock_In, Reset_N_In,
                  input Up, Down, Left, Right, Fire,
                  input PS2_CLK, PS2_DATA, // provisional keyboard inputs
                  input ColourSwitch_1,
                  input MoveSpeed_1, MoveSpeed_0,
                  input LevelSwitch_2, LevelSwitch_1, LevelSwitch_0,
                  
                  //output Debug_led, // TODO remove
                  
                  output [3:0] Main_Red_Out, Main_Green_Out, Main_Blue_Out,
                  output Sync_Horiz_Out, Sync_Vert_Out,
                  
                  output LED1_R, LED1_G, LED1_B, LED2_R, LED2_G, LED2_B, 
                  
                  output a, b, c, d, e, f, g,
                  output [7:0] an,
                  output [3:0]LED, [3:0]LED2 //provisional keyboard inputs
                  
            	);
   
   wire Clock_25MHz;
   wire Disp_Enable;
   wire [9:0] Val_Column, Val_Row;
   
   wire [7:0] Coins_1, Coins_2;
   wire [3:0]  sevSeg_5 = 4'b0, 
               sevSeg_4 = 4'b0, 
               sevSeg_3 = 4'b0, 
               sevSeg_2 = 4'b0, 
               sevSeg_1 = 4'b0, 
               sevSeg_0 = 4'b0;
               

               
   //wire Up1, Down1, Left1, Right1, Fire1; //Provisional keyboard wires for p1
   //wire Up2, Down2, Left2, Right2, Fire2; //Provisional keyboard wires for p2
   wire [4:0] p1keys, p2keys;
   wire [7:0] P1_Deaths, P2_Deaths;
   
   
   
   
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
        
        .Up1(p1keys[0]), .Down1(p1keys[3]), .Left1(p1keys[1]), .Right1(p1keys[2]), .Fire1(p1keys[4]),
        .Up2(Up), .Down2(Down), .Left2(Left), .Right2(Right), .Fire2(Fire),        
        
        .ColourSwitch_1(ColourSwitch_1),
        .LevelSwitch_2(LevelSwitch_2), .LevelSwitch_1(LevelSwitch_1), .LevelSwitch_0(LevelSwitch_0), 
        .MoveSpeed_1(MoveSpeed_1), .MoveSpeed_0(MoveSpeed_0),
        
       // .debug_led(Debug_led),
        
        
        .Disp_Ena_In(Disp_Enable), .Val_Col_In(Val_Column), .Val_Row_In(Val_Row),
        .Red(Main_Red_Out), .Blue(Main_Blue_Out), .Green(Main_Green_Out),
        
        .P1_Deaths(P1_Deaths), .P2_Deaths(P2_Deaths),
        
        .CoinValue_1(Coins_1[7:0]), .CoinValue_2(Coins_2[7:0])
    );
    
	PS2Receiver M4 // provisional keyboard driver
	(
	   .clk(Clock_25MHz),
	   .keyb_clk(PS2_CLK),
	   .kdata(PS2_DATA),
	   .p1keys(p1keys),
	   .p2keys(p2keys),
	   .debugLEDs({LED, LED2})
//	   .U(Up),
//	   .D(Down),
//	   .L(Left),
//	   .R(Right),
//	   .F(Fire)
	
	);
	
	ColourLED_Control M5
	(
	   .LED1(Coins_1[2:0]), .LED2(Coins_2[2:0]),
	   .LED1_R(LED1_R), .LED1_G(LED1_G), .LED1_B(LED1_B), 
	   .LED2_R(LED2_R), .LED2_G(LED2_G), .LED2_B(LED2_B) 
	);
	
	   
	   
	seginterface M6 
	(
		.clk(Clock_25MHz), .rst(Reset_N_In),
		
	    .dig7(Coins_1[7:4]), .dig6(Coins_1[3:0]), .dig5(P1_Deaths[7:4]), .dig4(P1_Deaths[3:0]),
	 	.dig3(Coins_2[7:4]), .dig2(Coins_2[3:0]), .dig1(P2_Deaths[7:4]), .dig0(P2_Deaths[3:0]),

		.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
		.an(an)
	
	);   
	   
	
        
endmodule
        
        
        
        
        
