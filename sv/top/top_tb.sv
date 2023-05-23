module top_tb ();

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

    int count;
    genvar i;

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

        wait(count == 1024)

        in_wr_en = 0;

        #100

        $finish;

    end

    always begin

        # 5

        clock = ~clock;

    end

    always @ (posedge clock or in_wr_en) begin

        if (!reset && in_wr_en) begin

            ray_data_single = ray_data[count];

            count = count + 1;

        end

    end

    ray_tracer_top #(

        .D_BITS     (D_BITS),
        .Q_BITS     (Q_BITS),
        .M_BITS     (M_BITS)

    ) DUT_INST0 (

        .clock              (clock),
        .reset              (reset),
        .in_wr_en           (in_wr_en),
        .ray_in             (ray_data_feed),
        .in_full            (in_full),
        .instruction_read   (instruction_read)

    );

endmodule