module p_hit_2_submodule #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] dir[2:0],
    input logic signed [31:0] origin[2:0],
    input logic signed [31:0] division_result,

    //for mult
    input logic in_empty_mult,
    output logic in_rd_en_mult,

    //for add
    input logic add_empty_origin,
    output logic add_rd_en,

    output logic signed [31:0] p_hit,
    output logic out_empty,
    input logic out_rd_en
);

logic scale_out_empty, scale_out_rd_en;
logic signed [31:0] scale_out[2:0]

scale #(
    .Q_BITS       (Q_BITS)
) u_scale (
    .clock        (clock),
    .reset        (reset),
    .x            (dir[2:0]),
    .a            (division_result),
    .in_empty     (in_empty_mult),
    .in_rd_en     (in_rd_en_mult),
    .out          (scale_out[2:0]),
    .out_empty    (scale_out_empty),
    .out_rd_en    (add_rd_en)
);

logic add_in_empty;

add u_add (
    .clock        (clock),
    .reset        (reset),
    .x[2:0]       (scale_out[2:0]),
    .y[2:0]       (origin[2:0]),
    .in_empty     (add_in_empty),
    .in_rd_en     (add_rd_en),

    .out[2:0]     (p_hit[2:0]),
    .out_empty    (out_empty),
    .out_rd_en    (out_rd_en)
);

always_comb begin
    add_in_empty = scale_out_empty || add_empty_origin;
end
endmodule

module p_hit_2_module #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] dir[2:0],
    input logic signed [31:0] origin[2:0],
    input logic signed [31:0] division_result,

    //for mult
    input logic in_empty_mult,
    output logic in_rd_en_mult;

    //for add
    input logic add_empty_origin,
    output logic add_rd_en;

    output logic signed [31:0] p_hit;
    output logic out_empty;
    input logic out_rd_en;
)

logic signed [31:0] origin_out[2:0], dir_out[2:0]

fifo_array #(
    .FIFO_DATA_WIDTH         (32),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) dir_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (),
    .din                     (dir[2:0]),
    .full                    (),
    .rd_en                   (),
    .dout                    (dir_out[2:0]),
    .empty                   ()
);

fifo_array #(
    .FIFO_DATA_WIDTH         (32),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) origin_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (),
    .din                     (origin[2:0]),
    .full                    (),
    .rd_en                   (),
    .dout                    (origin_out[2:0]),
    .empty                   ()
);

p_hit_2_submodule #(
    .Q_BITS              ('d10)
) u_p_hit_2_submodule (
    .clock               (clock),
    .reset               (reset),
    .dir                 (dir_out[2:0]),
    .origin              (origin_out[2:0]),
    .division_result     (division_result),
    //for mult
    .in_empty_mult       (in_empty_mult),
    .in_rd_en_mult       (in_rd_en_mult),
    //for add
    .add_empty_origin    (add_empty_origin),
    .add_rd_en           (add_rd_en),
    .p_hit               (p_hit),
    .out_empty           (out_empty),
    .out_rd_en           (out_rd_en)
);
    
endmodule

module p_hit_