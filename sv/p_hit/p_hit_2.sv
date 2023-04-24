module p_hit_2 #(
    parameter Q_BITS = 'd10
) (
    input logic clock,
    input logic reset,
    input int dir[2:0],   
    input int origin[2:0],
    input int division_result,
    input logic in_empty,
    output logic in_rd_en,

    output int p_hit[2:0],
    output logic out_empty,
    input logic out_rd_en
);

int out_din[2:0]
logic out_full, out_full_arr[2:0], out_wr_en;

p_hit_2_module #(
    .Q_BITS             ('d10)
) u_p_hit_2_module (
    .clock              (clock),
    .reset              (reset),
    .dir                (dir[2:0]),
    .origin             (origin[2:0]),
    .division_result    (division_result),
    .in_empty           (in_empty),
    .in_rd_en           (in_rd_en),
    
    .p_hit              (out_din[2:0]),
    .out_wr_en          (out_wr_en),
    .out_full           (out_full)
);

logic out_empty_arr[2:0];

genvar i;
generate for(i = 0; i < 2; i = i + 1) begin
    fifo #(
        .FIFO_DATA_WIDTH     ('d32),
        .FIFO_BUFFER_SIZE    ('d1024)
    ) fifo_out_inst (
        .reset               (reset),
        .wr_clk              (clock),
        .rd_clk              (clock),

        .wr_en               (out_wr_en),
        .din                 (out_din[i]),
        .full                (out_full_arr[i]),
        
        .rd_en               (out_rd_en),
        .dout                (p_hit[i]),
        .empty               (out_empty_arr[i])
    );
end
endgenerate

always_comb begin
    //put all the out_empty together
    out_empty = out_empty_arr[0] || out_empty_arr[1] || out_empty_arr[2];

    //put all the out_full together
    out_full = out_full_arr[0] || out_full_arr[1] || out_full_arr[2];
end

endmodule