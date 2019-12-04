// Code your testbench here
// or browse Examples

`timescale 1ns/100ps

module Testbench();
  
  reg Clock = 1'b0;
  reg Keyb_clk = 1'b0;
  reg kdata = 1'b0;
  reg [4:0] p1keys;
  reg [4:0] p2keys;
  reg [7:0] debugLEDs;
  
  reg [0:7] Keypress = 8'h75;
  reg [7:0] ii = 8'b0;
  
//  PS2Receiver UUT (.clk(Clock), .keyb_clk(Keyb_clk), .kdata(kdata), .p1keys(p1keys), 
//                   .p2keys(p2keys), .debugLEDs(debugLEDs));
  

  always
  	#5 Clock = ~Clock;
  
  
  initial
    begin
      Clock = 1'b0;
      Keyb_clk = 1'b0;
      kdata = 1'b0;
    end
  
  always
    begin
      #1000
      
      for (ii=0; ii<8; ii=ii+1)
      	begin
          #100
          Keyb_clk = 1'b1;
          kdata = Keypress[ii];
          #100
          Keyb_clk = 1'b0;
        end
      
      
      
      
    end


endmodule
