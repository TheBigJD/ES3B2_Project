////////////////////////////////////////////////////////////////////////////////////////
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

////Instantiating module to test, connecting driven inputs to TB code and outputting to
//		reg values to show outputs.

	PS2Receiver UUT ( 	.clk(Clock),
						.keyb_clk(Keyb_clk), 
						.kdata(kdata), 
						.p1keys(p1keys), 
						.p2keys(p2keys), 
						.debugLEDs(debugLEDs)
					);
////////////////////////////////////////////////////////////////////////////////////////  
//Clock generator - clock inverts every 5ns to give 25MHz clock
	always
		#40 Clock = ~Clock;

//////////////////////////////////////////////////////////////////////////////////////// 
//initial statement - runs only once at start of code
	initial
		begin
			Clock 		= 1'b0; //setting low to begin clock logic
			Keyb_clk 	= 1'b0;	//initial simulated keyboard clock = 1'b0
			kdata 		= 1'b0;	//initial simulated keyboard data  = 1'b0
		end

////////////////////////////////////////////////////////////////////////////////////////  
//
	always
		begin
			#1000 //Code waits for 1000 clock cycles, 10us, before beginning simulation
			
			//for loop generates keyboard clock and outputs data giving data output of 'Keypress', 
			//		
			for (ii=0; ii<8; ii=ii+1)
				begin
					//Wait
					#1000
					
					//Rise clock, change data
					Keyb_clk 	= 1'b1;
					kdata 		= Keypress[ii];
					
					//Wait
					#1000
					
					//Lower clock
					Keyb_clk = 1'b0;
				end
			end
////////////////////////////////////////////////////////////////////////////////////////
endmodule

