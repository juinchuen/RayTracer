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



endmodule