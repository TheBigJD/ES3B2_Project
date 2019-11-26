module Main_File( input Master_Clock_In, Reset_N_In,
                  input BTNU, BTND, BTNL, BTNR,
                  output [3:0] Main_Red_Out, Main_Green_Out, Main_Blue_Out,
                  output Sync_Horiz_Out, Sync_Vert_Out);
   
   wire Clock_25MHz;
   wire Disp_Enable;
   wire [9:0] Val_Column, Val_Row;
   
   Clock_Div M1 (
    .Master_Clock_In(Master_Clock_In), .Clock_Out(Clock_25MHz)); 
   
   VGA_Control M2(
        .Master_Clock_In(Clock_25MHz), .Reset_N_In(Reset_N_In), 	
        .Sync_Horiz_Out(Sync_Horiz_Out), .Sync_Vert_Out(Sync_Vert_Out),	
        .Disp_Ena_Out(Disp_Enable), 
        .Val_Col_Out(Val_Column), .Val_Row_Out(Val_Row));
            
    VGA_Draw M3(
    	.Master_Clock_In(Clock_25MHz), .Reset_N_In(Reset_N_In),
    	.Up(BTNU), .Down(BTND), .Left(BTNL), .Right(BTNR),
        .Disp_Ena_In(Disp_Enable),
	    .Val_Col_In(Val_Column), .Val_Row_In(Val_Row),
	    .Red(Main_Red_Out), .Blue(Main_Blue_Out), .Green(Main_Green_Out));
	   
        
endmodule
        
        
        
        
        
