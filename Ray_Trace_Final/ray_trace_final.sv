module ray_trace_final(
	
	input logic reset,
	
	input logic clock_fast,
	
	output logic [7:0] led
	
);

	logic [7:0] pixel [2:0];
	
	logic out_wr_en;
	
	assign led[7] = out_wr_en;
	
	assign led[6:0] = pixel[0][6:0];

	wrapper_top WT0 (
	
		.clock		(clock_fast),
		.reset		(reset),

		.out_wr_en	(out_wr_en),
		.pixel		(pixel)
	 
	 );

endmodule