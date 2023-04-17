`timescale 1ns/10ps

module cross(out0, out1, out2, x0, x1, x2, y0, y1, y2);

    input signed [31:0] x0;
    input signed [31:0] x1;
    input signed [31:0] x2;

    input signed [31:0] y0;
    input signed [31:0] y1;
    input signed [31:0] y2;

    output signed [31:0] out0;
    output signed [31:0] out1;
    output signed [31:0] out2;

    assign out0 = (x1 * y2 - x2 * y1) >> 16;
    assign out1 = (x2 * y0 - x0 * y2) >> 16;
    assign out2 = (x0 * y1 - x1 * y0) >> 16;

endmodule

module dot(out0, out1, out2, x0, x1, x2, y0, y1, y2);
   

    input signed [31:0] x0;
    input signed [31:0] x1;
    input signed [31:0] x2;

    input signed [31:0] y0;
    input signed [31:0] y1;
    input signed [31:0] y2;

    output signed [31:0] out0;
    output signed [31:0] out1;
    output signed [31:0] out2;

	wire signed [63:0] a;
	wire signed [63:0] b;
	wire signed [63:0] c;

	assign a = (x0 * y0) >> 16;
	assign b = (x1 * y1) >> 16;
	assign c = (x2 * y2) >> 16;

	assign out = a + b + c;

endmodule

module scale(out0, out1, out2, x0, x1, x2, a);

    input signed [31:0] x0;
    input signed [31:0] x1;
    input signed [31:0] x2;

    output signed [31:0] out0;
    output signed [31:0] out1;
    output signed [31:0] out2;

	wire signed [31:0] out0_big;
	wire signed [31:0] out1_big;
	wire signed [31:0] out2_big;
	
	assign out0_big = x0 * a;
	assign out1_big = x1 * a;
	assign out2_big = x2 * a;

	assign out0 = out0_big >> 16;
	assign out1 = out1_big >> 16;
	assign out2 = out2_big >> 16;

endmodule

module add(out0, out1, out2, x0, x1, x2, y0, y1, y2);

    input signed [31:0] x0;
    input signed [31:0] x1;
    input signed [31:0] x2;

    input signed [31:0] y0;
    input signed [31:0] y1;
    input signed [31:0] y2;

    output signed [31:0] out0;
    output signed [31:0] out1;
    output signed [31:0] out2;

	assign out0 = x0 + y0;
	assign out1 = x1 + y1;
	assign out2 = x2 + y2;
	
endmodule

module subtract(out0, out1, out2, x0, x1, x2, y0, y1, y2);

    input signed [31:0] x0;
    input signed [31:0] x1;
    input signed [31:0] x2;

    input signed [31:0] y0;
    input signed [31:0] y1;
    input signed [31:0] y2;

    output signed [31:0] out0;
    output signed [31:0] out1;
    output signed [31:0] out2;

	assign out0 = x0 - y0;
	assign out1 = x1 - y1;
	assign out2 = x2 - y2;
	
endmodule