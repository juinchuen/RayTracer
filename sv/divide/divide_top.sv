module divide_top #(
    parameter Q_BITS = 'd10,
    parameter D_BITS = 'd32, //data width
    parameter ED_WIDTH = D_BITS + Q_BITS + 'b1  //expanded data width
    //ED_WIDTH should never be larger than Q_BITS + D_BITS + 1
) (
    input logic clock,
    input logic reset,
    
    input logic signed [D_BITS-1:0] dividend,
    input logic signed [D_BITS-1:0] divisor,
    input logic in_empty,
    output logic in_rd_en,

    output logic    out_empty,
    input logic     out_rd_en,
    output logic signed [D_BITS-1:0] out_dout
);

logic [D_BITS-1:0] out_din;
logic out_wr_en, out_full;

divide_module #(
    .Q_BITS       (Q_BITS),
    .D_BITS       (D_BITS),
    .ED_WIDTH     (ED_WIDTH)
) u_divide_module (
    .clock        (clock),
    .reset        (reset),
    .dividend     (dividend),
    .divisor      (divisor),
    .in_empty     (in_empty),
    .in_rd_en     (in_rd_en),
    
    .quotient     (out_din),
    .out_wr_en    (out_wr_en),
    .out_full     (out_full)
);

fifo #(
    .FIFO_DATA_WIDTH     (D_BITS),
    .FIFO_BUFFER_SIZE    (D_BITS*16)
) u_fifo (
    .reset               (reset),
    .wr_clk              (clock),
    .rd_clk              (clock),

    .wr_en               (out_wr_en),
    .din                 (out_din),
    .full                (out_full),
    
    .rd_en               (out_rd_en),
    .dout                (out_dout),
    .empty               (out_empty)
);
    
endmodule