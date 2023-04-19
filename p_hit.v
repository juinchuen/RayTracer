`timescale 1ns/10ps

module ray_plane_intersect(p_hit, normal, origin, v0, dir);

	input signed [31:0] normal [2:0];
	input signed [31:0] origin [2:0];
	input signed [31:0] v0 	   [2:0];
	input signed [31:0] dir    [2:0];
	
	output signed [31:0] p_hit [2:0];

	logic signed [31:0] normal_o_v;
	logic signed [31:0] normal_o_origin;
	logic signed [31:0] normal_o_dir;
	logic signed [31:0] numerator;
	logic signed [31:0] quotient;
	logic signed [31:0] product [2:0];
	logic signed [47:0] force_resolution;

	dot d0 (normal_o_v, 	 normal, v0);
	dot d1 (normal_o_origin, normal, origin);
	dot d2 (normal_o_dir,	 normal, dir);

	assign numerator = normal_o_v - normal_o_origin;

	assign force_resolution = (numerator << 16);

	assign quotient = (force_resolution / normal_o_dir);

	scale s0 (product, dir, quotient);

	add a0 (p_hit, product, origin);

endmodule
