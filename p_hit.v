`timescale 1ns/10ps

module ray_plane_intersect(p_hit, normal, origin, v0, dir);

	input signed [31:0] normal0;
	input signed [31:0] normal1;
	input signed [31:0] normal2;
	
	input signed [31:0] origin0;
	input signed [31:0] origin1;
	input signed [31:0] origin2;
	
	input signed [31:0] v0_0;
	input signed [31:0] v0_1;
	input signed [31:0] v0_2;

	input signed [31:0] dir0;
	input signed [31:0] dir1;
	input signed [31:0] dir2;	

	output signed [31:0] p_hit0;
	output signed [31:0] p_hit1;
	output signed [31:0] p_hit2;

	wire [31:0] normal_o_v;
	wire [31:0] normal_o_origin;
	wire [31:0] normal_o_dir;
	wire [31:0] numerator;
	//wire [95:0] denominator;
	wire [31:0] dividend;
	wire [95:0] product;
	wire [95:0] sum;

	dot d0 (normal_o_v, normal, v0);
	dot d1 (normal_o_origin, normal, origin);
	dot d2 (normal_o_dir, normal, dir);

	assign numerator = normal_o_v - normal_o_origin;

	wire [63:0] force_resolution;

	assign force_resolution = (numerator << 16);

	assign dividend = (force_resolution / normal_o_dir);

	scale s0 (product, dir, dividend);

	add a0 (sum, product, origin);

	assign p_hit = sum;

endmodule
