module fifo_array #(
    parameter FIFO_DATA_WIDTH = 32,
    parameter FIFO_BUFFER_SIZE = 1024,
    parameter ARRAY_SIZE = 4
) (
    input  logic reset,
    input  logic clock,

    input  logic wr_en,
    input  logic signed [FIFO_DATA_WIDTH-1:0] din[ARRAY_SIZE-1:0],
    output logic full,
    
    input  logic rd_en,
    output logic signed [FIFO_DATA_WIDTH-1:0] dout[ARRAY_SIZE-1:0],
    output logic empty
);

logic full_arr[ARRAY_SIZE-1:0], empty_arr[ARRAY_SIZE-1:0];

logic signed [31:0] temp1, temp2, temp3;

always_comb begin
    temp1 = din[0];
    temp2 = din[1];
    temp3 = din[2];
end

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
endgenerate

// logic [ARRAY_SIZE-1:0] dummy1, dummy2;


logic all_empty = 0;
logic all_full = 0;
// generate for(j = 0; j < ARRAY_SIZE; j = j + 1) begin
//     assign dummy1 = empty_arr[j];
//     assign dummy2 = full_arr[j];
//     all_empty = all_empty or empty_arr[i];
// end
// endgenerate


always_comb begin
    all_empty = empty_arr[0];
    all_full = full_arr[0];
    for(int j = 1; j < ARRAY_SIZE; j = j + 1) begin
        all_empty = all_empty || empty_arr[j];
        all_full = all_full || full_arr[j];
    end
    empty = all_empty;
    full = all_full;
end

// always_comb begin
//     empty = |dummy1;
//     full = |dummy2;
// end

// always_comb begin
//     for() begin
//         empty = empty || empty_arr[j];
//         full = full || full_arr[j];
//     end
//     // empty = empty_arr.or();
//     // full = full_arr.or();
// end
    
endmodule