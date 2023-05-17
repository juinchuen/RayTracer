module ray_tracer_top()

localparam D_BITS = 'd32;
localparam Q_BITS = 'd10;
localparam M_BITS = 'd12;



module fifo #(
    parameter FIFO_DATA_WIDTH = 32,
    parameter FIFO_BUFFER_SIZE = 1024) 
(
    input  logic reset,
    input  logic wr_clk,
    input  logic wr_en,
    input  logic [FIFO_DATA_WIDTH-1:0] din,
    output logic full,
    input  logic rd_clk,
    input  logic rd_en,
    output logic [FIFO_DATA_WIDTH-1:0] dout,
    output logic empty
);


module streamer #(
    parameter Q_BITS = 'd10,
    parameter D_BITS = 'd32,
    parameter M_BITS = 'd12
) (
    input logic clock,
    input logic reset,

    input logic in_empty,
    output logic in_rd_en,
    input logic signed [D_BITS-1 : 0] ray_in [5:0],

    input logic out_full,
    output logic out_wr_en,
    output logic signed [D_BITS-1 : 0] instruction_out [17:0],

    output logic [M_BITS-1 : 0] mem_addr,
    input logic signed [D_BITS-1 : 0] mem_data [11:0]
);