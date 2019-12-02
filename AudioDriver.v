module AudioPlayback(
	input Master_Clock_In, Master_Reset_N_In,
	
	output Signal = 1'b0
		
);

parameter [10:0] SamplingFreq = 11'd22050; 
reg [10:0] SamplingClockDiv = 11'b0;

reg [15:0] SampleCount = 16'b0;



always @(posedge Master_Clock_In)
	begin
		if Master_Reset_N_In == 0)
			begin
				SamplingClockDiv = 11'b0;			
				Signal = 1'b0;

			end
		else
			begin
				if (SamplingClockDiv == SamplingFreq)
					begin
						SampleCount = (SampleCount + 1) % 65536
					
					end
				else
					SamplingClockDiv = SamplingClockDiv + 1;
			end	

		case (SampleCount)
			0: Signal = 1'b0;
			1: Signal = 1'b0;
//so on and so on...
//~Case statement contains soud file in binary.
		endcase
	end
	
	
endmodule   