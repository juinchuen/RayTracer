module top_test_tb ();

    localparam D_BITS = 'd32;
    localparam M_BITS = 'd12;
    localparam Q_BITS = 'd10;

    logic clock;
    logic reset;

    logic in_wr_en;

    logic in_full;
    logic signed [D_BITS-1 : 0] instruction_read [17:0];

    logic signed [6 * D_BITS - 1 : 0]  ray_data        [1023:0];

    logic signed [6 * D_BITS - 1 : 0]  ray_data_single;

    logic signed [D_BITS-1 : 0]        ray_data_feed   [5:0];

    logic        [M_BITS-1 : 0] triangle_ID_out;
    logic signed [D_BITS-1 : 0] p_hit_out              [2:0];
    logic                       hit_out;
    logic                       wr_en_out;

    logic        [M_BITS-1 : 0] triangle_ID_hitb;
    logic signed [D_BITS-1 : 0] p_hit_hitb             [2:0];
    logic                       hit_hitb;
    logic                       rd_hitb;

    int count;
    genvar i;

    int out_count = 0;

    generate

    for (i  = 0; i < 6; i = i + 1) begin

        assign ray_data_feed [i] = ray_data_single [D_BITS * i + 31 : D_BITS * i];

    end

    endgenerate

    initial begin
        
        $display("Loading ray data");
        $readmemh("../ray_data.txt", ray_data);

        clock = 1;
        reset = 0;

        count = 0;

        in_wr_en = 0;
        
        # 5

        reset = 1;

        # 10

        reset = 0;
        in_wr_en = 1;

        ray_data_single = ray_data[238];

        # 20

        in_wr_en = 0;

        wait(wr_en_out);

        $finish;

    end

    always begin

        # 5

        clock = ~clock;

    end

    ray_tracer_top #(

        .D_BITS     (D_BITS),
        .Q_BITS     (Q_BITS),
        .M_BITS     (M_BITS)

    ) DUT_INST0 (

        .clock                      (clock),
        .reset                      (reset),
        .in_wr_en                   (in_wr_en),
        .ray_in                     (ray_data_feed),
        .in_full                    (in_full),
        .instruction_read           (instruction_read),
        .hit_acc_shader             (hit_out),
        .phit_acc_shader            (p_hit_out),
        .triangle_ID_acc_shader     (triangle_ID_out),
        .wr_acc_shader              (wr_en_out),

        .phit_hitb_acc              (p_hit_hitb),
        .hit_hitb_acc               (hit_hitb),
        .triangle_ID_hitb_acc       (triangle_ID_hitb),
        .rd_acc_hitb                (rd_hitb)

    );

endmodule