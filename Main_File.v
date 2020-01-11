/////////////////////////////////////////////////////////////////////////////
//Top module. With a few exceptions, all other modules are instantiated here.
/////////////////////////////////////////////////////////////////////////////

module Main_File( input Master_Clock_In,                                    // On-board generated 100MHz clock input
                  input Reset_N_In,                                         // Switch to reset game logic. Used after programming and when switching maps
                  input Up, Down, Left, Right, Fire,                        // Player1 control inputs, 5 buttons on FPGA
                  input PS2_CLK,                                            // 10-30kHz input clock from keyboard
                  input PS2_DATA,                                           // Data line from keyboard clock
                  
                  input ColourSwitch_1,                                     // Switch to change between sprites for coins
                  input MoveSpeed_1, MoveSpeed_0,                           // Switches to select tank movement speed (4 options)
                  input LevelSwitch_2, LevelSwitch_1, LevelSwitch_0,        // Switches to select different levels (8 options)                     
                                             
                  output [3:0] Main_Red_Out, Main_Green_Out, Main_Blue_Out, // 4-bit VGA colour outputs
                  output Sync_Horiz_Out, Sync_Vert_Out,                     // VGA vertical & horizontal control lines
                  
                  output LED1_R, LED1_G, LED1_B, LED2_R, LED2_G, LED2_B,    // Ouputs to on-board RGB LEDs for player 1 and player 2
                  
                  output a, b, c, d, e, f, g,                               // Seven segment character LED outputs
                  output [7:0] an,                                          // Seven segment output enable (for 2x4-digit displays)
                  
                  output [3:0]LED, [3:0]LED2                                // 2x4-bit LED arrays to show keyboard scan codes
                  
            	);
   
   // Instantiating wires to connect signals between modules
   wire Clock_25MHz;                // Wire from Clock_Div module
   wire Disp_Enable;                // Wire from VGA controller
   wire [9:0] Val_Column, Val_Row;  // Wires from VGA controller
   
   wire [7:0] Coins_1, Coins_2;     // Wire from Game_logic
   
   wire [3:0]  sevSeg_5 = 4'b0,     // Wires from Game_logic         
               sevSeg_4 = 4'b0, 
               sevSeg_3 = 4'b0, 
               sevSeg_2 = 4'b0, 
               sevSeg_1 = 4'b0, 
               sevSeg_0 = 4'b0;               
               
   wire [4:0] p1keys, p2keys;       // Wires from keyboard input
   wire [7:0] P1_Deaths, P2_Deaths; // Wires from Game_logic
   
   
   
   // Clock divisor module, scales clock from 100MHz input to 25MHz output
    Clock_Div M1
    (
        .Master_Clock_In(Master_Clock_In),
        .Clock_Out(Clock_25MHz)
    ); 

    // VGA_Control module, outputs control signals for VGA display output
    VGA_Control M2 
    (
        .Master_Clock_In(Clock_25MHz), .Reset_N_In(Reset_N_In), 	
        
        .Sync_Horiz_Out(Sync_Horiz_Out), .Sync_Vert_Out(Sync_Vert_Out),	
        
        .Disp_Ena_Out(Disp_Enable), 
        .Val_Col_Out(Val_Column), .Val_Row_Out(Val_Row)
    );
        
    // Main control logic. Decides what to output on VGA; handles boundaries; bullets; collisions; reset conditions;
    // LED / seven-segment values; and everything else not covered in other instantiated modules
    VGA_Draw M3
    (
        .Master_Clock_In(Clock_25MHz), .Reset_N_In(Reset_N_In),
        
        .Up1(p1keys[0]), .Down1(p1keys[3]), .Left1(p1keys[1]), .Right1(p1keys[2]), .Fire1(p1keys[4]),
        .Up2(Up), .Down2(Down), .Left2(Left), .Right2(Right), .Fire2(Fire),        
        
        .ColourSwitch_1(ColourSwitch_1),
        .LevelSwitch_2(LevelSwitch_2), .LevelSwitch_1(LevelSwitch_1), .LevelSwitch_0(LevelSwitch_0), 
        .MoveSpeed_1(MoveSpeed_1), .MoveSpeed_0(MoveSpeed_0),
                           
        .Disp_Ena_In(Disp_Enable), .Val_Col_In(Val_Column), .Val_Row_In(Val_Row),
        .Red(Main_Red_Out), .Blue(Main_Blue_Out), .Green(Main_Green_Out),
        
        .P1_Deaths(P1_Deaths), .P2_Deaths(P2_Deaths),
        
        .CoinValue_1(Coins_1[7:0]), .CoinValue_2(Coins_2[7:0])
    );
    
    // PS/2 Keyboard driver. Keyboard outputs its own clock line and data line, needs to be debounced, and scan codes from keys 
    // need to be processed into characters. Module outputs the key scan code (8-bit) to 2x4-bit blocks of LEDs. P2 keys not used currently.
	PS2Receiver M4 
	(
	   .clk(Clock_25MHz),
	   .keyb_clk(PS2_CLK),
	   .kdata(PS2_DATA),
	   .p1keys(p1keys),
	   .p2keys(p2keys),
	   .debugLEDs({LED, LED2})
	
	);
	
	// Module to control 2x RGB LEDs on FPGA (one for each player). Takes coin counters from game logic as 
	// inputs and decides colour value for each LED based on this.
	ColourLED_Control M5
	(
	   .LED1(Coins_1[2:0]), .LED2(Coins_2[2:0]),
	   .LED1_R(LED1_R), .LED1_G(LED1_G), .LED1_B(LED1_B), 
	   .LED2_R(LED2_R), .LED2_G(LED2_G), .LED2_B(LED2_B) 
	);
	
	   
	// Driver for seven-segment displays on FPGA. Takes coin counters and death counters for each player and displays
	// on seven segment display.    
	seginterface M6 
	(
		.clk(Clock_25MHz), .rst(Reset_N_In),
		
	    .dig7(Coins_1[7:4]), .dig6(Coins_1[3:0]), .dig5(P1_Deaths[7:4]), .dig4(P1_Deaths[3:0]),
	 	.dig3(Coins_2[7:4]), .dig2(Coins_2[3:0]), .dig1(P2_Deaths[7:4]), .dig0(P2_Deaths[3:0]),

		.a(a), .b(b), .c(c), .d(d), .e(e), .f(f), .g(g),
		.an(an)
	
	);   
	   
	
        
endmodule
        
        
        
        
        
