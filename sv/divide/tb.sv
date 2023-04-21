`timescale 1ns/1ns

module tb();

localparam string TXT_IN_1 = "txt/dividend.txt";
localparam string TXT_IN_2 = "txt/divisor.txt";
localparam string CMP = "txt/cmp.txt";
localparam string TXT_OUT = "txt/out.txt";
localparam CLOCK_PERIOD = 10;

localparam QUANTIZED_BITS = 'd10;
localparam DATA_WIDTH = 'd32;
localparam EXPANDED_DATA_WIDTH = DATA_WIDTH + QUANTIZED_BITS + 1;

localparam SEEK_END = 2;
localparam SEEK_SET = 0;

int errors = '0;

logic clock = 1'b1;
logic reset = '0;
// logic in_write_done = '0;
logic out_read_done = '0;

logic signed [DATA_WIDTH-1:0] dividend_in, divisor_in;
logic in_wr_en, in_full;
logic signed [DATA_WIDTH-1:0] dout;
logic out_empty, out_rd_en;

logic signed [DATA_WIDTH-1:0] dividend, divisor;
logic empty_1, empty_2;
logic in_full_1, in_full_2;
logic in_rd_en;

fifo #(
    .FIFO_DATA_WIDTH     (DATA_WIDTH),
    .FIFO_BUFFER_SIZE    (DATA_WIDTH*16)
) fifo_in_1 (
    .reset               (reset),
    .wr_clk              (clock),
    .rd_clk              (clock),

    .wr_en               (in_wr_en),
    .din                 (dividend_in),
    .full                (in_full_2),
    
    .rd_en               (in_rd_en),
    .dout                (dividend),
    .empty               (empty_1)
);

fifo #(
    .FIFO_DATA_WIDTH     (DATA_WIDTH),
    .FIFO_BUFFER_SIZE    (DATA_WIDTH*16)
) fifo_in_2 (
    .reset               (reset),
    .wr_clk              (clock),
    .rd_clk              (clock),

    .wr_en               (in_wr_en),
    .din                 (divisor_in),
    .full                (in_full_1),
    
    .rd_en               (in_rd_en),
    .dout                (divisor),
    .empty               (empty_2)
);

divide_top #(
    .Q_BITS       (QUANTIZED_BITS),
    .D_WIDTH      (DATA_WIDTH)
    // .ED_WIDTH     ('b1)
) u_divide_top (
    .clock        (clock),
    .reset        (reset),

    .dividend     (dividend),
    .divisor      (divisor),
    .in_empty     (in_empty),
    .in_rd_en     (in_rd_en),

    .out_empty    (out_empty),
    .out_rd_en    (out_rd_en),
    .out_dout     (dout)
);

always_comb begin
    in_full = in_full_1 || in_full_2;
    in_empty = empty_1 || empty_2;
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
        if (!in_full) begin
            $fscanf(in_file_1, "%08x\n", dividend_in);
            $fscanf(in_file_2, "%08x\n", divisor_in);
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