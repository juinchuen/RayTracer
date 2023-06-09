module acc_tb();

localparam CLOCK_PERIOD = 'd10;
localparam DATA_WIDTH = 'd32;

localparam Q_BITS = 'd10;
localparam D_BITS = 'd32;

logic clock;
logic reset;

logic input_wr_en;
logic input_rd_en;

logic signed [D_BITS-1 : 0] write_p_hit [2:0];
logic signed [D_BITS-1 : 0] read_p_hit [2:0];

logic input_full [2:0];
logic input_empty [2:0];

fifo #(
    .FIFO_DATA_WIDTH     (DATA_WIDTH),
    .FIFO_BUFFER_SIZE    (DATA_WIDTH*16)
) fifo_in_0 (
    .reset               (reset),
    .wr_clk              (clock),
    .rd_clk              (clock),

    .wr_en               (input_wr_en),
    .din                 (write_p_hit[0]),
    .full                (input_full[0]),
    
    .rd_en               (input_rd_en),
    .dout                (read_p_hit[0]),
    .empty               (input_empty[0])
);

fifo #(
    .FIFO_DATA_WIDTH     (DATA_WIDTH),
    .FIFO_BUFFER_SIZE    (DATA_WIDTH*16)
) fifo_in_1 (
    .reset               (reset),
    .wr_clk              (clock),
    .rd_clk              (clock),

    .wr_en               (input_wr_en),
    .din                 (write_p_hit[1]),
    .full                (input_full[1]),
    
    .rd_en               (input_rd_en),
    .dout                (read_p_hit[1]),
    .empty               (input_empty[1])
);

fifo #(
    .FIFO_DATA_WIDTH     (DATA_WIDTH),
    .FIFO_BUFFER_SIZE    (DATA_WIDTH*16)
) fifo_in_2 (
    .reset               (reset),
    .wr_clk              (clock),
    .rd_clk              (clock),

    .wr_en               (input_wr_en),
    .din                 (write_p_hit[2]),
    .full                (input_full[2]),
    
    .rd_en               (input_rd_en),
    .dout                (read_p_hit[2]),
    .empty               (input_empty[2])
);


initial begin

    clock = 0;
    reset = 0;
    input_wr_en = 0;

    #10

    reset = 1;

    #10

    reset = 0;

    write_p_hit [0] = 'd10 << Q_BITS;
    write_p_hit [1] = 'd10 << Q_BITS;
    write_p_hit [2] = 'd10 << Q_BITS;

    input_wr_en = 1;
    
    for (int i = 0; i < 10; i ++) begin

        #10

        write_p_hit[0] = write_p_hit[0] - ('d1 << Q_BITS);
        write_p_hit[1] = write_p_hit[1] - ('d1 << Q_BITS);
        write_p_hit[2] = write_p_hit[2] - ('d1 << Q_BITS);

    end

    input_wr_en = 0;

    wait(input_empty[0] && input_empty[1] && input_empty[2]);

    #1000

    $finish;

end

always begin

    #(CLOCK_PERIOD/2)
    clock = ~clock;

end

logic input_empty_or;
assign input_empty_or = input_empty[0] || input_empty[1] || input_empty[2];

logic output_full;
assign output_full = 0;

logic output_wr_en;

logic hit;
assign hit = 1;

logic signed [D_BITS-1 : 0] p_hit_min [2:0];

accumulate #(.Q_BITS (Q_BITS), .D_BITS(D_BITS)) DUT_INST0 (
    .clock      (clock),
    .reset      (reset),
    .in_empty   (input_empty_or),
    .in_rd_en   (input_rd_en),
    .out_full   (output_full),
    .out_wr_en  (output_wr_en),
    .hit        (hit),
    .p_hit      (read_p_hit),
    .p_hit_min  (p_hit_min)
);

endmodule