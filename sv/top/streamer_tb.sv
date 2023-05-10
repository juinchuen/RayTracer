module streamer_tb #(
    parameter Q_BITS = 'd10,
    parameter D_BITS = 'd32,
    parameter M_BITS = 'd12
) ();

logic clock;
logic reset;

logic in_empty;
logic in_rd_en;
logic signed [D_BITS-1 : 0] ray_in [5:0];

logic out_full;
logic out_wr_en;
logic signed [D_BITS-1 : 0] instruction_out [17:0];

logic [M_BITS-1 : 0] mem_addr;
logic signed [D_BITS-1 : 0] mem_data [11:0];

initial begin

    clock = 1;
    reset = 0;
    in_empty = 1;

    ray_in[0] = 'b0;
    ray_in[1] = 'b0;
    ray_in[2] = 'b0;
    ray_in[3] = 'b0;
    ray_in[4] = 'b0;
    ray_in[5] = 'b0;

    mem_data[ 0] = 'b0;    
    mem_data[ 1] = 'b0;
    mem_data[ 2] = 'b0;
    mem_data[ 3] = 'b0;
    mem_data[ 4] = 'b0;
    mem_data[ 5] = 'b0;
    mem_data[ 6] = 'b0;
    mem_data[ 7] = 'b0;
    mem_data[ 8] = 'b0;
    mem_data[ 9] = 'b0;
    mem_data[10] = 'b0;
    mem_data[11] = 'b0;

    out_full = 0;

    #5

    reset = 1;

    #10

    reset = 0;
    in_empty = 0;

    #100

    $finish;

end

always begin

    #5

    clock = ~clock;

end

always @ (mem_addr) begin

    mem_data[ 0] = mem_data[ 0] + 1;    
    mem_data[ 1] = mem_data[ 1] + 1;
    mem_data[ 2] = mem_data[ 2] + 1;
    mem_data[ 3] = mem_data[ 3] + 1;
    mem_data[ 4] = mem_data[ 4] + 1;
    mem_data[ 5] = mem_data[ 5] + 1;
    mem_data[ 6] = mem_data[ 6] + 1;
    mem_data[ 7] = mem_data[ 7] + 1;
    mem_data[ 8] = mem_data[ 8] + 1;
    mem_data[ 9] = mem_data[ 9] + 1;
    mem_data[10] = mem_data[10] + 1;
    mem_data[11] = mem_data[11] + 1;

end

always @ (in_rd_en) begin

    ray_in[0] = ray_in[0] + 1;
    ray_in[1] = ray_in[1] + 1;
    ray_in[2] = ray_in[2] + 1;
    ray_in[3] = ray_in[3] + 1;
    ray_in[4] = ray_in[4] + 1;
    ray_in[5] = ray_in[5] + 1;

end

streamer #(
    .Q_BITS (Q_BITS),
    .D_BITS (D_BITS),
    .M_BITS (M_BITS)
) DUT_INST0 (
    .clock              (clock),
    .reset              (reset),

    .in_empty           (in_empty),
    .in_rd_en           (in_rd_en),
    .ray_in             (ray_in),

    .out_full           (out_full),
    .out_wr_en          (out_wr_en),
    .instruction_out    (instruction_out),

    .mem_addr           (mem_addr),
    .mem_data           (mem_data)
);

endmodule