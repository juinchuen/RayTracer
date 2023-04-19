`timescale 1ns/10ps

module cross(out, x, y);

    input signed [31:0] x [2:0];
    input signed [31:0] y [2:0];
    
    output signed [31:0] out [2:0];

    logic signed [47:0] out_big [2:0];

    assign out_big[0] = (x[1] * y[2] - x[2] * y[1]) >> 16;
    assign out_big[1] = (x[2] * y[0] - x[0] * y[2]) >> 16;
    assign out_big[2] = (x[0] * y[1] - x[1] * y[0]) >> 16;

    assign out[0] = out_big[0];
    assign out[1] = out_big[1];    
    assign out[2] = out_big[2];

endmodule

module dot(out, x, y);
   
    input signed [31:0] x [2:0];
    input signed [31:0] y [2:0];
    
    output signed [31:0] out [2:0];

	logic signed [47:0] out_big [2:0];

	assign out_big[0] = (x[0] * y[0]) >> 16;
	assign out_big[1] = (x[1] * y[1]) >> 16;
	assign out_big[2] = (x[2] * y[2]) >> 16;

	assign out = out_big[0] + out_big[1] + out_big[2];

endmodule

module scale(out, x, a);

    input signed [31:0] x [2:0];

    output signed [31:0] out [2:0];

	logic signed [47:0] out_big [2:0]
	
	assign out_big[0] = (x[0] * a) >> 16;
	assign out_big[1] = (x[1] * a) >> 16;
	assign out_big[2] = (x[2] * a) >> 16;

	assign out[0] = out0_big;
	assign out[1] = out1_big;
	assign out[2] = out2_big;

endmodule

module add(out, x, y);

    input signed [31:0] x [2:0];
    input signed [31:0] y [2:0];
    
    output signed [31:0] out [2:0];

	assign out[0] = x[0] + y[0];
	assign out[1] = x[1] + y[1];
	assign out[2] = x[2] + y[2];
	
endmodule

module subtract(out0, out1, out2, x0, x1, x2, y0, y1, y2);

    input signed [31:0] x [2:0];
    input signed [31:0] y [2:0];
    
    output signed [31:0] out [2:0];

	assign out[0] = x[0] - y[0];
	assign out[1] = x[1] - y[1];
	assign out[2] = x[2] - y[2];
	
endmodule