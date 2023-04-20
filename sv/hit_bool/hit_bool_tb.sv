`timescale 1 ns / 1 ns

module hit_bool_tb;

localparam P_HIT_FILE = "data_files/p_hit.txt";
localparam HIT_BOOL_FILE = "data_files/hit_bool.txt";
localparam int CLOCK_PERIOD = 10;
localparam int DATA_PTS = 256;
localparam Q_BITS = 16;
int counter = 0;

// Module variables
logic clock = 1'b1;
logic reset = '0;
logic [95:0] p_hit;
int normal  [2:0] = {32'hd504, 32'h0, 32'h8e00};
int v0 [2:0] = {32'hffff8000, 32'hffff8000, 32'h60000};
int v1 [2:0] = {32'h10000, 32'h8000, 32'h50000};
int v2 [2:0] = {32'h10000, 32'hffff8000, 32'h50000};

logic fifo_out_empty;
logic fifo_out_full;
logic hit;
logic fifo_out_rd_en;
logic fifo_out_wr_en;
logic fifo_out_dout;

logic fifo_in_wr_en;
logic fifo_in_full;
logic fifo_in_rd_en;
logic [95:0] fifo_in_dout;
logic fifo_in_empty;
hit_bool #(
    .Q_BITS(Q_BITS)
) u_hit_bool (
    //
    .clock             (clock),
    .reset             (reset),
    // p_hit module output, normal coordinates
    .p_hit             (fifo_in_dout),
    .normal            (normal),
    // Vector inputs
    .v0                (v0),
    .v1                (v1),
    .v2                (v2),
    // FIFO signals coming in
    .fifo_in_empty     (fifo_out_empty),
    .fifo_out_full     (fifo_out_full),
    // Output bool
    .hit               (hit),
    // FIFO signals going out 
    .fifo_in_rd_en     (fifo_in_rd_en),
    .fifo_out_wr_en    (fifo_out_wr_en)
);

fifo #(
    .FIFO_DATA_WIDTH     (32*3),
    .FIFO_BUFFER_SIZE    (1024)
) u_fifo_in (
    .reset               (reset),
    .wr_clk              (clock),
    .wr_en               (fifo_in_wr_en),
    .din                 (p_hit),
    .full                (fifo_in_full),
    .rd_clk              (clock),
    .rd_en               (fifo_in_rd_en),
    .dout                (fifo_in_dout),
    .empty               (fifo_in_empty)
);

fifo #(
    .FIFO_DATA_WIDTH     (1),
    .FIFO_BUFFER_SIZE    (1024)
) u_fifo_out (
    .reset               (reset),
    .wr_clk              (clock),
    .wr_en               (fifo_out_wr_en),
    .din                 (hit),
    .full                (fifo_out_full),
    .rd_clk              (clock),
    .rd_en               (fifo_out_rd_en),
    .dout                (fifo_out_dout),
    .empty               (fifo_out_empty)
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

    while (!$feof(p_hit_file)) begin
        @(negedge clock)
        fifo_in_wr_en = 1'b0;
        fifo_out_rd_en = 1'b0;
        if (fifo_in_full == 1'b0)begin
            $fscanf(p_hit_file, "%x, %x, %x\n", temp0, temp1, temp2);
            p_hit[31:0] = temp0;
            p_hit[63:32] = temp1;
            p_hit[95:64] = temp2;
            // p_hit = {int'(temp0), int'(temp1), int'(temp2)};
            fifo_in_wr_en = 1'b1;
        end
        if (fifo_out_empty == 1'b0) begin
            if (fifo_out_dout)begin
                $fwrite(hit_bool_file, "true\n");
            end else begin
                $fwrite(hit_bool_file, "false\n");
            end
            fifo_out_rd_en = 1'b1;
        end
        counter++;
    end
    $fclose(p_hit_file);
    $fclose(hit_bool_file);
    $finish;
end

endmodule