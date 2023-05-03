module p_hit_mult #(
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] tri_normal_1[2:0], //[x,y,z][0]
    input logic signed [31:0] tri_normal_2[2:0], //[x,y,z][1]
    input logic signed [31:0] v0[2:0],
    input logic signed [31:0] origin[2:0],
    input logic signed [31:0] dir_1[2:0],
    input logic signed [31:0] dir_2[2:0],
    output logic in_full[2:0],  //
    input logic in_wr_en[2:0],  //

    output logic signed [31:0] out[2:0],
    input logic out_rd_en,
    output logic out_empty
);

logic signed [31:0] division_out, dir_2_out[2:0];
logic empty_arr[1:0], empty, rd_en;

p_hit_1 #(
    .Q_BITS               (Q_BITS)
) u_p_hit_1 (
    .clock                (clock),
    .reset                (reset),
    .tri_normal_1         (tri_normal_1[2:0]), //[x,y,z][0]
    .tri_normal_2         (tri_normal_2[2:0]), //[x,y,z][1]
    .v0                   (v0[2:0]),
    .origin               (origin[2:0]),
    .dir                  (dir_1[2:0]),
    .in_full              (in_full[1:0]), //[0,1]
    .in_wr_en             (in_wr_en[1:0]), //[0,1]

    .out                  (division_out),
    .out_rd_en            (rd_en),
    .out_empty            (empty_arr[0])
);

fifo_array #(
    .FIFO_DATA_WIDTH         (32),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) dir_fifo (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (in_wr_en[2]),
    .din                     (dir_2[2:0]),
    .full                    (in_full[2]),
    .rd_en                   (rd_en),
    .dout                    (dir_2_out[2:0]),
    .empty                   (empty_arr[1])
);

scale #(
    .Q_BITS       (Q_BITS)
) u_scale (
    .clock        (clock),
    .reset        (reset),
    .x            (dir_2_out[2:0]),
    .a            (division_out),
    .in_empty     (empty),
    .in_rd_en     (rd_en),
    .out          (out[2:0]),
    .out_empty    (out_empty),
    .out_rd_en    (out_rd_en)
);

always_comb begin
    empty = empty_arr[0] || empty_arr[1];
end

endmodule


module p_hit #(
    parameter Q_BITS = 'd16

) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] tri_normal_1[2:0], //[x,y,z][0]
    input logic signed [31:0] tri_normal_2[2:0], //[x,y,z][1]
    input logic signed [31:0] v0[2:0],
    input logic signed [31:0] origin_1[2:0],
    input logic signed [31:0] origin_2[2:0],
    input logic signed [31:0] dir_1[2:0],
    input logic signed [31:0] dir_2[2:0],
    output logic in_full[3:0],  //
    input logic in_wr_en[3:0],  //

    output logic signed [31:0] out[2:0],
    input logic out_rd_en,
    output logic out_empty
);

logic empty_arr[1:0], empty, rd_en;
logic signed [31:0] origin_out[2:0], mult_out[2:0];

p_hit_mult #(
    .Q_BITS               (Q_BITS)
) u_p_hit_mult (
    .clock                (clock),
    .reset                (reset),
    .tri_normal_1         (tri_normal_1[2:0]),
    .tri_normal_2         (tri_normal_2[2:0]),
    .v0                   (v0[2:0]),
    .origin               (origin_1[2:0]),
    .dir_1                (dir_1[2:0]),
    .dir_2                (dir_2[2:0]),
    .in_full              (in_full[2:0]),
    .in_wr_en             (in_wr_en[2:0]),
    .out                  (mult_out[2:0]),
    .out_rd_en            (rd_en),
    .out_empty            (empty_arr[0])
);

fifo_array #(
    .FIFO_DATA_WIDTH         (32),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) origin_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (in_wr_en[3]),
    .din                     (origin_2[2:0]),
    .full                    (in_full[3]),
    .rd_en                   (rd_en),
    .dout                    (origin_out[2:0]),
    .empty                   (empty_arr[1])
);

add u_add (
    .clock        (clock),
    .reset        (reset),
    .x            (origin_out[2:0]),
    .y            (mult_out[2:0]),
    .in_empty     (empty),
    .in_rd_en     (rd_en),
    .out          (out[2:0]),
    .out_empty    (out_empty),
    .out_rd_en    (out_rd_en)
);

always_comb begin
    empty = empty_arr[0] || empty_arr[1];
end
    
endmodule