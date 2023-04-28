module p_hit_1_module #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input int tri_normal[2:0],
    input int origin[2:0],
    input int v0[2:0],
    input int dir[2:0],
    

    input int dir[2:0],   
    input int origin[2:0],
    input int division_result,
    input logic in_empty,
    output logic in_rd_en,

    output int p_hit[2:0],
    output logic out_wr_en,
    input logic out_full
);

logic signed [31:0] sub_din[1:0];

dot #(
    .Q_BITS       (Q_BITS)
) u_dot_x (
    .clock        (clock),
    .reset        (reset),
    .x            (tri_normal[2:0]),
    .y            (v0[2:0]),
    .in_empty     (in_empty),
    .in_rd_en     (in_rd_en),
    .out          (sub_din[0]),
    .out_empty    (out_empty),
    .out_rd_en    (out_rd_en)
);
//x

dot #(
    .Q_BITS       (Q_BITS)
) u_dot_y (
    .clock        (clock),
    .reset        (reset),
    .x            (tri_normal[2:0]),
    .y            (origin[2:0]),
    .in_empty     (in_empty),
    .in_rd_en     (in_rd_en),
    .out          (sub_din[1]),
    .out_empty    (out_empty),
    .out_rd_en    (out_rd_en)
);
//y







endmodule