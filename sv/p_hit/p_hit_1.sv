module p_hit_fifo_in_pt1 #(
    parameter D_BITS = 'd32
) (
    input logic clock,
    input logic reset,
    input logic signed [D_BITS-1:0] tri_normal_in[2:0],
    input logic signed [D_BITS-1:0] v0_in[2:0],
    input logic signed [D_BITS-1:0] origin_in[2:0],
    output logic in_full,
    input logic in_wr_en,

    output logic signed [D_BITS-1:0] tri_normal_out[2:0],
    output logic signed [D_BITS-1:0] v0_out[2:0],
    output logic signed [D_BITS-1:0] origin_out[2:0],
    output logic in_empty,
    input logic in_rd_en
);

    logic full_arr[2:0], empty_arr[2:0];

    fifo_array #(
        .FIFO_DATA_WIDTH         (D_BITS),
        .FIFO_BUFFER_SIZE        (D_BITS*16),
        .ARRAY_SIZE              (3)
    ) tri_normal_fifo (
        .reset                   (reset),
        .clock                   (clock),
        .wr_en                   (in_wr_en),
        .din                     (tri_normal_in[2:0]),
        .full                    (full_arr[0]),
        .rd_en                   (in_rd_en),
        .dout                    (tri_normal_out[2:0]),
        .empty                   (empty_arr[0])
    );

    fifo_array #(
        .FIFO_DATA_WIDTH         (D_BITS),
        .FIFO_BUFFER_SIZE        (D_BITS*16),
        .ARRAY_SIZE              (3)
    ) v0_fifo (
        .reset                   (reset),
        .clock                   (clock),
        .wr_en                   (in_wr_en),
        .din                     (v0_in[2:0]),
        .full                    (full_arr[1]),
        .rd_en                   (in_rd_en),
        .dout                    (v0_out[2:0]),
        .empty                   (empty_arr[1])
    );

    fifo_array #(
        .FIFO_DATA_WIDTH         (D_BITS),
        .FIFO_BUFFER_SIZE        (D_BITS*16),
        .ARRAY_SIZE              (3)
    ) origin_fifo (
        .reset                   (reset),
        .clock                   (clock),
        .wr_en                   (in_wr_en),
        .din                     (origin_in[2:0]),
        .full                    (full_arr[2]),
        .rd_en                   (in_rd_en),
        .dout                    (origin_out[2:0]),
        .empty                   (empty_arr[2])
    );

    logic all_empty = 0;
    logic all_full = 0;

    always_comb begin
        all_empty = empty_arr[0];
        all_full = full_arr[0];
        for(int j = 0; j < 3; j = j + 1) begin
            all_empty = all_empty || empty_arr[j];
            all_full = all_full || full_arr[j];
        end
        in_empty = all_empty;
        in_full = all_full;
    end
endmodule

module p_hit_dot_add_pt1 #(
    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [D_BITS-1:0] tri_normal[2:0],
    input logic signed [D_BITS-1:0] v0[2:0],
    input logic signed [D_BITS-1:0] origin[2:0],
    output logic in_full,
    input logic in_wr_en,

    output logic signed [D_BITS-1:0] out,
    output logic out_empty,
    input logic out_rd_en
);

    logic signed [D_BITS-1:0] v0_out[2:0], tri_normal_out[2:0], origin_out[2:0];
    logic in_rd_en;

    // //testing
    // logic signed  temp1, temp2, temp3, temp4, temp5, temp6, temp7;

    // always_comb begin
    //     temp1 = origin[0];
    //     temp2 = origin[1];
    //     temp3 = origin[2];
    //     temp4 = origin_out[0];
    //     temp5 = origin_out[1];
    //     temp6 = origin_out[2];
    // end
    // //testing

    p_hit_fifo_in_pt1 #(
        .D_BITS                (D_BITS)
    ) u_p_hit_fifo_in_pt1 (
        .clock                 (clock),
        .reset                 (reset),
        .tri_normal_in         (tri_normal[2:0]),
        .v0_in                 (v0[2:0]),
        .origin_in             (origin[2:0]),
        .in_full               (in_full),
        .in_wr_en              (in_wr_en),

        .tri_normal_out        (tri_normal_out[2:0]),
        .v0_out                (v0_out[2:0]),
        .origin_out            (origin_out[2:0]),
        .in_empty              (in_empty),
        .in_rd_en              (in_rd_en)
    );

    logic dot_in_read_en[1:0];
    logic signed [D_BITS-1:0] x, y;
    logic sub_in_rd_en, sub_in_empty;
    logic empty_arr[1:0];

    dot #(
        .D_BITS       (D_BITS),
        .Q_BITS       (Q_BITS)
    ) x_dot (
        .clock        (clock),
        .reset        (reset),
        .x            (tri_normal_out[2:0]),
        .y            (v0_out[2:0]),
        .in_empty     (in_empty),
        .in_rd_en     (dot_in_read_en[0]),

        .out          (x),
        .out_empty    (empty_arr[0]),
        .out_rd_en    (sub_in_rd_en)
    );

    dot #(
        .D_BITS       (D_BITS),
        .Q_BITS       (Q_BITS)
    ) y_dot (
        .clock        (clock),
        .reset        (reset),
        .x            (tri_normal_out[2:0]),
        .y            (origin_out[2:0]),
        .in_empty     (in_empty),
        .in_rd_en     (dot_in_read_en[1]),

        .out          (y),
        .out_empty    (empty_arr[1]),
        .out_rd_en    (sub_in_rd_en)
    );

    sub_single #(
        .D_BITS       (D_BITS)
    ) u_sub_single (
        .clock        (clock),
        .reset        (reset),
        .x            (x),
        .y            (y),
        .in_empty     (sub_in_empty),
        .in_rd_en     (sub_in_rd_en),
        .out          (out),
        .out_empty    (out_empty),
        .out_rd_en    (out_rd_en)
    );

    always_comb begin
        in_rd_en = dot_in_read_en[0] || dot_in_read_en[1];  //these will be the same, so just formality
        sub_in_empty = empty_arr[0] || empty_arr[1];
    end  
endmodule

module p_hit_dot_pt2 #(
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] tri_normal[2:0],
    input logic signed [31:0] dir[2:0],
    output logic in_full,
    input logic in_wr_en,

    output logic signed[31:0] out,
    input logic out_rd_en,
    output logic out_empty
);

    logic signed [31:0] tri_normal_out[2:0], dir_out[2:0];
    logic dot_rd_en, empty_arr[1:0], dot_empty, full_arr[1:0];

    fifo_array #(
        .FIFO_DATA_WIDTH         (32),
        .FIFO_BUFFER_SIZE        (1024),
        .ARRAY_SIZE              (3)
    ) normal_fifo (
        .reset                   (reset),
        .clock                   (clock),
        .wr_en                   (in_wr_en),
        .din                     (tri_normal[2:0]),
        .full                    (full_arr[0]),
        .rd_en                   (dot_rd_en),
        .dout                    (tri_normal_out[2:0]),
        .empty                   (empty_arr[0])
    );

    fifo_array #(
        .FIFO_DATA_WIDTH         (32),
        .FIFO_BUFFER_SIZE        (1024),
        .ARRAY_SIZE              (3)
    ) dir_fifo (
        .reset                   (reset),
        .clock                   (clock),
        .wr_en                   (in_wr_en),
        .din                     (dir[2:0]),
        .full                    (full_arr[1]),
        .rd_en                   (dot_rd_en),
        .dout                    (dir_out[2:0]),
        .empty                   (empty_arr[1])
    );

    dot #(
        .Q_BITS       (Q_BITS)
    ) u_dot (
        .clock        (clock),
        .reset        (reset),
        .x            (dir_out),
        .y            (tri_normal_out),
        .in_empty     (dot_empty),
        .in_rd_en     (dot_rd_en),
        .out          (out),
        .out_empty    (out_empty),
        .out_rd_en    (out_rd_en)
    );

    always_comb begin
        dot_empty = empty_arr[0] || empty_arr[1];
        in_full = full_arr[0] || full_arr[1];
    end
endmodule

module p_hit_1 #(
    parameter Q_BITS = 'd16
) (
    input logic clock,
    input logic reset,
    input logic signed [31:0] tri_normal_1[2:0], //[x,y,z][0]
    input logic signed [31:0] tri_normal_2[2:0], //[x,y,z][1]
    input logic signed [31:0] v0[2:0],
    input logic signed [31:0] origin[2:0],
    input logic signed [31:0] dir[2:0],
    output logic in_full[1:0],  //[0,1]
    input logic in_wr_en[1:0],  //[0,1]

    output logic signed [31:0] out,
    input logic out_rd_en,
    output logic out_empty
);

    // logic signed [31:0] temp1, temp2, temp3;
    // always_comb begin
    //     temp1 = tri_normal_1[0];
    //     temp2 = v0[0];
    //     temp3 = origin[0];
    // end

    // //testing
    // logic signed [31:0]  temp1, temp2, temp3, temp4, temp5, temp6, temp7;

    // always_comb begin
    //     temp1 = origin[0];
    //     temp2 = origin[1];
    //     temp3 = origin[2];
    // end
    // //testing

    logic signed [31:0] x, y;
    logic division_rd_en, empty_arr[1:0], div_empty;

    p_hit_dot_add_pt1 #(
        .Q_BITS             (Q_BITS)
    ) top (
        .clock              (clock),
        .reset              (reset),
        .tri_normal         (tri_normal_1[2:0]),
        .v0                 (v0[2:0]),
        .origin             (origin[2:0]),
        .in_full            (in_full[0]),
        .in_wr_en           (in_wr_en[1]),
        .out                (x),
        .out_empty          (empty_arr[0]),
        .out_rd_en          (division_rd_en)
    );

    p_hit_dot_pt2 #(
        .Q_BITS             (Q_BITS)
    ) bottom (
        .clock              (clock),
        .reset              (reset),
        .tri_normal         (tri_normal_2[2:0]),
        .dir                (dir[2:0]),
        .in_full            (in_full[1]),
        .in_wr_en           (in_wr_en[1]),
        .out                (y),
        .out_rd_en          (division_rd_en),
        .out_empty          (empty_arr[1])
    );

    divide_top #(
        .Q_BITS       (Q_BITS),
        // .D_BITS       (D_BITS)
    ) u_divide_top (
        .clock        (clock),
        .reset        (reset),
        .dividend     (x),
        .divisor      (y),
        .in_empty     (div_empty),
        .in_rd_en     (division_rd_en),
        .out_empty    (out_empty),
        .out_rd_en    (out_rd_en),
        .out_dout     (out)
    );

    always_comb begin
        div_empty = empty_arr[0] || empty_arr[1];
    end

endmodule