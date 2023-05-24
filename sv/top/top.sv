module ray_tracer_top #(

    parameter D_BITS = 'd32,
    parameter Q_BITS = 'd10,
    parameter M_BITS = 'd12

)(
    input   logic                       clock,
    input   logic                       reset,

    input   logic                       in_wr_en,
    input   logic signed [D_BITS-1 : 0] ray_in              [5:0],
    
    output  logic                       in_full,

    output  logic signed [D_BITS-1 : 0] instruction_read    [17:0],

    output logic                        hit_acc_shader,
    output logic signed  [D_BITS-1 : 0] phit_acc_shader     [2:0],
    output logic         [M_BITS-1 : 0] triangle_ID_acc_shader,
    output logic                        wr_acc_shader,

    output logic signed  [D_BITS-1 : 0] phit_hitb_acc       [2:0],
    output logic                        hit_hitb_acc,
    output logic         [M_BITS-1 : 0] triangle_ID_hitb_acc,
    output logic                        rd_acc_hitb
);

    // WIRE DECLARATION LIST

    logic           [D_BITS * 6 - 1 : 0]    ray_in_pack;
    genvar i;

    logic                                   rd_streamer_fifo0;
    logic signed    [D_BITS*6-1 : 0]        ray_fifo0_streamer;
    logic signed    [D_BITS-1 : 0]          ray_parse_fifo0_streamer [5:0];

    logic           [M_BITS-1 : 0]          addr_streamer_mem;
    logic signed    [D_BITS-1 : 0]          triangle_parse_mem_streamer [11:0];
    logic signed    [12 * D_BITS - 1 : 0]   triangle_mem_streamer;

    logic           [M_BITS-1 : 0]          mem_wr_addr;
    logic                                   mem_wr_en;
    logic           [D_BITS * 12 - 1 : 0]   mem_din;

    assign mem_wr_addr = 'b0;
    assign mem_wr_en = 0;
    assign mem_din  = 'b0;

    logic           [M_BITS-1 : 0]  triangle_ID_streamer_phit;
    logic                           full_phit_streamer;
    logic                           wr_streamer_phit;

    logic signed    [D_BITS-1 : 0]  phit_phit_hitb          [2:0];
    logic signed    [D_BITS-1 : 0]  v0_phit_hitb            [2:0];
    logic signed    [D_BITS-1 : 0]  v1_phit_hitb            [2:0];
    logic signed    [D_BITS-1 : 0]  v2_phit_hitb            [2:0];
    logic signed    [D_BITS-1 : 0]  normal_phit_hitb [2:0];
    
    logic           [M_BITS-1 : 0]  triangle_ID_phit_hitb;

    logic           [M_BITS-1 : 0]  ray_ID_dummy_in;
    logic           [M_BITS-1 : 0]  ray_ID_dummy_out;
    assign                          ray_ID_dummy_in = 'b0;

    logic                           rd_hitb_phit;
    logic                           empty_phit_hitb;

    // logic           [M_BITS-1 : 0]  triangle_ID_hitb_acc;
    // logic                           hit_hitb_acc;
    // logic signed    [D_BITS-1 : 0]  phit_hitb_acc           [2:0];
    // logic                           rd_acc_hitb;
    logic                           empty_hitb_acc;

    logic                           full_shader_acc;
    // logic                           wr_acc_shader;
    // logic                           hit_acc_shader;
    // logic signed    [D_BITS-1 : 0]  phit_acc_shader         [2:0];
    // logic           [M_BITS-1 : 0]  triangle_ID_acc_shader;

    assign                          full_shader_acc = 0;

    generate

        for (i = 0; i < 6; i = i + 1) begin

            assign ray_in_pack [D_BITS * i + 31 : D_BITS * i] = ray_in [i];

        end

    endgenerate

    fifo #(
        .FIFO_DATA_WIDTH    (6*D_BITS),
        .FIFO_BUFFER_SIZE   ('d1024)
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

    p_hit #(
        .D_BITS             (D_BITS),
        .Q_BITS             (Q_BITS),
        .M_BITS             (M_BITS)
    ) P_HIT0 (
        .clock              (clock),
        .reset              (reset),
        .tri_normal_in      (instruction_read [17:15]),
        .v0_in              (instruction_read [ 8: 6]),
        .v1_in              (instruction_read [11: 9]),
        .v2_in              (instruction_read [14:12]),
        .origin             (instruction_read [ 2: 0]),
        .dir                (instruction_read [ 5: 3]),
        .triangle_id_in     (triangle_ID_streamer_phit),
        .in_full            (full_phit_streamer),
        .in_wr_en           (wr_streamer_phit),

        .p_hit              (phit_phit_hitb),
        .v0_out             (v0_phit_hitb),
        .v1_out             (v1_phit_hitb),
        .v2_out             (v2_phit_hitb),
        .triangle_id_out    (triangle_ID_phit_hitb),
        .tri_normal_out     (normal_phit_hitb),

        .out_rd_en          (rd_hitb_phit),
        .out_empty          (empty_phit_hitb)
    );

    hit_bool #(
        .D_BITS     (D_BITS),
        .Q_BITS     (Q_BITS),
        .M_BITS     (M_BITS)
    ) HIT_BOOL0 (
        
        .clock          (clock),
        .reset          (reset),

        // p_hit data from module
        .p_hit_din      (phit_phit_hitb),

        // normal data
        .normal         (normal_phit_hitb),

        // Vector inputs 
        .v0             (v0_phit_hitb),
        .v1             (v1_phit_hitb),
        .v2             (v2_phit_hitb),

        // Pass through data
        .tri_id_din     (triangle_ID_phit_hitb),
        .ray_id_din     (ray_ID_dummy_in),
        .tri_id_dout    (triangle_ID_hitb_acc),
        .ray_id_dout    (ray_ID_dummy_out),
        
        // hit_bool output
        .hit_bool_dout  (hit_hitb_acc),

        // p_hit output (passed through)
        .p_hit_dout     (phit_hitb_acc),

        // Tied together FIFO signals 
        .in_rd_en       (rd_hitb_phit),     // Signal that reads from p_hit's output FIFOs
        .out_rd_en      (rd_acc_hitb),      // Read enable for all output FIFOs
        .in_empty       (empty_phit_hitb),  // Signal that indicates if any of p_hit's output FIFOs are empty
        .out_empty      (empty_hitb_acc)    // Signal that indicates if any output FIFOs in this module are empty
    ); 

    accumulate #(
        .Q_BITS     (Q_BITS),
        .D_BITS     (D_BITS),
        .M_BITS     (M_BITS)
    ) ACC0 (
        .clock          (clock),
        .reset          (reset),

        .in_empty       (empty_hitb_acc),
        .in_rd_en       (rd_acc_hitb),

        .out_full       (full_shader_acc),
        .out_wr_en      (wr_acc_shader),

        .hit            (hit_hitb_acc),
        .p_hit          (phit_hitb_acc),
        .triangle_ID    (triangle_ID_hitb_acc),

        .hit_min            (hit_acc_shader),
        .p_hit_min          (phit_acc_shader),
        .triangle_ID_min    (triangle_ID_acc_shader)
    );

endmodule

