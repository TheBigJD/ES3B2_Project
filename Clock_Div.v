/////////////////////////////////////////////////////////////////////////////
//Clock divisor module. Divides 100MHz clock to 25MHz
/////////////////////////////////////////////////////////////////////////////

module Clock_Div(
        input Master_Clock_In,                      //100MHz in
        output Clock_Out                            //25MHz out
    );
    
    reg [1:0] Clock_Counter = 2'd0;                 //Setup 2-bit counter
    reg Clock = 0;                                  //Initialise output value to zero
    
    always @(posedge   Master_Clock_In)             //Triggered on rising edge
    begin
        if (Clock_Counter == 1)			    // When two clock cycles have passed
            begin
                Clock_Counter = 0;                  //Reset counter    
                Clock = ~(Clock);                   //Invert output
            end
        else
            Clock_Counter <= Clock_Counter + 1'b1;  //Otherwise increment counter
    end
            
     assign Clock_Out = Clock;
       
endmodule
