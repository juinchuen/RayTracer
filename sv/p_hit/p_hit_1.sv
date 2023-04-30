module p_hit_dot_pt1 #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] tri_normal[2:0],
    input logic signed [31:0] v0[2:0],

    input logic in_empty,
    output logic in_rd_en;

    output logic signed [31:0] out;
    output logic out_empty;
    input logic out_rd_en;
);



endmodule
