`timescale 1ns/10ps

module p_hit_tb;

	reg [95:0] normal;
	reg [95:0] v0;
	reg [95:0] origin;
	reg [95:0] dir;

	wire [95:0] p_hit;

	initial begin

		normal = 96'h0000D5040000000000008E00;
		v0 =     96'h00060000FFFF8000FFFF8000;
		origin = 96'h0004000000010000FFFF0000;
		dir =    96'h0000F15B00003C56FFFFC3AA;

		#100
		$finish;

	end

	ray_plane_intersect rp0 (p_hit, normal, origin, v0, dir);

endmodule
