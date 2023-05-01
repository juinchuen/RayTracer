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


endmodule