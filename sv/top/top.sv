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

    logic           [M_BITS-1 : 0]          addr_streamer_mem;
    logic signed    [D_BITS-1 : 0]          triangle_parse_mem_streamer [11:0];
    logic signed    [12 * D_BITS - 1 : 0]   triangle_mem_streamer;
    logic           [M_BITS-1 : 0]          triangle_ID_streamer_phit;

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
        .triangle_ID_out    (triangle_ID_streamer_phit),

        .mem_addr           (addr_streamer_mem),
        .mem_data           (triangle_parse_mem_streamer)
    );

    logic [M_BITS-1 : 0]        mem_wr_addr;
    logic                       mem_wr_en;
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
	    .SRAMB_ADDR_WIDTH   (M_BITS),
	    .SRAMB_DATA_WIDTH   ('d384)
	
    ) MEM0 (
	    .clock      (clock),
	    .rd_addr    (addr_streamer_mem),
	    .wr_addr    (mem_wr_addr),
	    .wr_en      (mem_wr_en),
	    .dout       (triangle_mem_streamer),
	    .din        (mem_din)
    );

    logic           [M_BITS-1 : 0]  triangle_ID_streamer_phit;
    logic                           full_phit_streamer;
    logic                           wr_streamer_phit;

    p_hit #(
        .D_BITS             (D_BITS),
        .Q_BITS             (Q_BITS),
        .M_BITS             (M_BITS)
    ) P_HIT0 (
        .clock              (clock),
        .reset              (reset),
        .tri_normal_in      (instruction_read [15:17]),
        .v0_in[2:0]         (instruction_read [ 6: 8]),
        .v1_in[2:0]         (instruction_read [ 9:11]),
        .v2_in[2:0]         (instruction_read [12:14]),
        .origin[2:0]        (instruction_read [ 0: 2]),
        .dir[2:0]           (instruction_read [ 3: 5]),
        .triangle_id_in     (triangle_ID_streamer_phit),
        .in_full            (full_phit_streamer),
        .in_wr_en           (wr_streamer_phit),

        .p_hit              (phit_phit_hitb),
        .v0_out             (v0_phit_hitb),
        .v1_out             (v1_phit_hitb),
        .v2_out             (v2_phit_hitb),
        .triangle_id_out    (triangle_ID_phit_hitb),
        .tri_normal_out     (triangle_norm_phit_hitb),

        .out_rd_en          (wr_phit_hitb),
        .out_empty          (empty_hitb_phit)
    );

    logic signed    [D_BITS-1 : 0]  phit_phit_hitb          [2:0];
    logic signed    [D_BITS-1 : 0]  v0_phit_hitb            [2:0];
    logic signed    [D_BITS-1 : 0]  v1_phit_hitb            [2:0];
    logic signed    [D_BITS-1 : 0]  v2_phit_hitb            [2:0];
    logic signed    [D_BITS-1 : 0]  triangle_norm_phit_hitb [2:0];
    
    logic           [M_BITS-1 : 0]  triangle_ID_phit_hitb;

    module hit_bool #(
        .D_BITS     (D_BITS),
        .Q_BITS     (Q_BITS),
        .M_BITS     (M_BITS)
    ) HIT_BOOL0 (
    
        .clock      (clock),
        .reset      (reset),

    // p_hit module output, normal coordinates

    input logic signed [D_BITS-1:0] p_hit [2:0],
    input logic signed [D_BITS-1:0] normal [2:0],

    // Vector inputs (these are fed into the respective FIFOs)
    input logic signed [D_BITS-1:0] v0 [2:0],
    input logic signed [D_BITS-1:0] v1 [2:0],
    input logic signed [D_BITS-1:0] v2 [2:0],
    // Internal FIFO signals
    input logic v0_in_wr_en, 
    output logic v0_in_full,
    input logic v1_in_wr_en,
    output logic v1_in_full,
    input logic v2_in_wr_en,
    output logic v2_in_full,
    input logic fifo_out_rd_en,
    input logic normal_in_wr_en,
    output logic normal_in_full,
    // Pass through data
    input logic [M_BITS-1:0] tri_id_fifo_din,
    input logic [M_BITS-1:0] ray_id_fifo_din,
    output logic [M_BITS-1:0] tri_id_fifo_dout,
    output logic [M_BITS-1:0] ray_id_fifo_dout,
    input logic tri_id_fifo_wr_en,
    input logic ray_id_fifo_wr_en,
    input logic tri_id_fifo_rd_en,
    input logic ray_id_fifo_rd_en,
    output logic tri_id_fifo_full,
    output logic ray_id_fifo_full,
    output logic tri_id_fifo_empty,
    output logic ray_id_fifo_empty,
    
    // Signals to p_hit module
    input logic p_hit_in_empty,
    output logic p_hit_in_rd_en,
    // hit_bool output fifo
    output logic fifo_out_dout,   
    output logic fifo_out_empty,
    // p_hit output FIFO
    output logic signed [D_BITS-1:0] p_hit_fifo_out_dout [2:0],
    output logic p_hit_fifo_out_empty,
    input logic p_hit_fifo_out_rd_en
); 

endmodule

