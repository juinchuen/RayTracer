`timescale 1 ns / 1 ns

module hit_bool_tb;

localparam P_HIT_FILE = "data_files/p_hit.txt";
localparam P_HIT_CMP_FILE = "data_files/p_hit_cmp.txt";
localparam P_HIT_OUT_FILE = "data_files/p_hit_out.txt";
localparam HIT_BOOL_FILE = "data_files/hit_bool.txt";
localparam HIT_BOOL_CMP_FILE = "data_files/hit_bool_cmp.txt";
localparam TRIANGLE_ID_FILE = "data_files/triangle_id.txt";
localparam RAY_ID_FILE = "data_files/ray_id.txt";
localparam RAY_ORIGIN_FILE = "data_files/ray_origin.txt";
localparam TRIANGLE_ID_OUT_FILE = "data_files/triangle_id_out.txt";
localparam RAY_ID_OUT_FILE = "data_files/ray_id_out.txt";
localparam RAY_ORIGIN_OUT_FILE = "data_files/ray_origin_out.txt";
localparam TRIANGLE_ID_CMP_FILE = "data_files/triangle_id_cmp.txt";
localparam RAY_ID_CMP_FILE = "data_files/ray_id_cmp.txt";
localparam RAY_ORIGIN_CMP_FILE = "data_files/ray_origin_cmp.txt";
localparam int CLOCK_PERIOD = 10;
localparam int DATA_PTS = 256;
localparam Q_BITS = 'd16;
localparam D_BITS = 'd32;
localparam M_BITS = 'd12;
localparam SEEK_END = 2;
localparam SEEK_SET = 0;
int cycle, counter, errors = 0; // Cycle keeps track of current cycle, counter keeps track of data points generated

// Module variables
logic clock = 1'b1;
logic reset = '0;

logic signed [D_BITS-1:0] v0 [2:0] = {32'hffff8000, 32'hffff8000, 32'h60000};
logic signed [D_BITS-1:0] v1 [2:0] = {32'h10000, 32'h8000, 32'h50000};
logic signed [D_BITS-1:0] v2 [2:0] = {32'h10000, 32'hffff8000, 32'h50000};

logic signed [D_BITS-1:0] normal [2:0] = {32'hd504, 32'h0, 32'h8e00};

// Things that stream in:
// p_hit values
logic p_hit_fifo_wr_en;
logic signed [D_BITS-1:0] p_hit_fifo_din [2:0];
logic p_hit_fifo_full;
logic signed [D_BITS-1:0] p_hit_fifo_dout [2:0];
logic p_hit_fifo_empty;
logic signed [D_BITS-1:0] p_hit_fifo_out_dout [2:0];

logic in_rd_en;
fifo_array #(
    .FIFO_DATA_WIDTH         (D_BITS),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) p_hit_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (p_hit_fifo_wr_en),
    .din                     (p_hit_fifo_din[2:0]),
    .full                    (p_hit_fifo_full),
    .rd_en                   (in_rd_en),
    .dout                    (p_hit_fifo_dout[2:0]),
    .empty                   (p_hit_fifo_empty)
);

logic tri_id_fifo_wr_en;
logic tri_id_fifo_full;
logic tri_id_fifo_empty;
logic [M_BITS-1:0] tri_id_fifo_din;
logic [M_BITS-1:0] tri_id_fifo_dout;
fifo #(
    .FIFO_DATA_WIDTH     (M_BITS),
    .FIFO_BUFFER_SIZE    (1024)
) triangle_id_fifo (
    .reset               (reset),
    .wr_clk              (clock),
    .wr_en               (tri_id_fifo_wr_en),
    .din                 (tri_id_fifo_din),
    .full                (tri_id_fifo_full),
    .rd_clk              (clock),
    .rd_en               (in_rd_en),
    .dout                (tri_id_fifo_dout),
    .empty               (tri_id_fifo_empty)
);

logic ray_id_fifo_wr_en;
logic ray_id_fifo_full;
logic ray_id_fifo_empty;
logic [M_BITS-1:0] ray_id_fifo_din;
logic [M_BITS-1:0] ray_id_fifo_dout;
fifo #(
    .FIFO_DATA_WIDTH     (M_BITS),
    .FIFO_BUFFER_SIZE    (1024)
) ray_id_fifo (
    .reset               (reset),
    .wr_clk              (clock),
    .wr_en               (ray_id_fifo_wr_en),
    .din                 (ray_id_fifo_din),
    .full                (ray_id_fifo_full),
    .rd_clk              (clock),
    .rd_en               (in_rd_en),
    .dout                (ray_id_fifo_dout),
    .empty               (ray_id_fifo_empty)
);

logic ray_origin_fifo_wr_en;
logic ray_origin_fifo_full;
logic ray_origin_fifo_empty;
logic signed [D_BITS-1:0] ray_origin_fifo_din [2:0];
logic signed [D_BITS-1:0] ray_origin_fifo_dout [2:0];

fifo_array #(
    .FIFO_DATA_WIDTH         (D_BITS),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) ray_origin_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (ray_origin_fifo_wr_en),
    .din                     (ray_origin_fifo_din[2:0]),
    .full                    (ray_origin_fifo_full),
    .rd_en                   (in_rd_en),
    .dout                    (ray_origin_fifo_dout[2:0]),
    .empty                   (ray_origin_fifo_empty)
);

// Hit bool module
logic hit_bool_fifo_out_dout;
logic [M_BITS-1:0] tri_id_dout;
logic [M_BITS-1:0] ray_id_dout;
logic signed [D_BITS-1:0] ray_origin_dout [2:0];

logic out_rd_en;
logic in_empty;
logic out_empty;

assign in_empty = p_hit_fifo_empty && tri_id_fifo_empty && ray_id_fifo_empty;

hit_bool #(
    .D_BITS             (D_BITS),
    .Q_BITS             (Q_BITS),
    .M_BITS             (M_BITS)
) u_hit_bool (
    //
    .clock              (clock),
    .reset              (reset),
    // p_hit module output, normal coordinates
    .p_hit_din          (p_hit_fifo_dout[2:0]),
    .normal             (normal[2:0]),
    // Vector inputs (these are fed into the respective FIFOs)
    .v0                 (v0[2:0]),
    .v1                 (v1[2:0]),
    .v2                 (v2[2:0]),
    // Pass through data
    .tri_id_din(tri_id_fifo_dout),
    .ray_id_din(ray_id_fifo_dout),
    .ray_origin_din(ray_origin_fifo_dout[2:0]),
    .tri_id_dout(tri_id_dout),
    .ray_id_dout(ray_id_dout),
    .ray_origin_dout(ray_origin_dout[2:0]),
    // hit_bool and p_hit outputs 
    .hit_bool_dout   (hit_bool_fifo_out_dout),
    .p_hit_dout(p_hit_fifo_out_dout),
    // tied signals
    .in_rd_en(in_rd_en),
    .out_rd_en(out_rd_en),
    .in_empty(in_empty),
    .out_empty(out_empty)
);

logic signed [D_BITS-1:0] temp0;
logic signed [D_BITS-1:0] temp1;
logic signed [D_BITS-1:0] temp2;

logic signed [D_BITS-1:0] temp3;
logic signed [D_BITS-1:0] temp4;
logic signed [D_BITS-1:0] temp5;

logic signed [D_BITS-1:0] cmp_dout [2:0];
logic hit_bool_cmp_dout;
logic [M_BITS-1:0] tri_id_cmp_dout = 0;
logic [M_BITS-1:0] ray_id_cmp_dout = 0;
logic signed [D_BITS-1:0] ray_origin_cmp_dout [2:0];

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

initial begin: test
    // Load p_hit txt file
    int p_hit_file, p_hit_cmp_file, p_hit_out_file;
    int hit_bool_file, hit_bool_cmp_file;
    int triangle_id_file, ray_id_file, ray_origin_file;
    int triangle_id_out_file, ray_id_out_file, ray_origin_out_file;
    int triangle_id_cmp_file, ray_id_cmp_file, ray_origin_cmp_file;
    int pos, length;
    int hit_pos, hit_length;
    int tri_pos, tri_length;
    int ray_id_pos, ray_id_length;
    int ray_origin_pos, ray_origin_length;

    // Open files
    p_hit_file = $fopen(P_HIT_FILE, "rb");
    p_hit_cmp_file = $fopen(P_HIT_CMP_FILE, "rb");
    p_hit_out_file = $fopen(P_HIT_OUT_FILE, "wb");
    hit_bool_file = $fopen(HIT_BOOL_FILE, "wb");
    hit_bool_cmp_file = $fopen(HIT_BOOL_CMP_FILE, "rb");
    triangle_id_file = $fopen(TRIANGLE_ID_FILE, "r");
    ray_id_file = $fopen(RAY_ID_FILE, "r");
    ray_origin_file = $fopen(RAY_ORIGIN_FILE, "r");
    triangle_id_out_file = $fopen(TRIANGLE_ID_OUT_FILE, "w");
    ray_id_out_file = $fopen(RAY_ID_OUT_FILE, "w");
    ray_origin_out_file = $fopen(RAY_ORIGIN_OUT_FILE, "w");
    triangle_id_cmp_file = $fopen(TRIANGLE_ID_CMP_FILE, "r");
    ray_id_cmp_file = $fopen(RAY_ID_CMP_FILE, "r");
    ray_origin_cmp_file = $fopen(RAY_ORIGIN_CMP_FILE, "r");

    pos = $ftell(p_hit_cmp_file);
    $fseek(p_hit_cmp_file, 0, SEEK_END);
    length = $ftell(p_hit_cmp_file);
    $fseek(p_hit_cmp_file, pos, SEEK_SET);

    tri_pos = $ftell(triangle_id_cmp_file);
    $fseek(triangle_id_cmp_file, 0, SEEK_END);
    tri_length = $ftell(triangle_id_cmp_file);
    $fseek(triangle_id_cmp_file, tri_pos, SEEK_SET);

    ray_id_pos = $ftell(ray_id_cmp_file);
    $fseek(ray_id_cmp_file, 0, SEEK_END);
    ray_id_length = $ftell(ray_id_cmp_file);
    $fseek(ray_id_cmp_file, ray_id_pos, SEEK_SET);

    ray_origin_pos = $ftell(ray_origin_cmp_file);
    $fseek(ray_origin_cmp_file, 0, SEEK_END);
    ray_origin_length = $ftell(ray_origin_cmp_file);
    $fseek(ray_origin_cmp_file, ray_origin_pos, SEEK_SET);

    hit_pos = $ftell(hit_bool_cmp_file);
    $fseek(hit_bool_cmp_file, 0, SEEK_END);
    hit_length = $ftell(hit_bool_cmp_file);
    $fseek(hit_bool_cmp_file, hit_pos, SEEK_SET);


    // End when all P hit data has been read in, and an equivalent amount 
    // of hit data points have been generated
    @(negedge reset);
    while (!$feof(p_hit_file) || counter < DATA_PTS) begin
        @(negedge clock)
        // Set write of p_hit fifo to 0
        p_hit_fifo_wr_en = 1'b0;
        tri_id_fifo_wr_en = 1'b0;
        ray_id_fifo_wr_en = 1'b0;

        // Set read enable to 0
        out_rd_en = 1'b0;

        // Insert p_hit values into FIFO
        if (!p_hit_fifo_full)begin
            $fscanf(p_hit_file, "%x, %x, %x\n", temp0, temp1, temp2);
            p_hit_fifo_din[0] = temp0;
            p_hit_fifo_din[1] = temp1;
            p_hit_fifo_din[2] = temp2;
            p_hit_fifo_wr_en = 1'b1;
            // // Feed in triangle ID and ray ID values to hit_bool
            // $fscanf(triangle_id_file, "%d\n", tri_id_fifo_din);
            // $fscanf(ray_id_file, "%d\n", ray_id_fifo_din);
        end
        if (!tri_id_fifo_full)begin
            $fscanf(triangle_id_file, "%d\n", tri_id_fifo_din);
            tri_id_fifo_wr_en = 1'b1;
        end
        if (!ray_id_fifo_full)begin
            $fscanf(ray_id_file, "%d\n", ray_id_fifo_din);
            ray_id_fifo_wr_en = 1'b1;
        end

        if (!ray_origin_fifo_full)begin
            $fscanf(ray_origin_file, "%x, %x, %x \n", temp3, temp4, temp5);
            ray_origin_fifo_din[0] = temp3;
            ray_origin_fifo_din[1] = temp4;
            ray_origin_fifo_din[2] = temp5;
            ray_origin_fifo_wr_en = 1'b1;
        end

        if (!out_empty) begin
            // check hit_bool output
            $fscanf(hit_bool_cmp_file, "%d\n", hit_bool_cmp_dout);
            $fwrite(hit_bool_file, "%d\n", hit_bool_fifo_out_dout);
            if (hit_bool_cmp_dout != hit_bool_fifo_out_dout)begin
                errors+=1;
                $write("@ %0t: ERROR: HIT_BOOL: %d != %d\n", $time, hit_bool_fifo_out_dout, hit_bool_cmp_dout);
            end

            // Check to see if P_hit was passed through properly
            $fscanf(p_hit_cmp_file, "%x, %x, %x\n", cmp_dout[0], cmp_dout[1], cmp_dout[2]);
            $fwrite(p_hit_out_file, "%x, %x, %x\n", p_hit_fifo_out_dout[0], p_hit_fifo_out_dout[1], p_hit_fifo_out_dout[2]);
            if (cmp_dout[0] != p_hit_fifo_out_dout[0]) begin
                errors += 1;
                $write("@ %0t: ERROR: X: %08x != %08x\n", $time, p_hit_fifo_out_dout[0], cmp_dout[0]);
            end
            if (cmp_dout[1] != p_hit_fifo_out_dout[1]) begin
                errors += 1;
                $write("@ %0t: ERROR: Y: %08x != %08x\n", $time, p_hit_fifo_out_dout[1], cmp_dout[1]);
            end
            if (cmp_dout[2] != p_hit_fifo_out_dout[2]) begin
                errors += 1;
                $write("@ %0t: ERROR: Z: %08x != %08x\n", $time, p_hit_fifo_out_dout[2], cmp_dout[2]);
            end
            // Check to see if triangle_id was passed through properly
            $fscanf(triangle_id_cmp_file, "%d\n", tri_id_cmp_dout);
            $fwrite(triangle_id_out_file, "%d\n", tri_id_dout);
            if (tri_id_cmp_dout != tri_id_dout)begin
                errors += 1;
                $write("@ %0t: ERROR: triangle_id: %08x != %08x\n", $time, tri_id_dout, tri_id_cmp_dout);
            end
            // Check to see if ray_id was passed through properly
            $fscanf(ray_id_cmp_file, "%d\n", ray_id_cmp_dout);
            $fwrite(ray_id_out_file, "%d\n", ray_id_dout);
            if (ray_id_cmp_dout != ray_id_dout)begin
                errors += 1;
                $write("@ %0t: ERROR: ray_id: %08x != %08x\n", $time, ray_id_dout, ray_id_cmp_dout);
            end

            // Check to see if ray_origin was passed through properly
            $fscanf(ray_origin_cmp_file, "%x, %x, %x\n", ray_origin_cmp_dout[0], ray_origin_cmp_dout[1], ray_origin_cmp_dout[2]);
            $fwrite(ray_origin_out_file, "%x, %x, %x\n", ray_origin_dout[0], ray_origin_dout[1], ray_origin_dout[2] );
            if (ray_origin_cmp_dout[0] != ray_origin_dout[0])begin
                errors += 1;
                $write("@ %0t: ERROR: ray_origin X: %08x != %08x\n", $time, ray_origin_dout[0], ray_origin_cmp_dout[0]);
            end
            if (ray_origin_cmp_dout[1] != ray_origin_dout[1])begin
                errors += 1;
                $write("@ %0t: ERROR: ray_origin Y: %08x != %08x\n", $time, ray_origin_dout[1], ray_origin_cmp_dout[1]);
            end
            if (ray_origin_cmp_dout[2] != ray_origin_dout[2])begin
                errors += 1;
                $write("@ %0t: ERROR: ray_origin Z: %08x != %08x\n", $time, ray_origin_dout[2], ray_origin_cmp_dout[2]);
            end
            out_rd_en = 1'b1;
            counter++;
        end
        cycle++;
    end
    $fclose(p_hit_file);
    $fclose(hit_bool_file);
    $fclose(p_hit_cmp_file);
    $fclose(p_hit_out_file);
    $fclose(triangle_id_file);
    $fclose(ray_id_file);
    $fclose(triangle_id_out_file);
    $fclose(ray_id_out_file);
    $fclose(triangle_id_cmp_file);
    $fclose(ray_id_cmp_file);
    $finish;
end

endmodule