`timescale 1ns/1ns

module tb();

localparam string TRIANGLE_IN_2 = "../../test_data/triangle_normal_2.txt";
localparam string TRIANGLE_IN_1 = "../../test_data/triangle_normal.txt";
localparam string V0_IN = "../../test_data/triangle_data.txt";
localparam string ORIGIN_IN_1 = "../../test_data/ray_origin_data.txt";
localparam string ORIGIN_IN_2 = "../../test_data/ray_origin_data_2.txt";
localparam string DIR_IN_1 = "../../test_data/ray_dir_data.txt";
localparam string DIR_IN_2 = "../../test_data/ray_dir_data_2.txt";
localparam string TXT_CMP = "../../test_data/p_hit.txt";
localparam string TXT_OUT = "txt/out.txt";
localparam CLOCK_PERIOD = 10;

localparam D_BITS = 'd32;
localparam Q_BITS = 'd16;

localparam SEEK_END = 2;
localparam SEEK_SET = 0;

int errors = '0;

logic clock = 1'b1;
logic reset = '0;
// logic in_write_done = '0;
logic out_read_done = '0;

//inputs
logic in_wr_en[3:0], in_full[3:0];
logic signed [D_BITS-1:0] tri_normal_1[2:0], tri_normal_2[2:0];
logic signed [D_BITS-1:0] v0[2:0];
logic signed [D_BITS-1:0] origin_1[2:0], origin_2[2:0];
logic signed [D_BITS-1:0] dir_1[2:0], dir_2[2:0];
logic signed [D_BITS-1:0] v0_out[2:0];

//outputs
logic out_empty, out_rd_en;
logic signed [D_BITS-1:0] out[2:0];

p_hit #(
    .D_BITS               (D_BITS),
    .Q_BITS               (Q_BITS)
) u_p_hit (
    .clock                (clock),
    .reset                (reset),
    .tri_normal_in        (tri_normal_1[2:0]),
    .v0_in                (v0[2:0]),
    .origin_in               (origin_1[2:0]),
    .dir                  (dir_1[2:0]),
    .in_full              (in_full[0]),
    .in_wr_en             (in_wr_en[0]),
    .p_hit                (out[2:0]),
    .out_rd_en            (out_rd_en),
    .out_empty            (out_empty),
    .v0_out               (v0_out[2:0])
);

///testing
logic[D_BITS-1:0] temparr1, temparr2, temparr3;
logic temp1, temp2, temp3, temp4;

always_comb begin
    temp1 = in_wr_en[0];
    temp2 = in_wr_en[1];
    temp3 = in_full[0];
    temp4 = in_full[1];
    temparr1 = origin_2[0];
    temparr2 = origin_2[1];
    temparr3 = origin_2[2];
end
///testing

always begin
    clock = 1'b1;
    #(CLOCK_PERIOD/2);
    clock = 1'b0;
    #(CLOCK_PERIOD/2);
end

initial begin
    @(posedge clock);
    reset = 1'b1;
    @(posedge clock);
    reset = 1'b0;
end

initial begin : setting_up_constant_inputs
    int in_file[2:0];
    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, V0_IN);
    $display("@ %0t: Loading file %s...", $time, TRIANGLE_IN_1);
    $display("@ %0t: Loading file %s...", $time, TRIANGLE_IN_2);

    in_file[0] = $fopen(V0_IN, "rb");
    in_file[1] = $fopen(TRIANGLE_IN_1, "rb");
    in_file[2] = $fopen(TRIANGLE_IN_2, "rb");

    $fscanf(in_file[0], "%x, %x, %x\n", v0[0], v0[1], v0[2]);
    $fscanf(in_file[1], "%x, %x, %x\n", tri_normal_1[0], tri_normal_1[1], tri_normal_1[2]);
    $fscanf(in_file[2], "%x, %x, %x\n", tri_normal_2[0], tri_normal_2[1], tri_normal_2[2]);

    $fclose(in_file[0]);
    $fclose(in_file[1]);
    $fclose(in_file[2]);
end

initial begin : txt_read_process
    int in_file[3:0];
    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, ORIGIN_IN_1);
    $display("@ %0t: Loading file %s...", $time, ORIGIN_IN_2);
    $display("@ %0t: Loading file %s...", $time, DIR_IN_1);
    $display("@ %0t: Loading file %s...", $time, DIR_IN_2);

    
    in_file[0] = $fopen(ORIGIN_IN_1, "rb");
    in_file[1] = $fopen(ORIGIN_IN_2, "rb");
    in_file[2] = $fopen(DIR_IN_1,    "rb");
    in_file[3] = $fopen(DIR_IN_2,    "rb");

    in_wr_en[0] = 1'b0;
    in_wr_en[1] = 1'b0;
    in_wr_en[2] = 1'b0;
    in_wr_en[3] = 1'b0;

    while (!$feof(in_file[0]) && !$feof(in_file[1])) begin
        @(negedge clock);
        in_wr_en[0] = 1'b0;
        in_wr_en[1] = 1'b0;
        in_wr_en[2] = 1'b0;
        in_wr_en[3] = 1'b0;
        if (!in_full[0] || !in_full[1] || !in_full[2] || !in_full[3]) begin
            $fscanf(in_file[0], "%x, %x, %x\n", origin_1[0], origin_1[1], origin_1[2]);
            $fscanf(in_file[1], "%x, %x, %x\n", origin_2[0], origin_2[1], origin_2[2]);
            $fscanf(in_file[2], "%x, %x, %x\n", dir_1[0], dir_1[1], dir_1[2]);
            $fscanf(in_file[3], "%x, %x, %x\n", dir_2[0], dir_2[1], dir_2[2]);
            in_wr_en[0] = 1'b1;
            in_wr_en[1] = 1'b1;
            in_wr_en[2] = 1'b1;
            in_wr_en[3] = 1'b1;
        end
    end

    @(negedge clock);
    in_wr_en[0] = 1'b0;
    in_wr_en[1] = 1'b0;
    in_wr_en[2] = 1'b0;
    in_wr_en[3] = 1'b0;
    $fclose(in_file[0]);
    $fclose(in_file[1]);
    // in_write_done = 1'b1;
end

initial begin: txt_write_process
    int j;
    int out_file, cmp_file;
    int pos, length;
    logic signed [D_BITS-1:0] cmp_dout[2:0];
    @(negedge reset);
    @(negedge clock);

    $display("@ %0t: Comparing file %s...", $time, TXT_OUT);

    out_file = $fopen(TXT_OUT, "wb");
    cmp_file = $fopen(TXT_CMP, "rb");
    
    out_rd_en = 1'b0;

    pos = $ftell(cmp_file);
    $fseek(cmp_file, 0, SEEK_END);
    length = $ftell(cmp_file);
    $fseek(cmp_file, pos, SEEK_SET);

    while (j < length) begin
        @(negedge clock);
        out_rd_en = 1'b0;
        if (!out_empty) begin
            $fscanf(cmp_file, "%x, %x, %x\n", cmp_dout[0], cmp_dout[1], cmp_dout[2]);
            $fwrite(out_file, "%x, %x, %x\n", out[0], out[1], out[2]);

            if (cmp_dout[0] != out[0]) begin
                errors += 1;
                $write("@ %0t: ERROR: %x != %x\n", $time, out[0], cmp_dout[0]);
            end
            out_rd_en = 1'b1;
            j = j + 8;
        end
    end
    
    @(negedge clock);
    out_rd_en = 1'b0;
    $fclose(TXT_OUT);
    $fclose(TXT_CMP);
    out_read_done = 1'b1;
end

initial begin : tb_process
    longint unsigned start_time, end_time;

    @(negedge reset);
    @(posedge clock);
    start_time = $time;

    // start
    $display("@ %0t: Beginning simulation...", start_time);
    @(posedge clock);

    wait(out_read_done);
    end_time = $time;

    // report metrics
    $display("@ %0t: Simulation completed.", end_time);
    $display("Total simulation cycle count: %0d", (end_time-start_time)/CLOCK_PERIOD);
    $display("Total error count: %0d", errors);

    // end the simulation
    $finish;
end

endmodule
