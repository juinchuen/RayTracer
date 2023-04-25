`timescale 1ns/1ns

module tb();

localparam string TXT_IN_1 = "txt/x.txt";
localparam string TXT_IN_2 = "txt/y.txt";
localparam string TXT_CMP = "txt/cmp.txt";
localparam string TXT_OUT = "txt/out.txt";
localparam CLOCK_PERIOD = 10;

localparam Q_BITS = 'd10;

localparam SEEK_END = 2;
localparam SEEK_SET = 0;

int errors = '0;

logic clock = 1'b1;
logic reset = '0;
// logic in_write_done = '0;
logic out_read_done = '0;

logic in_wr_en;
int x_din[2:0], y_din[2:0];
logic out_empty, out_rd_en;
int dout;


int x[2:0], y[2:0];
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

dot #(
    .Q_BITS       ('d10)
) u_dot (
    .clock        (clock),
    .reset        (reset),
    .x            (x[2:0]),
    .y            (y[2:0]),
    .in_empty     (in_empty),
    .in_rd_en     (in_rd_en),
    .out          (dout),
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
            $fscanf(in_file_1, "%08x %08x %08x\n", x[0], x[1], x[2]);
            $fscanf(in_file_2, "%08x %08x %08x\n", y[0], y[1], y[2]);
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
            $fscanf(cmp_file, "%08x\n", cmp_dout);
            $fwrite(out_file, "%08x\n", dout);

            if (cmp_dout != dout) begin
                errors += 1;
                $write("@ %0t: ERROR: %x != %x\n", $time, dout, cmp_dout);
            end
            out_rd_en = 1'b1;
            $display("Answer is: %f", (real'(dout)/real'(2**QUANTIZED_BITS)));
            j = j + 5;
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