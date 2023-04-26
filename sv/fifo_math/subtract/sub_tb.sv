`timescale 1ns/1ns

module tb();

localparam string TXT_IN_1 = "../txt/x.txt";
localparam string TXT_IN_2 = "../txt/y.txt";
localparam string TXT_CMP = "../txt/cmp_array.txt";
localparam string TXT_OUT = "out.txt";
localparam CLOCK_PERIOD = 10;

localparam SEEK_END = 2;
localparam SEEK_SET = 0;

int errors = '0;

logic clock = 1'b1;
logic reset = '0;
// logic in_write_done = '0;
logic out_read_done = '0;

logic in_wr_en;
logic signed [31:0] x_din[2:0], y_din[2:0];
logic out_empty, out_rd_en;
logic signed [31:0] dout[2:0];


logic signed [31:0] x[2:0], y[2:0];
logic x_empty, y_empty, in_empty, in_rd_en;

fifo_array #(
    .FIFO_DATA_WIDTH   (32),
    .FIFO_BUFFER_SIZE  (1024),
    .ARRAY_SIZE        (3)
) fifo_array_x (
    .reset             (reset),
    .clock             (clock),
    .wr_en             (in_wr_en),
    .din               (x_din[2:0]),
    .full              (x_full),
    .rd_en             (in_rd_en),
    .dout              (x[2:0]),
    .empty             (x_empty)
);

fifo_array #(
    .FIFO_DATA_WIDTH   (32),
    .FIFO_BUFFER_SIZE  (1024),
    .ARRAY_SIZE        (3)
) fifo_array_y (
    .reset             (reset),
    .clock             (clock),
    .wr_en             (in_wr_en),
    .din               (y_din[2:0]),
    .full              (y_full),
    .rd_en             (in_rd_en),
    .dout              (y[2:0]),
    .empty             (y_empty)
);

sub u_dot (
    .clock        (clock),
    .reset        (reset),
    .x            (x[2:0]),
    .y            (y[2:0]),
    .in_empty     (in_empty),
    .in_rd_en     (in_rd_en),
    .out          (dout[2:0]),
    .out_empty    (out_empty),
    .out_rd_en    (out_rd_en)
);

always_comb begin
    in_empty = y_empty || x_empty;
end

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

initial begin : txt_read_process
    int i;
    int in_file_1, in_file_2;
    @(negedge reset);
    $display("@ %0t: Loading file %s...", $time, TXT_IN_1);
    $display("@ %0t: Loading file %s...", $time, TXT_IN_2);

    in_file_1 = $fopen(TXT_IN_1, "rb");
    in_file_2 = $fopen(TXT_IN_2, "rb");
    in_wr_en = 1'b0;

    i = 0;
    while (!$feof(in_file_1) && !$feof(in_file_2)) begin
        @(negedge clock);
        in_wr_en = 1'b0;
        if (!y_full || !x_full) begin
            $fscanf(in_file_1, "%08x %08x %08x\n", x_din[0], x_din[1], x_din[2]);
            $fscanf(in_file_2, "%08x %08x %08x\n", y_din[0], y_din[1], y_din[2]);
            in_wr_en = 1'b1;
        end
    end

    @(negedge clock);
    in_wr_en = 1'b0;
    $fclose(in_file_1);
    $fclose(in_file_2);
    // in_write_done = 1'b1;
end

initial begin: txt_write_process
    int j;
    int out_file, cmp_file;
    int pos, length;
    int cmp_dout;
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
            $fscanf(cmp_file, "%08x %08x %08x\n", cmp_dout[0], cmp_dout[1], cmp_dout[2]);
            $fwrite(out_file, "%08x %08x %08x\n", dout[0], dout[1], dout[2]);

            if (cmp_dout[0] != dout[0]) begin
                errors += 1;
                $write("@ %0t: ERROR: %x != %x\n", $time, dout[0], cmp_dout[0]);
            end
            if (cmp_dout[1] != dout[1]) begin
                errors += 1;
                $write("@ %0t: ERROR: %x != %x\n", $time, dout[1], cmp_dout[1]);
            end
            if (cmp_dout[2] != dout[2]) begin
                errors += 1;
                $write("@ %0t: ERROR: %x != %x\n", $time, dout[2], cmp_dout[2]);
            end
            out_rd_en = 1'b1;
            j = j + 27;
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