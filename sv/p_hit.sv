module ray_plane_intersect #(
	parameter Q_BITS = 'd10)
(
	input logic signed [0:2] [31:0] normal,
	input logic signed [0:2] [31:0] origin,
	input logic signed [0:2] [31:0] v0,
	input logic signed [0:2] [31:0] dir,
	output logic signed [0:2][31:0] p_hit
);

logic signed [31:0] normal_o_v;
logic signed [31:0] normal_o_origin;
logic signed [31:0] normal_o_dir;
logic signed [31:0] numerator;
logic signed [31:0] quotient;
logic signed [0:2][31:0] product;
logic signed [47:0] force_resolution;

// Module instantiations
dot dot_d0_inst (
	.out    (normal_o_v),
	.x      (normal),
	.y      (v0)
);

dot dot_d1_inst (
	.out    (normal_o_origin),
	.x      (normal),
	.y      (origin)
);

dot dot_d2_inst (
	.out    (normal_o_dir),
	.x      (normal),
	.y      (dir)
);

// No clock so no divide for now
// divide_module #(
// .Q_BITS       ('d10),
// .D_WIDTH      ('d32),
// .ED_WIDTH     (2*D_WIDTH)
// ) u_divide_module (
// .clock        (clock),
// .reset        (reset),
// .dividend     (dividend),
// .divisor      (divisor),
// .quotient     (quotient),
// .valid_in     (valid_in),
// .valid_out    (valid_out)
// );

scale scale_product_inst(
	.out (product),
	.x   (dir),
	.y   (quotient)
);

add add_p_hit_inst(
	.out (p_hit),
	.x   (product),
	.y   (origin)
)

always_comb begin
	numerator = normal_o_v - normal_o_origin;
	force_resolution = (numerator << Q_BITS);
	quotient = (force_resolution / normal_o_dir); // In the future we'll use divide module after clo
end

endmodule