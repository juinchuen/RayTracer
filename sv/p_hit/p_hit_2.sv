module p_hit_mult #(
    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [D_BITS-1:0] tri_normal_1[2:0], //[x,y,z][0]
    input logic signed [D_BITS-1:0] tri_normal_2[2:0], //[x,y,z][1]
    input logic signed [D_BITS-1:0] v0[2:0],
    input logic signed [D_BITS-1:0] origin[2:0],
    input logic signed [D_BITS-1:0] dir_1[2:0],
    input logic signed [D_BITS-1:0] dir_2[2:0],
    output logic in_full[2:0],  //
    input logic in_wr_en[2:0],  //

    output logic signed [D_BITS-1:0] out[2:0],
    input logic out_rd_en,
    output logic out_empty
);

    logic signed [D_BITS-1:0] division_out, dir_2_out[2:0];
    logic empty_arr[1:0], empty, rd_en;

    // //testing
    // logic signed[D_BITS-1:0] temp1, temp2, temp3, temp4, temp5, temp6, temp7;

    // always_comb begin
    //     temp1 = out[0];
    //     temp2 = out[1];
    //     temp3 = out[2];
    //     temp4 = dir_2[0];
    //     temp5 = dir_2[1];
    //     temp6 = dir_2[2];
    // end
    // //testing

    p_hit_1 #(
        .D_BITS               (D_BITS),
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
        .FIFO_DATA_WIDTH         (D_BITS),
        .FIFO_BUFFER_SIZE        (D_BITS*16),
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
        .D_BITS       (D_BITS),
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


module p_hit_module #(
    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [D_BITS-1:0] tri_normal_1[2:0], //[x,y,z][0]
    input logic signed [D_BITS-1:0] tri_normal_2[2:0], //[x,y,z][1]
    input logic signed [D_BITS-1:0] v0[2:0],
    input logic signed [D_BITS-1:0] origin_1[2:0],
    input logic signed [D_BITS-1:0] origin_2[2:0],
    input logic signed [D_BITS-1:0] dir_1[2:0],
    input logic signed [D_BITS-1:0] dir_2[2:0],
    output logic in_full[3:0],  //
    input logic in_wr_en[3:0],  //

    output logic signed [D_BITS-1:0] out[2:0],
    input logic out_rd_en,
    output logic out_empty
);

    logic empty_arr[1:0], empty, rd_en;
    logic signed [D_BITS-1:0] origin_out[2:0], mult_out[2:0];

    // //testing
    // logic signed [D_BITS-1:0]  temp1, temp2, temp3, temp4, temp5, temp6;
    // always_comb begin
    //     temp1 = out[0];
    //     temp2 = out[1];
    //     temp3 = out[2];
    //     temp4 = origin_2[0];
    //     temp5 = origin_2[1];
    //     temp6 = origin_2[2];
    // end
    // //testing

    p_hit_mult #(
        .D_BITS               (D_BITS),
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
        .FIFO_DATA_WIDTH         (D_BITS),
        .FIFO_BUFFER_SIZE        (D_BITS*16),
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

    add #(
        .D_BITS       (D_BITS)
    ) u_add (
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


module p_hit #(
    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd16,
    parameter M_BITS = 'd32
) (
    input logic clock,
    input logic reset,
    input logic signed [D_BITS-1:0] tri_normal_in[2:0],
    input logic signed [D_BITS-1:0] v0_in[2:0],
    input logic signed [D_BITS-1:0] v1_in[2:0],
    input logic signed [D_BITS-1:0] v2_in[2:0],
    input logic signed [D_BITS-1:0] origin[2:0],
    input logic signed [D_BITS-1:0] dir[2:0],
    input logic signed [M_BITS-1:0] triangle_id_in[2:0],
    output logic in_full,
    input logic in_wr_en,

    output logic signed [D_BITS-1:0] p_hit[2:0],
    output logic signed [D_BITS-1:0] v0_out[2:0],
    output logic signed [D_BITS-1:0] v1_out[2:0],
    output logic signed [D_BITS-1:0] v2_out[2:0],
    output logic signed [D_BITS-1:0] triangle_id_out[2:0],
    output logic signed [M_BITS-1:0] tri_normal_out[2:0],

    input logic out_rd_en,
    output logic out_empty 
);

logic in_full_arr[7:0];
logic out_empty_arr[5:0];

p_hit_module #(
    .D_BITS               (D_BITS),
    .Q_BITS               (Q_BITS)
) u_p_hit_module (
    .clock                (clock),
    .reset                (reset),
    .tri_normal_1         (tri_normal_in[2:0]),
    .tri_normal_2         (tri_normal_in[2:0]),
    .v0                   (v0_in[2:0]),
    .origin_1             (origin[2:0]),
    .origin_2             (origin[2:0]),
    .dir_1                (dir[2:0]),
    .dir_2                (dir[2:0]),
    .in_full              ({in_full_arr[0], in_full_arr[1], in_full_arr[2]}),
    .in_wr_en             ({in_wr_en, in_wr_en, in_wr_en, in_wr_en}),

    .out                  (p_hit[2:0]),
    .out_rd_en            (out_rd_en),
    .out_empty            (out_empty_arr[0]) 
);

fifo_array #(
    .FIFO_DATA_WIDTH    (D_BITS),
    .FIFO_BUFFER_SIZE   (D_BITS*32),
    .ARRAY_SIZE         (3)
) v0_fifo (
    .reset              (reset),
    .clock              (clock),
    .wr_en              (in_wr_en),
    .din                (v0_in[2:0]),
    .full               (in_full_arr[3]),
    .rd_en              (out_rd_en),
    .dout               (v0_out[2:0]),
    .empty              (out_empty_arr[1])
);

fifo_array #(
    .FIFO_DATA_WIDTH    (D_BITS),
    .FIFO_BUFFER_SIZE   (D_BITS*32),
    .ARRAY_SIZE         (3)
) v1_fifo (
    .reset              (reset),
    .clock              (clock),
    .wr_en              (in_wr_en),
    .din                (v1_in[2:0]),
    .full               (in_full_arr[4]),
    .rd_en              (out_rd_en),
    .dout               (v1_out[2:0]),
    .empty              (out_empty_arr[2])
);

fifo_array #(
    .FIFO_DATA_WIDTH    (D_BITS),
    .FIFO_BUFFER_SIZE   (D_BITS*32),
    .ARRAY_SIZE         (3)
) v2_fifo (
    .reset              (reset),
    .clock              (clock),
    .wr_en              (in_wr_en),
    .din                (v2_in[2:0]),
    .full               (in_full_arr[5]),
    .rd_en              (out_rd_en),
    .dout               (v2_out[2:0]),
    .empty              (out_empty_arr[3])
);

fifo_array #(
    .FIFO_DATA_WIDTH    (D_BITS),
    .FIFO_BUFFER_SIZE   (D_BITS*32),
    .ARRAY_SIZE         (3)
) normal_fifo (
    .reset              (reset),
    .clock              (clock),
    .wr_en              (in_wr_en),
    .din                (tri_normal_in[2:0]),
    .full               (in_full_arr[6]),
    .rd_en              (out_rd_en),
    .dout               (tri_normal_out[2:0]),
    .empty              (out_empty_arr[4])
);

fifo_array #(
    .FIFO_DATA_WIDTH    (M_BITS),
    .FIFO_BUFFER_SIZE   (M_BITS*32),
    .ARRAY_SIZE         (3)
) triangle_id_fifo (
    .reset              (reset),
    .clock              (clock),
    .wr_en              (in_wr_en),
    .din                (triangle_id_in[2:0]),
    .full               (in_full_arr[7]),
    .rd_en              (out_rd_en),
    .dout               (triangle_id_out[2:0]),
    .empty              (out_empty_arr[5])
);

logic all_empty = 0;
logic all_full = 0;

always_comb begin
    for(int i = 0; i < 8; i = i + 1) begin
        all_full = all_full || in_full_arr[i];
    end
    for(int i = 0; i < 6; i = i + 1) begin
        all_empty = all_empty || out_empty_arr[i];
    end
    out_empty = all_empty;
    in_full = all_full;
end
    
endmodule