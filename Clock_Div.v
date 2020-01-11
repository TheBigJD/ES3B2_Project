/////////////////////////////////////////////////////////////////////////////
//Clock divisor module. Divides 100MHz clock to 25MHz
/////////////////////////////////////////////////////////////////////////////

module Clock_Div(
        input Master_Clock_In,                      //100MHz in
        output Clock_Out                            //25MHz out
    );
    
    reg [2:0] Clock_Counter = 4'd0;                 //
    reg Clock = 0;
    
    always @(posedge   Master_Clock_In)
    begin
        if (Clock_Counter == 1)
            begin
                Clock_Counter = 0;
                Clock = ~(Clock);
            end
        else
            Clock_Counter <= Clock_Counter + 1'b1;
    end
            
     assign Clock_Out = Clock;
       
endmodule
