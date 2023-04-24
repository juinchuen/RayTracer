module fifo_array #(
    parameter FIFO_DATA_WIDTH = 32,
    parameter FIFO_BUFFER_SIZE = 1024,
    parameter ARRAY_SIZE = 4
) (
    input  logic reset,
    input  logic clock,

    input  logic wr_en,
    input  logic [FIFO_DATA_WIDTH-1:0] din[ARRAY_SIZE-1:0],
    output logic full,
    
    input  logic rd_en,
    output logic [FIFO_DATA_WIDTH-1:0] dout[ARRAY_SIZE-1:0],
    output logic empty
);

logic full_arr[ARRAY_SIZE-1:0], empty_arr[ARRAY_SIZE-1:0];

genvar i;
generate for(i = 0; i < ARRAY_SIZE; i = i + 1) begin
    fifo #(
        .FIFO_DATA_WIDTH     (FIFO_DATA_WIDTH),
        .FIFO_BUFFER_SIZE    (FIFO_BUFFER_SIZE)
    ) u_fifo (
        .reset               (reset),
        .wr_clk              (clock),
        .rd_clk              (clock),

        .din                 (din[i]),
        .wr_en               (wr_en),
        .full                (full_arr[i]),
        
        .dout                (dout[i]),
        .rd_en               (rd_en),
        .empty               (empty_arr[i])
    );
end

always_comb begin
    empty = empty_arr.or();
    full = full_arr.or();
end
endgenerate
    
endmodule