module p_hit_2 #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] tri_normal_1[2:0], //[x,y,z][0]
    input logic signed [31:0] tri_normal_2[2:0], //[x,y,z][1]
    input logic signed [31:0] v0[2:0],
    input logic signed [31:0] origin_1[2:0],
    input logic signed [31:0] origin_2[2:0]
    input logic signed [31:0] dir_1[2:0],
    input logic signed [31:0] dir_2[2:0]
    output logic in_full[3:0],  //
    input logic in_wr_en[3:0],  //

    output logiv signed [31:0] out[2:0],
    input logic out_rd_en,
    output logic out_empty
);

p_hit_1 #(
    .Q_BITS               ('d10)
) u_p_hit_1 (
    .clock                (clock),
    .reset                (reset),
    .tri_normal_1[2:0]    (tri_normal_1[2:0]), //[x,y,z][0]
    .tri_normal_2[2:0]    (tri_normal_2[2:0]), //[x,y,z][1]
    .v0[2:0]              (v0[2:0]),
    .origin[2:0]          (origin[2:0]),
    .dir[2:0]             (dir[2:0]),
    .in_full[1:0]         (in_full[1:0]), //[0,1]
    .in_wr_en[1:0]        (in_wr_en[1:0]), //[0,1]

    .out                  (),
    .out_rd_en            (),
    .out_empty            ()
);

endmodule