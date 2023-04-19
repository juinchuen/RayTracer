module ray_plane_intersect #(
	parameter Q_BITS = 'd10
) (
	input int normal [0:2], 
	input int origin [0:2],
	input int v0 [0:2],
	input int dir [0:2],
	output int p_hit [0:2]
);

	int normal_o_v;
	int normal_o_origin;
	int normal_o_dir;
	int numerator;
	int quotient;
	int product [0:2];
	logic signed [31+Q_BITS:0] force_resolution;

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

// module ray_plane_intersect(p_hit, normal, origin, v0, dir);

// 	dot d0 (normal_o_v, 	 normal, v0);
// 	dot d1 (normal_o_origin, normal, origin);
// 	dot d2 (normal_o_dir,	 normal, dir);

// 	assign numerator = normal_o_v - normal_o_origin;

// 	assign force_resolution = (numerator << 16);

// 	assign quotient = (force_resolution / normal_o_dir);

// 	scale s0 (product, dir, quotient);

// 	add a0 (p_hit, product, origin);

// endmodule
