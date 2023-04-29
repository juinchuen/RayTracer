`timescale 1 ns / 1 ns

module hit_bool_tb;

localparam P_HIT_FILE = "data_files/p_hit.txt";
localparam HIT_BOOL_FILE = "data_files/hit_bool.txt";
localparam int CLOCK_PERIOD = 10;
localparam int DATA_PTS = 256;
localparam Q_BITS = 16;
int cycle, counter = 0; // Cycle keeps track of current cycle, counter keeps track of data points generated

// Module variables
logic clock = 1'b1;
logic reset = '0;

logic signed [31:0] v0 [2:0] = {32'hffff8000, 32'hffff8000, 32'h60000};
logic signed [31:0] v1 [2:0] = {32'h10000, 32'h8000, 32'h50000};
logic signed [31:0] v2 [2:0] = {32'h10000, 32'hffff8000, 32'h50000};


// Things that stream in:
// - Normal vector
logic normal_fifo_wr_en;
logic normal_fifo_rd_en;
logic normal_fifo_full;
logic normal_fifo_empty;
logic signed [31:0] normal_fifo_din  [2:0] = {32'hd504, 32'h0, 32'h8e00};
logic signed [31:0] normal_fifo_dout [2:0];
fifo_array #(
    .FIFO_DATA_WIDTH         (32),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) normal_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (normal_fifo_wr_en),
    .din                     (normal_fifo_din[2:0]),
    .full                    (normal_fifo_full),
    .rd_en                   (normal_fifo_rd_en),
    .dout                    (normal_fifo_dout[2:0]),
    .empty                   (normal_fifo_empty)
);

// Vector fifos
logic v0_fifo_wr_en;
logic v0_fifo_full;
logic v0_fifo_rd_en;
logic signed [31:0] v0_fifo_dout[2:0];
logic v0_fifo_empty;
fifo_array #(
    .FIFO_DATA_WIDTH         (32),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) v0_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (v0_fifo_wr_en),
    .din                     (v0[2:0]),
    .full                    (v0_fifo_full),
    .rd_en                   (v0_fifo_rd_en),
    .dout                    (v0_fifo_dout[2:0]),
    .empty                   (v0_fifo_empty)
);
logic v1_fifo_wr_en;
logic v1_fifo_full;
logic v1_fifo_rd_en;
logic signed [31:0] v1_fifo_dout[2:0];
logic v1_fifo_empty;
fifo_array #(
    .FIFO_DATA_WIDTH         (32),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) v1_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (v1_fifo_wr_en),
    .din                     (v1[2:0]),
    .full                    (v1_fifo_full),
    .rd_en                   (v1_fifo_rd_en),
    .dout                    (v1_fifo_dout[2:0]),
    .empty                   (v1_fifo_empty)
);
logic v2_fifo_wr_en;
logic v2_fifo_full;
logic v2_fifo_rd_en;
logic signed [31:0] v2_fifo_dout[2:0];
logic v2_fifo_empty;
fifo_array #(
    .FIFO_DATA_WIDTH         (32),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) v2_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (v2_fifo_wr_en),
    .din                     (v2[2:0]),
    .full                    (v2_fifo_full),
    .rd_en                   (v2_fifo_rd_en),
    .dout                    (v2_fifo_dout[2:0]),
    .empty                   (v2_fifo_empty)
);

// p_hit values
logic p_hit_fifo_wr_en;
logic signed [31:0] p_hit_fifo_din [2:0];
logic p_hit_fifo_full;
logic p_hit_fifo_rd_en;
logic signed [31:0] p_hit_fifo_dout [2:0];
logic p_hit_fifo_empty;
fifo_array #(
    .FIFO_DATA_WIDTH         (32),
    .FIFO_BUFFER_SIZE        (1024),
    .ARRAY_SIZE              (3)
) p_hit_fifo_array (
    .reset                   (reset),
    .clock                   (clock),
    .wr_en                   (p_hit_fifo_wr_en),
    .din                     (p_hit_fifo_din[2:0]),
    .full                    (p_hit_fifo_full),
    .rd_en                   (p_hit_fifo_rd_en),
    .dout                    (p_hit_fifo_dout[2:0]),
    .empty                   (p_hit_fifo_empty)
);

// Hit bool module
logic hit_bool_fifo_out_rd_en;
logic hit_bool_fifo_out_dout;
logic hit_bool_fifo_out_empty;
hit_bool #(
    .Q_BITS               ('d16)
) u_hit_bool (
    //
    .clock                (clock),
    .reset                (reset),
    // p_hit module output, normal coordinates
    .p_hit                (p_hit_fifo_dout[2:0]),
    .normal               (normal_fifo_dout[2:0]),
    // Vector inputs
    .v0                   (v0_fifo_dout[2:0]),
    .v1                   (v1_fifo_dout[2:0]),
    .v2                   (v2_fifo_dout[2:0]),
    .fifo_out_rd_en       (hit_bool_fifo_out_rd_en),
    .triangle_in_empty    (normal_fifo_empty),
    .triangle_in_rd_en    (normal_fifo_rd_en),
    .p_hit_in_empty       (p_hit_fifo_empty),
    .p_hit_in_rd_en       (p_hit_fifo_rd_en),
    .v0_in_empty          (v0_fifo_empty),
    .v0_in_rd_en          (v0_fifo_rd_en),
    .v1_in_empty          (v1_fifo_empty),
    .v1_in_rd_en          (v1_fifo_rd_en),
    .v2_in_empty          (v2_fifo_empty),
    .v2_in_rd_en          (v2_fifo_rd_en),
    .fifo_out_dout        (hit_bool_fifo_out_dout),
    .fifo_out_empty       (hit_bool_fifo_out_empty)
);

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
    int p_hit_file;
    int hit_bool_file;
    int temp0;
    int temp1;
    int temp2;

    // Open files
    p_hit_file = $fopen(P_HIT_FILE, "rb");
    hit_bool_file = $fopen(HIT_BOOL_FILE, "wb");

    // End when all P hit data has been read in, and an equivalent amount 
    // of hit data points have been generated
    while (!$feof(p_hit_file) || counter < DATA_PTS) begin
        @(negedge clock)
        p_hit_fifo_wr_en = 1'b0;
        normal_fifo_wr_en = 1'b0;
        v0_fifo_wr_en = 1'b0;
        v1_fifo_wr_en = 1'b0;
        v2_fifo_wr_en = 1'b0;
        hit_bool_fifo_out_rd_en = 1'b0;
        if (p_hit_fifo_full == 1'b0)begin
            $fscanf(p_hit_file, "%x, %x, %x\n", temp0, temp1, temp2);
            p_hit_fifo_din[0] = temp0;
            p_hit_fifo_din[1] = temp1;
            p_hit_fifo_din[2] = temp2;
            p_hit_fifo_wr_en = 1'b1;
            normal_fifo_wr_en = 1'b1;
            v0_fifo_wr_en = 1'b1;
            v1_fifo_wr_en = 1'b1;
            v2_fifo_wr_en = 1'b1;
        end
        if (hit_bool_fifo_out_empty == 1'b0) begin
            if (hit_bool_fifo_out_dout)begin
                $fwrite(hit_bool_file, "true\n");
            end else begin
                $fwrite(hit_bool_file, "false\n");
            end
            hit_bool_fifo_out_rd_en = 1'b1;
            counter++;
        end
        cycle++;
    end
    $fclose(p_hit_file);
    $fclose(hit_bool_file);
    $finish;
end

endmodule