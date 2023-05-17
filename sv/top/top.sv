module ray_tracer_top(
    input logic clock,
    input logic reset
)

    localparam D_BITS = 'd32;
    localparam Q_BITS = 'd10;
    localparam M_BITS = 'd12;

    fifo #(
        .FIFO_DATA_WIDTH    (6*D_BITS),
        .FIFO_BUFFER_SIZE   ('d300)
    ) INPUT_RAY_FIFO (
        .reset      (reset),
        .wr_clk     (clock),
        .wr_en      (in_wr_en),
        .din        (ray_in),
        .full       (in_full),
        .rd_clk     (clock),
        .rd_en      (rd_streamer_fifo0),
        .dout       (ray_fifo0_streamer),
        .empty      (empty_fifo0_streamer)
    );

    logic rd_streamer_fifo0;
    logic signed [D_BITS*6-1 : 0] ray_fifo0_streamer;
    logic signed [D_BITS-1 : 0] ray_parse_fifo0_streamer [5:0];

    genvar i;

    generate

        for (i = 0; i < 6; i = i + 1) begin

            assign ray_parse_fifo0_streamer [i] = ray_fifo0_streamer [D_BITS * i + 31 : D_BITS * i];

        end

    endgenerate

    streamer #(
        .Q_BITS (Q_BITS),
        .D_BITS (D_BITS),
        .M_BITS (M_BITS)
    ) STREAMER0 (
        .clock(clock),
        .reset(reset),

        .in_empty           (empty_fifo0_streamer),
        .in_rd_en           (rd_streamer_fifo0),
        .ray_in             (ray_parse_fifo0_streamer),

        .out_full           (full_streamer_phit),
        .out_wr_en          (wr_streamer_phit),
        .instruction_out    (),

        .mem_addr           (addr_streamer_mem),
        .mem_data           (triangle_parse_mem_streamer)
    );

    logic addr_streamer_mem;
    logic signed [D_BITS-1 : 0] triangle_parse_mem_streamer [11:0];
    logic signed [12 * D_BITS - 1 : 0] triangle_mem_streamer;

    generate

        for (i = 0; i < 12; i = i + 1) begin

            assign triangle_parse_mem_streamer [i] = triangle_mem_streamer [D_BITS * i + 31 : D_BITS * i];

    sram MEM0 (
        .clock      (clock),
        .rd_addr    (addr_streamer_mem),
        .wr_addr    (),
        .wr_en      (),
        .dout       (),
        .din        ()
    );



