module ray_tracer_top #(

    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd10,
    parameter M_BITS = 'd12

)(
    input logic clock,
    input logic reset,

    input logic in_wr_en,
    input logic [D_BITS-1 : 0] ray_in [5:0],
    
    output logic in_full,

    output logic signed [D_BITS-1 : 0] instruction_read [17:0]
);

    logic [D_BITS * 6 - 1 : 0] ray_in_pack;

    genvar i;

    generate

        for (i = 0; i < 6; i = i + 1) begin

            assign ray_in_pack [D_BITS * i + 31 : D_BITS * i] = ray_in [i];

        end

    endgenerate

    logic rd_streamer_fifo0;
    logic signed [D_BITS*6-1 : 0] ray_fifo0_streamer;
    logic signed [D_BITS-1 : 0] ray_parse_fifo0_streamer [5:0];

    fifo #(
        .FIFO_DATA_WIDTH    (6*D_BITS),
        .FIFO_BUFFER_SIZE   ('d300)
    ) INPUT_RAY_FIFO (
        .reset      (reset),
        .wr_clk     (clock),
        .wr_en      (in_wr_en),
        .din        (ray_in_pack),
        .full       (in_full),
        .rd_clk     (clock),
        .rd_en      (rd_streamer_fifo0),
        .dout       (ray_fifo0_streamer),
        .empty      (empty_fifo0_streamer)
    );

    logic full_phit_streamer;
    logic wr_streamer_phit;

    assign full_phit_streamer = 0;

    logic [M_BITS-1 : 0] addr_streamer_mem;
    logic signed [D_BITS-1 : 0] triangle_parse_mem_streamer [11:0];
    logic signed [12 * D_BITS - 1 : 0] triangle_mem_streamer;

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
        .clock              (clock),
        .reset              (reset),

        .in_empty           (empty_fifo0_streamer),
        .in_rd_en           (rd_streamer_fifo0),
        .ray_in             (ray_parse_fifo0_streamer),

        .out_full           (full_phit_streamer),
        .out_wr_en          (wr_streamer_phit),
        .instruction_out    (instruction_read),

        .mem_addr           (addr_streamer_mem),
        .mem_data           (triangle_parse_mem_streamer)
    );

    logic [M_BITS-1 : 0] mem_wr_addr;
    logic mem_wr_en;
    logic [D_BITS * 12 - 1 : 0] mem_din;

    assign mem_wr_addr = 'b0;
    assign mem_wr_en = 0;
    assign mem_din  = 'b0;

    generate

        for (i = 0; i < 12; i = i + 1) begin

            assign triangle_parse_mem_streamer [i] = triangle_mem_streamer [D_BITS * i + 31 : D_BITS * i];

        end

    endgenerate

    sramb #(

	    .SRAMB_BUFFER_SIZE  ('d16),
	    .SRAMB_ADDR_WIDTH   ('d12),
	    .SRAMB_DATA_WIDTH   ('d384)
	
    ) MEM0 (
	    .clock      (clock),
	    .rd_addr    (addr_streamer_mem),
	    .wr_addr    (mem_wr_addr),
	    .wr_en      (mem_wr_en),
	    .dout       (triangle_mem_streamer),
	    .din        (mem_din)
    );

endmodule

