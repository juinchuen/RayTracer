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
    int ascii_count = 0;

    int sim_output_file;
    int hitb_output_file;
    int ascii_output_file;

    generate

    for (i  = 0; i < 6; i = i + 1) begin

        assign ray_data_feed [i] = ray_data_single [D_BITS * i + 31 : D_BITS * i];

    end

    endgenerate

    initial begin

        sim_output_file = $fopen("sim_output_file", "w");
        hitb_output_file = $fopen("hitb_output_file", "w");
        ascii_output_file = $fopen("ascii_output_file", "w");
        
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

        wait(out_count == 1000)

        $fclose(sim_output_file);

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

    always @ (posedge wr_en_out) begin

        if (hit_out) begin

            $fwrite(sim_output_file, "hit, %8d\n", triangle_ID_out);
            $fwrite(ascii_output_file, "%1x", triangle_ID_out);

        end

        else begin

            $fwrite(sim_output_file, "no hit\n");
            $fwrite(ascii_output_file, ".");

        end

        out_count = out_count + 1;

        ascii_count = ascii_count + 1;

        if (ascii_count == 32) begin

            $fwrite(ascii_output_file, "\n");

            ascii_count = 0;

        end

    end

    always @ (posedge rd_hitb) begin

        if (hit_hitb) begin

            $fwrite(hitb_output_file,
                    "  hit, %2d, %x, %x %x\n",
                    triangle_ID_hitb,
                    p_hit_hitb[0],
                    p_hit_hitb[1],
                    p_hit_hitb[2]);

        end

        else begin

            $fwrite(hitb_output_file, "nohit\n");

        end

    end

endmodule