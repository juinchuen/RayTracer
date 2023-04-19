`timescale 1ns/1ns

module tb();

localparam QUANTIZED_BITS = 'd10;
localparam DATA_WIDTH = 'd32;
localparam EXPANDED_DATA_WIDTH = DATA_WIDTH + QUANTIZED_BITS + 1;

localparam CLOCK_PERIOD = 10;

logic clock = 1'b1;
logic reset = '0;
logic signed [DATA_WIDTH-1:0] din;
logic signed [DATA_WIDTH-1:0] dout;
// logic start = '0;
// logic done  = '0;

logic in_wr_en;
logic in_full;


logic signed [DATA_WIDTH-1:0] dividend;
logic signed [DATA_WIDTH-1:0] divisor;
logic signed [DATA_WIDTH-1:0] quotient;

logic valid_in, valid_out;

fifo #(
    .FIFO_DATA_WIDTH     (DATA_WIDTH),
    .FIFO_BUFFER_SIZE    (DATA_WIDTH*16)
) fifo_in (
    .reset               (reset),
    .wr_clk              (clock),
    .rd_clk              (clock),

    .wr_en               (in_wr_en),
    .din                 (din),
    .full                (in_full),
    
    .rd_en               (rd_en),
    .dout                (),
    .empty               (empty)
);

divide_module #(
    .Q_BITS(QUANTIZED_BITS),
    .D_WIDTH(DATA_WIDTH),
    .ED_WIDTH(EXPANDED_DATA_WIDTH)
) divide_inst(
    .clock(clock),
    .reset(reset),
    .dividend(dividend),
    .divisor(divisor),
    .quotient(quotient),
    .in_empty(),
    .out_full(),
);

fifo #(
    .FIFO_DATA_WIDTH     (DATA_WIDTH),
    .FIFO_BUFFER_SIZE    (DATA_WIDTH*16)
) fifo_in (
    .reset               (reset),
    .wr_clk              (clock),
    .rd_clk              (clock),

    .wr_en               (wr_en),
    .din                 (din),
    .full                (full),
    
    .rd_en               (rd_en),
    .dout                (dout),
    .empty               (empty)
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

initial begin: input_process
    @(negedge clock);
    dividend =  -'d190 << QUANTIZED_BITS;
    divisor =   'd7 << QUANTIZED_BITS;
    valid_in = 'b1;
end

initial begin: output_read
    wait(valid_out);
    $display("Answer is: %f", (real'(quotient)/real'(2**QUANTIZED_BITS)));
    $finish;
end

endmodule