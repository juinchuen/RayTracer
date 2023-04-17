`timescale 1ns/10ps

module cross(out, x, y);

    input [95:0] x;
    input [95:0] y;

    output [95:0] out;

    assign out[31:0 ] = (x[63:32] * y[95:64] - x[95:64] * y[63:32]) >> 16;
    assign out[63:32] = (x[95:64] * y[31:0 ] - x[31:0 ] * y[95:64]) >> 16;
    assign out[95:64] = (x[31:0 ] * y[63:32] - x[63:32] * y[31:0 ]) >> 16;

endmodule

module dot(out, x, y);
   
	input [95:0] x;
	input [95:0] y;

	wire signed [31:0] x0, x1, x2;
	wire signed [31:0] y0, y1, y2;

	assign x0 = x[31:0 ];
	assign x1 = x[63:32];
	assign x2 = x[95:64];

	assign y0 = y[31:0 ];
	assign y1 = y[63:32];
	assign y2 = y[95:64];

	output signed [31:0] out;

	wire signed [63:0] a;
	wire signed [63:0] b;
	wire signed [63:0] c;

	assign a = (x0 * y0) >> 16;
	assign b = (x1 * y1) >> 16;
	assign c = (x2 * y2) >> 16;


	assign out = a + b + c;

endmodule

module scale(out, x, a);

	input [95:0] x;
	input signed [31:0] a;

	wire signed [31:0] x0;
	wire signed [31:0] x1;
	wire signed [31:0] x2;

	wire signed [63:0] out0;
	wire signed [63:0] out1;
	wire signed [63:0] out2;

	assign x0 = x[31:0];
	assign x1 = x[63:32];
	assign x2 = x[95:64];

	output [95:0] out;

	assign out0 = x0 * a;
	assign out1 = x1 * a;
	assign out2 = x2 * a;

	assign out[31:0 ] = out0 >> 16;
	assign out[63:32] = out1 >> 16;
	assign out[95:64] = out2 >> 16;

endmodule

module add(out, x, y);

	input [95:0] x;
	input [95:0] y;

	output [95:0] out;

	assign out[31:0 ] = x[31:0 ] + y[31:0 ];
	assign out[63:32] = x[63:32] + y[63:32];
	assign out[95:64] = x[95:64] + y[95:64];
	
endmodule
