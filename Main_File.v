module Main_File( input Master_Clock_In, Reset_N_In,
                  //input BTNU, BTND, BTNL, BTNR,
                  
                  input PS2_CLK,
                  input PS2_DATA,
                  output [2:0]LED, // LED outputs show directions of keys pressed for player 1
                  output [2:0]LED2, // LED outputs show directions of keys pressed for player 2
                  
                  output [3:0] Main_Red_Out, Main_Green_Out, Main_Blue_Out,
                  output Sync_Horiz_Out, Sync_Vert_Out);
                  
    reg CLK50MHZ = 0;
    
    always @(posedge(Master_Clock_In))
    begin
        CLK50MHZ<=~CLK50MHZ;
    end
    
   wire Clock_25MHz;
   wire Disp_Enable;
   wire [9:0] Val_Column, Val_Row;
   wire up, down, left, right; // directions from keyboard
   
   Clock_Div M1 (
    .Master_Clock_In(Master_Clock_In), .Clock_Out(Clock_25MHz)); 
   
   VGA_Control M2(
        .Master_Clock_In(Clock_25MHz), .Reset_N_In(Reset_N_In), 	
        .Sync_Horiz_Out(Sync_Horiz_Out), .Sync_Vert_Out(Sync_Vert_Out),	
        .Disp_Ena_Out(Disp_Enable), 
        .Val_Col_Out(Val_Column), .Val_Row_Out(Val_Row));
        
    PS2Receiver keyboard(
        .clk(CLK50MHZ),
        .keyb_clk(PS2_CLK),
        .kdata(PS2_DATA),
        .p1keys(LED[2:0]),
        .p2keys(LED2[2:0]),
        .U(up), 
        .D(down),
        .L(left),
        .R(right)
        );
        
        
            
    VGA_Draw M3(
    	.Master_Clock_In(Clock_25MHz), .Reset_N_In(Reset_N_In),
    	.Up(up), .Down(down), .Left(left), .Right(right),
        .Disp_Ena_In(Disp_Enable),
	    .Val_Col_In(Val_Column), .Val_Row_In(Val_Row),
	    .Red(Main_Red_Out), .Blue(Main_Blue_Out), .Green(Main_Green_Out));
	   
        
endmodule
        
        
        
        
        
