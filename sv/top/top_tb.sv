module top_tb ();

    localparam D_BITS = 'd32;
    localparam M_BITS = 'd12;
    localparam Q_BITS = 'd10;

    logic clock;
    logic reset;

    logic in_wr_en;
    logic [D_BITS-1 : 0] ray_in [5:0];

    logic in_full;
    logic signed [D_BITS-1 : 0] instruction_read [17:0];

    initial begin

        clock = 1;
        reset = 0;

        in_wr_en = 0;

        ray_in [0] = 'd0;
        ray_in [1] = 'd0;
        ray_in [2] = 'd0;
        ray_in [3] = 'd0;
        ray_in [4] = 'd0;
        ray_in [5] = 'd0;
        
        # 5

        reset = 1;

        # 10

        reset = 0;
        in_wr_en = 1;

        # 100

        in_wr_en = 0;

        #3000

        $finish;

    end

    always begin

        # 5

        clock = ~clock;

    end

    always @ (posedge clock) begin

        ray_in [0] = ray_in [0] + 1;
        ray_in [1] = ray_in [1] + 1;
        ray_in [2] = ray_in [2] + 1;
        ray_in [3] = ray_in [3] + 1;
        ray_in [4] = ray_in [4] + 1;
        ray_in [5] = ray_in [5] + 1;

    end

    ray_tracer_top #(

        .D_BITS     (D_BITS),
        .Q_BITS     (Q_BITS),
        .M_BITS     (M_BITS)

    ) DUT_INST0 (

        .clock              (clock),
        .reset              (reset),
        .in_wr_en           (in_wr_en),
        .ray_in             (ray_in),
        .in_full            (in_full),
        .instruction_read   (instruction_read)

    );

endmodule